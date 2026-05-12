const admin = require('firebase-admin');

process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';

admin.initializeApp({
  projectId: 'demo-no-project'
});

async function run() {
  await admin.firestore().collection('nodes').doc('node_001').update({
    capacity: 10
  });
  console.log('Kapasitas node_001 berhasil di-reset menjadi 10.');
}

run().catch(console.error);
