const admin = require('firebase-admin');
const { FieldValue } = require('firebase-admin/firestore');
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const express = require('express');
const cors = require('cors');
const { getDistanceFromLatLonInKm } = require('./geoHelper');
require('dotenv').config();

// Inisialisasi Admin SDK
// Di Cloud Functions, admin.initializeApp() otomatis menggunakan service account default.
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
        message: `Hai! Saya mendeteksi kemacetan berat di rute paket ${deliveryId} dengan estimasi keterlambatan sekitar ${delay} menit. Rute alternatif yang saya rekomendasikan adalah ${nodeInfo ? nodeInfo.name : "mitra FlexiNode terdekat"}${nodeInfo ? `, sekitar ${Math.round(nodeInfo.distance_km * 1000)} meter dari tujuan` : ""}. Silakan cek notifikasi untuk melihat detail mitra dan kompensasi voucher.`,
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
      delayMinutes: delayMinutes || 20, // Default > 15 untuk trigger AI
      current_traffic_delay: delayMinutes || 20,
      homeDeliverySelected: false,
      trafficMode: "demo",
      updatedAt: FieldValue.serverTimestamp()
    });
    res.json({ success: true, message: `Simulated ${delayMinutes || 20} min delay on ${deliveryId}. AI is analyzing...` });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// [POST] /api/accept-offer - Endpoint untuk receiver menerima tawaran
