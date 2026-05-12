const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const { getDistanceFromLatLonInKm } = require('./geoHelper');
const { GoogleGenerativeAI } = require("@google/generative-ai");


require('dotenv').config();

// Inisialisasi Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const rerouteTool = {
  name: "trigger_reroute_offer",
  description: "Memicu penawaran pengalihan rute ke pelanggan saat terjadi kemacetan parah, memilih node mitra terbaik, dan menentukan jumlah cashback.",
  parameters: {
    type: "OBJECT",
    properties: {
      node_id: {
        type: "STRING",
        description: "ID unik dari mitra yang dipilih (contoh: node_001).",
      },
      cashback_amount: {
        type: "INTEGER",
        description: "Nominal cashback dalam Rupiah (antara 3000 hingga 7000). Semakin lama delay, nominal harus semakin tinggi.",
      },
      reason: {
        type: "STRING",
        description: "Alasan persuasif singkat untuk pelanggan agar mau mengambil di mitra (maksimal 1 kalimat yang ramah).",
      }
    },
    required: ["node_id", "cashback_amount", "reason"],
  },
};

const model = genAI.getGenerativeModel({
  model: "gemini-2.5-flash",
  tools: [{ functionDeclarations: [rerouteTool] }],
});

console.log("🚀 Flexi Nodes Backend: Monitoring started...");

// Fungsi Utama: Mengawasi koleksi 'deliveries'
const watcher = db.collection('deliveries').onSnapshot(snapshot => {
  snapshot.docChanges().forEach(change => {
    // Mengecek jika ada dokumen baru (added) atau data yang diperbarui (modified)
    if (change.type === 'added' || change.type === 'modified') {
      const deliveryData = change.doc.data();
      const deliveryId = change.doc.id;

      console.log(`📦 Update terdeteksi pada Paket: ${deliveryId}`);

      // LOGIKA PEMICU AI:
      // Kita hanya memicu AI jika statusnya 'on_delivery' dan delay > 15 menit
      if (deliveryData.status === 'on_delivery' && deliveryData.current_traffic_delay > 15) {
        console.log("⚠️ Kemacetan terdeteksi! Memulai analisis AI...");

        // Di sinilah nanti kita memanggil fungsi Haversine dan Gemini API
        handleTrafficDelay(deliveryId, deliveryData);
      }

      if (deliveryData.status === 'rerouted_to_node') {
      console.log("🔄 User setuju! Memproses pengalihan rute...");

      // Ambil ID mitra dari tawaran AI yang sudah tersimpan di dokumen
      const selectedNodeId = deliveryData.ai_offer?.node_id;

      if (selectedNodeId) {
        // Panggil fungsi pengurangan kapasitas
        reduceNodeCapacity(selectedNodeId);
      } else {
        console.log("⚠️ Data node_id tidak ditemukan pada ai_offer.");
      }
    }
    }
  });
}, err => {
  console.log(`❌ Error pada Listener: ${err}`);
});

// Placeholder fungsi untuk tahap selanjutnya
async function handleTrafficDelay(deliveryId, deliveryData) {
  try {
    console.log(`\n--- Memproses Keterlambatan Paket: ${deliveryId} ---`);

    // Asumsi: Dokumen pengiriman Anda menyimpan koordinat tujuan/lokasi macet
    // Sesuaikan nama field 'target_latitude' dengan skema yang disepakati dengan tim Flutter
    const lat = deliveryData.target_latitude;
    const lon = deliveryData.target_longitude;
    const delay = deliveryData.current_traffic_delay;

    // ==========================================
    // 1. Cari Mitra Terdekat (Haversine)
    // ==========================================
    console.log(`📍 Mencari mitra terdekat dari lokasi macet...`);
    const nearbyNodes = await findNearestNodes(lat, lon);

    if (nearbyNodes.length === 0) {
      console.log("❌ Tidak ada mitra dalam radius terdekat atau kapasitas penuh.");
      console.log("➡️ Pengiriman tetap dilanjutkan secara normal (door-to-door).");
      return; // Hentikan eksekusi jika tidak ada opsi mitra
    }

    // ==========================================
    // 2. Panggil Gemini (Function Calling)
    // ==========================================
    console.log(`🧠 Meminta Gemini merancang penawaran untuk delay ${delay} menit...`);
    const aiOffer = await analyzeAndTriggerOffer(deliveryId, delay, nearbyNodes);

    // ==========================================
    // 3. Update Firestore (Memicu UI Flutter)
    // ==========================================
    if (aiOffer && aiOffer.node_id) {
      console.log(`💾 Menyimpan keputusan Gemini ke Firestore...`);

      // Mengubah dokumen di Firestore. 
      // Perubahan inilah yang akan dideteksi oleh StreamBuilder di aplikasi Flutter!
      await db.collection('deliveries').doc(deliveryId).update({
        status: "pending_user_approval",
        ai_offer: {
          node_id: aiOffer.node_id,
          cashback_amount: aiOffer.cashback_amount,
          reason: aiOffer.reason,
          offered_at: admin.firestore.FieldValue.serverTimestamp() // Catat waktu penawaran
        }
      });

      console.log(`🎉 Sukses! Status paket ${deliveryId} diperbarui. Menunggu respon user di aplikasi Flutter.`);
      console.log(`---------------------------------------------------`);
    } else {
      console.log("⚠️ Proses dihentikan karena AI gagal mengembalikan penawaran yang valid.");
    }

  } catch (error) {
    console.error(`❌ Terjadi kesalahan fatal pada handleTrafficDelay:`, error);
  }
}

