const admin = require('firebase-admin');
const { FieldValue } = require('firebase-admin/firestore');
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const express = require('express');
const cors = require('cors');
const { getDistanceFromLatLonInKm } = require('./geoHelper');
const serviceAccount = require('./serviceAccountKey.json');
require('dotenv').config();

// Inisialisasi Admin SDK
// Untuk Cloud Functions/Emulator, cukup gunakan admin.initializeApp() tanpa parameter
if (!admin.apps.length) {
  admin.initializeApp();
}

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
      voucherType: {
        type: "STRING",
        description: "Tipe voucher kompensasi untuk pengguna (contoh: 'free_shipping', 'discount_5', 'discount_10'). Semakin lama delay, berikan voucher yang lebih bernilai.",
      },
      reason: {
        type: "STRING",
        description: "Alasan persuasif singkat untuk pelanggan agar mau mengambil di mitra (maksimal 1 kalimat yang ramah).",
      }
    },
    required: ["node_id", "voucherType", "reason"],
  },
};

const model = genAI.getGenerativeModel({
  model: "gemini-2.5-flash",
  tools: [{ functionDeclarations: [rerouteTool] }],
});

// ============================================================================
// PHASE 1: FIREBASE CLOUD FUNCTIONS (AI AUTONOMOUS ENGINE)
// ============================================================================

exports.onDeliveryUpdated = onDocumentUpdated("deliveries/{deliveryId}", async (event) => {
  const newValue = event.data.after.data();
  const previousValue = event.data.before.data();
  const deliveryId = event.params.deliveryId;

  // 1. Logika AI: Deteksi Kemacetan
  if (newValue.delayMinutes > 15 && newValue.status === 'on_delivery') {
    // Pastikan AI belum pernah menawarkan sebelumnya untuk paket ini
    const existingOffers = await db.collection('offers')
      .where('deliveryId', '==', deliveryId)
      .get();

    if (!existingOffers.empty) {
      console.log(`⏳ Paket ${deliveryId} sudah memiliki penawaran AI. Melewati...`);
      return;
    }

    console.log(`⚠️ Kemacetan terdeteksi pada paket ${deliveryId}! Memulai analisis AI...`);
    await handleTrafficDelay(deliveryId, newValue);
  }

  // 2. Logika Eksekusi Logistik: Pengurangan Kapasitas
  if (newValue.status === 'rerouted_to_node' && previousValue.status !== 'rerouted_to_node') {
    console.log(`🔄 Paket ${deliveryId} dialihkan! Memproses kapasitas node...`);
    const selectedNodeId = newValue.selectedNodeId;
    if (selectedNodeId) {
      await reduceNodeCapacity(selectedNodeId);
    }
  }
});

async function handleTrafficDelay(deliveryId, deliveryData) {
  try {
    // Menggunakan GeoPoint: targetLocation
    const lat = deliveryData.targetLocation?.latitude;
    const lon = deliveryData.targetLocation?.longitude;
    const delay = deliveryData.delayMinutes;
    const receiverId = deliveryData.receiverId;

    if (!lat || !lon) {
      console.error(`❌ GeoPoint 'targetLocation' tidak ditemukan pada paket ${deliveryId}`);
      return;
    }

    const nearbyNodes = await findNearestNodes(lat, lon);

    if (nearbyNodes.length === 0) {
      console.log("❌ Tidak ada mitra dalam radius terdekat atau kapasitas penuh.");
      return;
    }

    const aiOffer = await analyzeAndTriggerOffer(deliveryId, delay, nearbyNodes);

    if (aiOffer && aiOffer.node_id) {
      console.log(`💾 Menyimpan keputusan Gemini ke Firestore...`);

      const nodeInfo = nearbyNodes.find(n => n.node_id === aiOffer.node_id);

      // Buat dokumen offer di tabel 'offers'
      await db.collection('offers').add({
        deliveryId: deliveryId,
        receiverId: receiverId || "unknown",
        nodeId: aiOffer.node_id,
        nodeName: nodeInfo ? nodeInfo.name : "Unknown Node",
        voucherType: aiOffer.voucherType,
        distanceMeters: Math.round((nodeInfo ? nodeInfo.distance_km : 0) * 1000),
        status: "pending",
        reason: aiOffer.reason,
        offeredAt: FieldValue.serverTimestamp()
      });

      // Kirim pesan peringatan otomatis ke chatbot
      await db.collection('AI_message').add({
        deliveryId: deliveryId,
        sender: "Flexi AI",
        message: `Hai! Saya mendeteksi ada kemacetan parah di rute Anda (delay ~${delay} menit). Saya punya tawaran rute alternatif ke mitra terdekat dengan kompensasi voucher! Silakan cek notifikasi Anda.`,
        type: "ai_reasoning",
        createdAt: FieldValue.serverTimestamp()
      });

      console.log(`🎉 Sukses! Offer dan AI message untuk paket ${deliveryId} berhasil dibuat.`);
    }
  } catch (error) {
    console.error(`❌ Terjadi kesalahan pada handleTrafficDelay:`, error);
  }
}