app.post('/accept-offer', async (req, res) => {
  const {
    deliveryId,
    nodeId,
    nodeName,
    nodeLat,
    nodeLng,
    voucherAmount,
    cashbackAmount
  } = req.body;
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
    const selectedNodeId = nodeId || offerData.nodeId;
    const selectedNodeName = nodeName || offerData.nodeName;
    const selectedVoucherAmount = voucherAmount || cashbackAmount || offerData.voucherAmount || offerData.cashback_amount || 5000;
    const selectedVoucherType = voucherTypeForAmount(selectedVoucherAmount, offerData.voucherType);

    // 2. Buat OTP acak dan kode Voucher
    const pickupOtp = Math.floor(100000 + Math.random() * 900000).toString();
    const voucherCode = `FLX-${selectedVoucherType.toUpperCase()}-${Math.floor(1000 + Math.random() * 9000)}`;

    // 3. Update status delivery
    const deliveryUpdate = {
      status: "rerouted_to_node",
      selectedNodeId,
      selectedNodeName,
      voucherAmount: selectedVoucherAmount,
      cashbackAmount: selectedVoucherAmount,
      otpCode: pickupOtp,
      updatedAt: FieldValue.serverTimestamp()
    };

    if (typeof nodeLat === 'number') deliveryUpdate.selectedNodeLat = nodeLat;
    if (typeof nodeLng === 'number') deliveryUpdate.selectedNodeLng = nodeLng;

    await db.collection('deliveries').doc(deliveryId).update(deliveryUpdate);

    // 4. Update status offer jadi accepted dan simpan vouchernya
    await offerDoc.ref.update({
      nodeId: selectedNodeId,
      nodeName: selectedNodeName,
      status: "accepted",
      voucherType: selectedVoucherType,
      voucherAmount: selectedVoucherAmount,
      cashback_amount: selectedVoucherAmount,
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

function voucherTypeForAmount(amount, fallback = "discount_5") {
  if (amount >= 10000) return "discount_10";
  if (amount >= 5000) return "discount_5";
  if (amount >= 4000) return "discount_4";
  return fallback;
}

function firstPresent(...values) {
  return values.find((value) => value !== undefined && value !== null && value !== "");
}

function formatRupiah(amount) {
  const parsed = Number(amount);
  if (!Number.isFinite(parsed) || parsed <= 0) return null;
  return `Rp${parsed.toLocaleString("id-ID")}`;
}

function formatDistance(meters) {
  const parsed = Number(meters);
  if (!Number.isFinite(parsed) || parsed <= 0) return null;
  if (parsed >= 1000) return `${(parsed / 1000).toFixed(1).replace(".", ",")} km`;
  return `${Math.round(parsed)} meter`;
}

function buildChatContext(deliveryId, deliveryData = {}, offerData = {}) {
  const status = deliveryData.status || "Unknown";
  const delayMinutes = Number(firstPresent(
    deliveryData.delayMinutes,
    deliveryData.current_traffic_delay,
    0
  ));
  const normalizedDelay = Number.isFinite(delayMinutes) ? delayMinutes : 0;
  const hasActiveOffer = ["pending", "accepted"].includes(offerData.status);
  const hasRerouteContext = [
    "offer_pending",
    "rerouted_to_node",
    "delivered_to_node",
    "completed",
  ].includes(status) || hasActiveOffer;
  const voucherAmount = firstPresent(
    deliveryData.voucherAmount,
    deliveryData.cashbackAmount,
    offerData.voucherAmount,
    offerData.cashback_amount
  );
  const selectedNodeName = hasRerouteContext ? firstPresent(
    deliveryData.selectedNodeName,
    offerData.nodeName,
    deliveryData.nodeName
  ) : null;
  const distanceText = hasRerouteContext ? formatDistance(firstPresent(
    offerData.distanceMeters,
    deliveryData.distanceMeters
  )) : null;

  return {
    deliveryId,
    status,
    hasRerouteContext,
    receiverName: firstPresent(deliveryData.receiverName, "Customer"),
    receiverAddress: firstPresent(deliveryData.receiverAddress, deliveryData.address),
    selectedNodeName,
    selectedNodeId: hasRerouteContext ? firstPresent(deliveryData.selectedNodeId, offerData.nodeId) : null,
    distanceText,
    delayMinutes: normalizedDelay,
    trafficStatus: normalizedDelay > 0
      ? firstPresent(deliveryData.trafficStatus, deliveryData.trafficMode, "terdeteksi delay")
      : "normal",
    voucherText: hasRerouteContext ? formatRupiah(voucherAmount) : null,
    voucherCode: hasRerouteContext ? firstPresent(deliveryData.voucherCode, offerData.voucherCode) : null,
    offerStatus: hasActiveOffer ? offerData.status : null,
    offerReason: hasActiveOffer ? offerData.reason : null,
    etaText: firstPresent(
      deliveryData.estimatedArrivalText,
      deliveryData.estimatedArrival,
      deliveryData.eta,
      deliveryData.etaText
    ) || (normalizedDelay > 0
      ? `bertambah sekitar ${normalizedDelay} menit`
      : "sesuai jadwal, jam spesifik belum tercatat"),
    otpCode: deliveryData.otpCode,
  };
}

function buildRuleBasedChatResponse(context, userMessage) {
  const lowerMessage = String(userMessage).toLowerCase();
  const asksReroute = /(kemana|ke mana|dialihkan|alih|rute|mitra|node|lokasi)/i.test(lowerMessage);
  const asksVoucher = /(voucher|kompensasi|cashback|diskon)/i.test(lowerMessage);
  const delayText = context.delayMinutes > 0
    ? `estimasi keterlambatan sekitar ${context.delayMinutes} menit`
    : "tidak ada keterlambatan besar yang tercatat saat ini";
  const nodeText = context.selectedNodeName
    ? `${context.selectedNodeName}${context.distanceText ? ` (${context.distanceText} dari tujuan)` : ""}`
    : "mitra FlexiNode terdekat, tetapi nama node belum tercatat di sistem";
  const voucherText = context.voucherText
    ? `Kompensasi voucher ${context.voucherText}${context.voucherCode ? ` dengan kode ${context.voucherCode}` : ""} sudah terkait dengan pengalihan ini.`
    : "Detail voucher belum tercatat, jadi silakan cek notifikasi saat offer selesai diproses.";

  if (asksVoucher) {
    if (!context.hasRerouteContext) {
      return `Belum ada voucher untuk paket ${context.deliveryId} karena paket belum dialihkan ke mitra. Status paket masih on delivery dan kondisi trafik tercatat normal.`;
    }
    return `${voucherText} Paket ${context.deliveryId} ${context.selectedNodeName ? `dialihkan ke ${nodeText}` : "sedang diproses untuk rute alternatif"} karena ${delayText}.`;
  }

  if (asksReroute && !context.hasRerouteContext) {
    return `Paket ${context.deliveryId} belum dialihkan ke mitra. Statusnya masih on delivery menuju alamat penerima, kondisi trafik tercatat normal, dan ${delayText}.`;
  }

  if (asksReroute || context.status === "rerouted_to_node") {
    return `Paket ${context.deliveryId} dialihkan ke ${nodeText}. Pengalihan dilakukan karena rute awal mengalami kemacetan berat dengan ${delayText}. ${voucherText} Anda tidak perlu melakukan apa pun; driver akan melanjutkan pengiriman melalui rute alternatif.`;
  }

  return `Status paket ${context.deliveryId} saat ini adalah ${context.status}. ${context.selectedNodeName ? `Tujuan aktifnya ${nodeText}. ` : ""}${context.delayMinutes > 0 ? `Ada ${delayText}. ` : ""}${voucherText}`;
}

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

    const offersSnapshot = await db.collection('offers')
      .where('deliveryId', '==', deliveryId)
      .get();
    const offerDocs = offersSnapshot.docs.map((doc) => doc.data());
    const offerData = offerDocs.find((offer) => offer.status === "accepted")
      || offerDocs.find((offer) => offer.status === "pending")
      || null;
    const chatContext = buildChatContext(deliveryId, deliveryData || {}, offerData || {});

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
    const systemPrompt = `Anda adalah asisten AI FlexiNode untuk pelanggan last-mile delivery.
Jawab dalam Bahasa Indonesia yang ramah, jelas, dan informatif.
Aturan respons:
- Jawab inti pertanyaan di kalimat pertama.
- Jika pelanggan bertanya paket dialihkan ke mana, sebutkan nama mitra/node tujuan terlebih dahulu.
- Sertakan alasan, estimasi dampak, kompensasi voucher, dan aksi berikutnya jika datanya tersedia.
- Jangan mengarang alamat, ETA jam spesifik, nama driver, OTP, atau kode voucher. Jika belum ada data, katakan belum tercatat.
- Hindari status teknis mentah seperti "rerouted_to_node" kecuali pelanggan memintanya.
- Jika Status Teknis adalah on_delivery, Delay Kemacetan 0, dan Reroute Aktif adalah tidak, jangan menyebut ada kemacetan atau paket dialihkan.
- Buat respons singkat: 2-4 kalimat atau bullet pendek bila perlu.

Data Paket Saat Ini:
- ID Paket: ${chatContext.deliveryId}
- Status Teknis: ${chatContext.status}
- Reroute Aktif: ${chatContext.hasRerouteContext ? "ya" : "tidak"}
- Penerima: ${chatContext.receiverName}
- Alamat Penerima: ${chatContext.receiverAddress || "belum tercatat"}
- Node/Mitra Tujuan Reroute: ${chatContext.selectedNodeName || "belum tercatat"}
- Jarak Node dari Tujuan: ${chatContext.distanceText || "belum tercatat"}
- Delay Kemacetan: ${chatContext.delayMinutes} menit
- Kondisi Trafik: ${chatContext.trafficStatus || "belum tercatat"}
- Estimasi Tiba: ${chatContext.etaText}
- Voucher: ${chatContext.voucherText || "belum tercatat"}
- Kode Voucher: ${chatContext.voucherCode || "belum tercatat"}
- Status Offer: ${chatContext.offerStatus || "belum tercatat"}
- Alasan Offer: ${chatContext.offerReason || "belum tercatat"}

Riwayat Chat Terbaru:
${chatHistory}
User: ${message}
AI:`;

    let aiResponse;
    try {
      const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
      const result = await model.generateContent(systemPrompt);
      aiResponse = result.response.text();
    } catch (aiError) {
      console.error("Gemini chat fallback used:", aiError);
      aiResponse = buildRuleBasedChatResponse(chatContext, message);
    }

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