async function findNearestNodes(targetLat, targetLon) {
  try {
    const nodesSnapshot = await db.collection('nodes').get();
    let nearbyNodes = [];

    nodesSnapshot.forEach(doc => {
      const nodeData = doc.data();
      const distance = getDistanceFromLatLonInKm(
        targetLat,
        targetLon,
        nodeData.latitude,
        nodeData.longitude
      );

      if (distance <= 2 && nodeData.capacity > 0) {
        nearbyNodes.push({
          node_id: doc.id,
          name: nodeData.name,
          distance_km: parseFloat(distance.toFixed(2)),
          capacity: nodeData.capacity
        });
      }
    });

    nearbyNodes.sort((a, b) => a.distance_km - b.distance_km);

    return nearbyNodes.slice(0, 3); // ambil 3 terdekat

  } catch (error) {
    console.error("❌ Error finding nearby nodes:", error);
    return [];
  }
}

async function analyzeAndTriggerOffer(deliveryId, delayMinutes, nearbyNodes) {
  console.log(`🤖 Gemini sedang menganalisis opsi untuk Paket ${deliveryId}...`);

  // Ini adalah Prompt Engineering Anda
  const prompt = `
    Anda adalah sistem AI Logistik Cerdas untuk 'Flexi Nodes'.
    Terdapat paket yang terdeteksi akan mengalami keterlambatan lalu lintas selama ${delayMinutes} menit.
    
    Berikut adalah data mitra (nodes) terdekat yang tersedia saat ini dalam format JSON:
    ${JSON.stringify(nearbyNodes, null, 2)}
    
    Tugas Anda:
    1. Analisis daftar mitra di atas. Pilih SATU mitra paling optimal (prioritaskan jarak terdekat yang kapasitasnya > 0).
    2. Tentukan kompensasi cashback yang pantas untuk keterlambatan ${delayMinutes} menit.
    3. Panggil fungsi 'trigger_reroute_offer' dengan keputusan Anda.
  `;

  try {
    const result = await model.generateContent(prompt);

    // Mengekstrak hasil panggilan fungsi dari Gemini
    const call = result.response.functionCalls()[0];

    if (call && call.name === "trigger_reroute_offer") {
      const { node_id, cashback_amount, reason } = call.args;

      console.log(`✅ Keputusan AI Diterima!`);
      console.log(`- Mitra Terpilih: ${node_id}`);
      console.log(`- Nominal Cashback: Rp ${cashback_amount}`);
      console.log(`- Pesan: "${reason}"`);

      // Mengembalikan data JSON yang rapi
      return call.args;
    } else {
      console.log("⚠️ AI tidak mengembalikan format Function Call yang diharapkan.");
      return null;
    }
  } catch (error) {
    console.error("❌ Gagal menghubungi Gemini API:", error);
    return null;
  }
}

async function reduceNodeCapacity(nodeId) {
  try {
    const nodeRef = db.collection('nodes').doc(nodeId)

    await nodeRef.update({
      capacity: admin.firestore.FieldValue.increment(-1)
    });
    console.log(`Kapasitas mitra ${nodeId} berhasil dikurangi 1.`)
  } catch (error) {
    console.error(`❌ Gagal mengurangi kapasitas mitra ${nodeId}:`, error);
  }
}