async function findNearestNodes(targetLat, targetLon) {
  try {
    const nodesSnapshot = await db.collection('nodes').get();
    let nearbyNodes = [];

    nodesSnapshot.forEach(doc => {
      const nodeData = doc.data();
      const nodeLat = nodeData.location?.latitude;
      const nodeLon = nodeData.location?.longitude;

      if (nodeLat && nodeLon) {
        const distance = getDistanceFromLatLonInKm(
          targetLat,
          targetLon,
          nodeLat,
          nodeLon
        );

        console.log(`🔍 Checking Node ${doc.id}: Dist=${distance.toFixed(2)}km, Cap=${nodeData.capacity}`);

        if (distance <= 2 && nodeData.capacity > 0) {
          nearbyNodes.push({
            node_id: doc.id,
            name: nodeData.name,
            distance_km: parseFloat(distance.toFixed(2)),
            capacity: nodeData.capacity
          });
        }
      } else {
        console.log(`⚠️ Node ${doc.id} tidak punya field 'location' (GeoPoint) yang valid.`);
      }
    });

    nearbyNodes.sort((a, b) => a.distance_km - b.distance_km);
    return nearbyNodes.slice(0, 3);
  } catch (error) {
    console.error("❌ Error finding nearby nodes:", error);
    return [];
  }
}

async function analyzeAndTriggerOffer(deliveryId, delayMinutes, nearbyNodes) {
  const prompt = `
    Anda adalah sistem AI Logistik Cerdas untuk 'Flexi Nodes'.
    Terdapat paket yang terdeteksi akan mengalami keterlambatan lalu lintas selama ${delayMinutes} menit.
    
    Berikut adalah data mitra (nodes) terdekat yang tersedia saat ini:
    ${JSON.stringify(nearbyNodes, null, 2)}
    
    Tugas Anda:
    1. Analisis daftar mitra di atas. Pilih SATU mitra paling optimal.
    2. Tentukan kompensasi cashback yang pantas untuk keterlambatan ${delayMinutes} menit.
    3. Panggil fungsi 'trigger_reroute_offer' dengan keputusan Anda.
  `;

  try {
    const result = await model.generateContent(prompt);
    const call = result.response.functionCalls()[0];

    if (call && call.name === "trigger_reroute_offer") {
      return call.args;
    }
    return null;
  } catch (error) {
    console.error("❌ Gagal menghubungi Gemini API:", error);
    return null;
  }
}

async function reduceNodeCapacity(nodeId) {
  try {
    const nodeRef = db.collection('nodes').doc(nodeId)
    await nodeRef.update({
      capacity: FieldValue.increment(-1)
    });
    console.log(`Kapasitas mitra ${nodeId} berhasil dikurangi 1.`)
  } catch (error) {
    console.error(`❌ Gagal mengurangi kapasitas mitra ${nodeId}:`, error);
  }
}

