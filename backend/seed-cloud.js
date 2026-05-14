const admin = require('firebase-admin');

// Inisialisasi tanpa kunci manual (menggunakan kredensial lokal dari firebase login)
// Karena kita akan menjalankan ini dari laptop untuk mengisi data di cloud.
admin.initializeApp({
  projectId: 'flexi-nodes'
});

const db = admin.firestore();

async function seed() {
  console.log('🚀 Memulai Seeding ke Cloud Firestore...');

  try {
    // 1. Seed Deliveries
    const deliveryRef = db.collection('deliveries').doc('paket_001');
    await deliveryRef.set({
      orderId: 'SD-1001',
      status: 'on_delivery',
      receiverName: 'Andika Sujanto',
      receiverId: 'demo_user_123',
      targetLocation: new admin.firestore.GeoPoint(-7.2815, 112.7525), // Surabaya Area
      delayMinutes: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log('✅ Data Delivery berhasil dibuat.');

    // 2. Seed Nodes (Toko Mitra)
    const nodes = [
      {
        id: 'node_001',
        name: 'Indomaret Ahmad Yani',
        location: new admin.firestore.GeoPoint(-7.2812, 112.7521),
        capacity: '10',
        available: true
      },
      {
        id: 'node_002',
        name: 'Alfamart Gayungan',
        location: new admin.firestore.GeoPoint(-7.2900, 112.7500),
        capacity: '5',
        available: true
      }
    ];

    for (const node of nodes) {
      await db.collection('nodes').doc(node.id).set(node);
    }
    console.log('✅ Data Nodes (Toko Mitra) berhasil dibuat.');

    console.log('\n✨ SEEDING SELESAI! Database Cloud Anda sudah siap digunakan.');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error saat seeding:', error);
    process.exit(1);
  }
}

seed();
