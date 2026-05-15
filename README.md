# 🚚 FlexiNode: Smart Logistics with AI Autonomous Rerouting

FlexiNode adalah platform logistik cerdas yang menggunakan AI (Google Gemini) untuk mendeteksi kemacetan secara real-time dan secara otomatis menawarkan rute alternatif ke titik mitra (Node) terdekat dengan kompensasi voucher bagi pelanggan.

## 🏗️ Arsitektur Proyek

Proyek ini terdiri dari dua bagian utama:
1.  **Frontend (`/frontend/flexi_node`)**: Dibangun dengan Flutter Web untuk antarmuka pelacakan paket dan chatbot AI.
2.  **Backend (`/backend`)**: Node.js Express yang berjalan di Firebase Cloud Functions (v2) sebagai otak AI dan pengelola database.

### 2. Seeding Data (Opsional)
Jika database Cloud Anda masih kosong, jalankan script ini untuk mengisi data pesanan dan toko mitra awal:
```bash
node seed-cloud.js
```

---

## 🚀 Cara Menjalankan Proyek (Development)

### 1. Persiapan Backend
Buka terminal di folder `/backend`:
```bash
npm install
```
Jika ingin menjalankan secara lokal (Emulator):
```bash
npx firebase-tools emulators:start
```

### 2. Persiapan Frontend
Buka terminal di folder `/frontend/flexi_node`:
```bash
flutter pub get
```
Jalankan di browser Chrome:
```bash
flutter run -d chrome
```

---

## 📤 Cara Deploy ke Production (Cloud)

Jika Anda melakukan perubahan dan ingin meng-update server yang sedang berjalan:

### Update Backend & Aturan Database
Buka terminal di root directory:
```bash
# Deploy semua (Functions + Firestore Rules)
npx firebase-tools deploy

# Hanya deploy AI/API saja (lebih cepat)
npx firebase-tools deploy --only functions
```

---

## 🛠️ Panduan Modifikasi (Skenario)

### "Saya ingin mengubah cara AI memberikan alasan reroute..."
Edit file `backend/index.js` pada bagian `systemPrompt` (sekitar baris 360). Ubah instruksi teks di sana, lalu jalankan `firebase deploy --only functions`.

### "Saya ingin mengubah URL server dari Cloud kembali ke Lokal..."
Buka `frontend/flexi_node/lib/data/demo_delivery_store.dart`. Ubah nilai di dalam getter `_apiUrl`. Gunakan alamat `localhost` atau `127.0.0.1` yang sesuai dengan port emulator Anda.

### "Saya ingin menambah API Key Maps baru..."
1. Update `web/index.html` pada bagian `<script src="https://maps.googleapis.com/...">`.
2. Update `.vscode/launch.json` pada bagian `--dart-define=GOOGLE_ROUTES_API_KEY=...` agar debugging di VS Code tetap berjalan lancar.

---

## 🔑 Kredensial Penting
*   **Firebase Project ID**: `flexi-nodes`
*   **Backend URL**: `https://api-mw5zqvl2rq-uc.a.run.app`
*   **AI Engine**: Gemini 2.0 Flash

---