// ============================================================================
// PHASE 2: REST API ENDPOINTS (EXPRESS)
// ============================================================================

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// [GET] /api/deliveries - Mendapatkan daftar paket
app.get('/deliveries', async (req, res) => {
  try {
    const snapshot = await db.collection('deliveries').get();
    const deliveries = [];
    snapshot.forEach(doc => deliveries.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, data: deliveries });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// [GET] /api/nodes - Mendapatkan daftar mitra
app.get('/nodes', async (req, res) => {
  try {
    const snapshot = await db.collection('nodes').get();
    const nodes = [];
    snapshot.forEach(doc => nodes.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, data: nodes });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// [POST] /api/simulate-traffic - Endpoint untuk trigger demo dari frontend
app.post('/simulate-traffic', async (req, res) => {
  const { deliveryId, delayMinutes } = req.body;
  if (!deliveryId) return res.status(400).json({ success: false, error: "deliveryId is required" });

  try {
    const docRef = db.collection('deliveries').doc(deliveryId);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ success: false, error: `Dokumen ${deliveryId} tidak ada di koleksi 'deliveries'. Silakan buat dulu di Emulator UI.` });
    }

    await docRef.update({
      delayMinutes: delayMinutes || 20 // Default > 15 untuk trigger AI
    });
    res.json({ success: true, message: `Simulated ${delayMinutes || 20} min delay on ${deliveryId}. AI is analyzing...` });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// [POST] /api/accept-offer - Endpoint untuk receiver menerima tawaran
app.post('/accept-offer', async (req, res) => {
  const { deliveryId } = req.body;
  if (!deliveryId) return res.status(400).json({ success: false, error: "deliveryId is required" });

  try {
    // 1. Ambil penawaran (offer) yang sedang pending untuk delivery ini
    const offersSnapshot = await db.collection('offers')
      .where('deliveryId', '==', deliveryId)
      .where('status', '==', 'pending')
      .get();

    if (offersSnapshot.empty) {
      return res.status(404).json({ error: "Penawaran tidak ditemukan atau sudah diproses." });
    }

    const offerDoc = offersSnapshot.docs[0];
    const offerData = offerDoc.data();

    // 2. Buat OTP acak dan kode Voucher
    const pickupOtp = Math.floor(100000 + Math.random() * 900000).toString();
    const voucherCode = `FLX-${offerData.voucherType.toUpperCase()}-${Math.floor(1000 + Math.random() * 9000)}`;

    // 3. Update status delivery
    await db.collection('deliveries').doc(deliveryId).update({
      status: "rerouted_to_node",
      selectedNodeId: offerData.nodeId,
      selectedNodeName: offerData.nodeName,
      otpCode: pickupOtp,
      updatedAt: FieldValue.serverTimestamp()
    });

    // 4. Update status offer jadi accepted dan simpan vouchernya
    await offerDoc.ref.update({
      status: "accepted",
      voucherCode: voucherCode
    });

    res.json({
      success: true,
      message: "Offer accepted. Rerouted successfully.",
      otp: pickupOtp,
      voucherCode: voucherCode
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Endpoint untuk AI Chatbot
app.post('/chat', async (req, res) => {
  const { deliveryId, receiverId, message } = req.body;

  if (!deliveryId || !message) {
    return res.status(400).json({ success: false, error: "deliveryId and message are required" });
  }

  try {
    // 1. Simpan pesan user ke database
    await db.collection('AI_message').add({
      deliveryId,
      receiverId: receiverId || "unknown",
      sender: "User",
      message: message,
      type: "user",
      createdAt: FieldValue.serverTimestamp()
    });

    // 2. Ambil konteks paket saat ini
    const deliveryDoc = await db.collection('deliveries').doc(deliveryId).get();
    const deliveryData = deliveryDoc.exists ? deliveryDoc.data() : null;

    // 3. Ambil riwayat percakapan sebelumnya (batas 5 terakhir agar hemat token)
    const historySnapshot = await db.collection('AI_message')
      .where('deliveryId', '==', deliveryId)
      .orderBy('createdAt', 'desc')
      .limit(5)
      .get();

    let chatHistory = "";
    historySnapshot.docs.reverse().forEach(doc => {
      const d = doc.data();
      chatHistory += `${d.sender}: ${d.message}\n`;
    });

    // 4. Siapkan Prompt untuk Gemini
    const systemPrompt = `Anda adalah asisten AI dari FlexiNode, layanan logistik cerdas. Tugas Anda menjawab pertanyaan pelanggan dengan ramah, singkat, dan solutif.
Data Paket Saat Ini:
- Status: ${deliveryData?.status || 'Unknown'}
- Delay Kemacetan: ${deliveryData?.delayMinutes || 0} menit
- Tujuan: ${deliveryData?.receiverName || 'Unknown'}

Riwayat Chat Terbaru:
${chatHistory}
User: ${message}
AI:`;

    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    const result = await model.generateContent(systemPrompt);
    const aiResponse = result.response.text();

    // 5. Simpan balasan AI ke database
    await db.collection('AI_message').add({
      deliveryId,
      receiverId: receiverId || "unknown",
      sender: "Flexi AI",
      message: aiResponse,
      type: "ai_chat",
      createdAt: FieldValue.serverTimestamp()
    });

    res.json({ success: true, response: aiResponse });
  } catch (error) {
    console.error("❌ Chat error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Export Express app sebagai Cloud Function "api"
exports.api = onRequest(app);