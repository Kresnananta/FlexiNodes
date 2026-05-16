# FlexiNode

FlexiNode adalah aplikasi demo last-mile delivery yang membantu pengiriman tetap efisien saat terjadi kemacetan. Sistem ini mendeteksi potensi keterlambatan, menawarkan pengalihan paket ke partner node terdekat, menghitung estimasi tiba berbasis traffic, memberikan voucher kompensasi, dan menyediakan chatbot AI untuk menjawab pertanyaan pelanggan.

Demo web:

- https://flexi-nodes.web.app

## Anggota Tim

- Anak Agung Ngurah Agung Kresna Ananta
- Darren Dexter Thio

## Tujuan Program

Program ini dibuat untuk mensimulasikan solusi logistik cerdas pada skenario pengiriman jarak akhir. Fokus utamanya adalah mengurangi dampak kemacetan terhadap kurir dan pelanggan dengan cara:

- memantau status pengiriman dan estimasi keterlambatan;
- memilih partner node terdekat sebagai lokasi pickup alternatif;
- memberikan kompensasi voucher kepada pelanggan;
- membantu pelanggan memahami status paket melalui Flexi AI Agent;
- menyediakan alur QR untuk serah terima paket antara driver, mitra, dan pelanggan.

## Cara Kerja Singkat

1. Driver membawa paket menuju alamat pelanggan.
2. Sistem melakukan pengecekan traffic atau simulasi demo traffic.
3. Jika keterlambatan tinggi, Flexi AI membuat rekomendasi reroute ke partner node terdekat.
4. Pelanggan menerima tawaran pickup node dan kompensasi voucher.
5. Jika pelanggan menyetujui, rute driver berubah menuju partner node.
6. Driver menyerahkan paket ke mitra melalui QR handover.
7. Pelanggan mengambil paket di mitra menggunakan QR pickup.
8. Chatbot AI menjawab pertanyaan pelanggan berdasarkan status paket, ETA, voucher, dan keputusan reroute.

## Fitur Utama

- Live demo state untuk melihat status paket secara langsung.
- Realtime Traffic dan Demo Traffic.
- Flexi AI Agent berbasis backend AI.
- Template chat cepat di halaman AI Chat.
- Estimasi tiba berbasis data traffic.
- Reroute paket ke partner node.
- Voucher kompensasi.
- QR flow untuk driver, mitra, dan customer.
- Firebase Hosting untuk demo web.
- Firebase Auth, Firestore, dan Cloud Functions sebagai backend.

## Struktur Proyek

- `frontend/flexi_node` - aplikasi Flutter untuk web/mobile preview.
- `backend` - Express API yang berjalan di Firebase Cloud Functions v2.
- `firestore.rules` - aturan akses Firestore.
- `firebase.json` - konfigurasi Firebase Functions, Firestore, Hosting, dan Emulator.
- `TROUBLESHOOTING.md` - catatan masalah umum dan cara mengatasinya.

## Teknologi

- Flutter Web
- Firebase Hosting
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Functions v2
- Google Gemini API
- Google Maps JavaScript API
- Google Routes API
- Google Geocoding API

## Prasyarat

Pastikan perangkat memiliki:

- Flutter SDK
- Node.js LTS
- Chrome
- akses Firebase project
- Firebase CLI, dapat dijalankan melalui `npx firebase-tools`

Login Firebase:

```powershell
npx firebase-tools login
```

## Konfigurasi Lokal

API key tidak disimpan di repository. Setelah clone atau pull project, buat file konfigurasi lokal berikut.

### 1. Frontend Environment

```powershell
cd C:\Projects\FlexiNode\frontend\flexi_node
Copy-Item env.example.json env.local.json
```

Isi `env.local.json`:

```json
{
  "FIREBASE_WEB_API_KEY": "isi_firebase_web_api_key",
  "FIREBASE_ANDROID_API_KEY": "isi_firebase_android_api_key",
  "FIREBASE_APPLE_API_KEY": "isi_firebase_apple_api_key",
  "GOOGLE_MAPS_API_KEY": "isi_key_geocoding_maps",
  "GOOGLE_ROUTES_API_KEY": "isi_key_routes"
}
```

Keterangan:

- `FIREBASE_WEB_API_KEY` wajib untuk menjalankan web/Chrome.
- `FIREBASE_ANDROID_API_KEY` hanya diperlukan untuk Android.
- `FIREBASE_APPLE_API_KEY` hanya diperlukan untuk iOS/macOS.
- `GOOGLE_MAPS_API_KEY` dipakai untuk reverse geocoding.
- `GOOGLE_ROUTES_API_KEY` dipakai untuk route dan ETA.
- Jika Maps, Geocoding, dan Routes memakai satu Google API key yang sama, isi nilai yang sama pada field Google terkait.

### 2. Google Maps Script Untuk Web

```powershell
Copy-Item web\maps_config.example.js web\maps_config.js
```

Isi `web/maps_config.js`:

```js
window.FLEXINODE_GOOGLE_MAPS_API_KEY = 'isi_key_maps_javascript';
```

### 3. Backend Environment

Buat file `backend/.env`:

```env
GEMINI_API_KEY=isi_gemini_api_key
```

### 4. Firebase Android Config

Untuk menjalankan aplikasi di Android, siapkan file Firebase native:

```powershell
Copy-Item android\app\google-services.example.json android\app\google-services.json
```

Kemudian isi file `android/app/google-services.json` dengan konfigurasi asli dari Firebase Console:

1. Buka Firebase Console.
2. Pilih project `flexi-nodes`.
3. Buka Android app dengan package name `com.example.flexi_node`.
4. Download `google-services.json`.
5. Simpan file tersebut ke `frontend/flexi_node/android/app/google-services.json`.

File `env.local.json`, `web/maps_config.js`, `android/app/google-services.json`, dan `backend/.env` tidak ikut di-commit ke Git.

## Cara Menjalankan Program

### Menjalankan Frontend Web

```powershell
cd C:\Projects\FlexiNode\frontend\flexi_node
flutter pub get
flutter run -d chrome --dart-define-from-file=env.local.json
```

Jika menjalankan dari root project:

```powershell
cd C:\Projects\FlexiNode
flutter run -d chrome --dart-define-from-file=frontend/flexi_node/env.local.json
```

Catatan: setelah mengubah `env.local.json`, hentikan proses Flutter lalu jalankan ulang. Hot restart tidak cukup karena `--dart-define` dibaca saat compile.

### Menjalankan Frontend Android

Pastikan USB debugging aktif dan perangkat sudah muncul sebagai authorized:

```powershell
flutter devices
```

Untuk Google Maps native Android, set API key sebelum menjalankan app:

```powershell
$env:GOOGLE_MAPS_API_KEY="isi_key_maps_android"
flutter run -d android --dart-define-from-file=env.local.json
```

Jika menggunakan Git Bash:

```bash
export GOOGLE_MAPS_API_KEY="isi_key_maps_android"
flutter run -d android --dart-define-from-file=env.local.json
```

### Menjalankan Backend Lokal

```powershell
cd C:\Projects\FlexiNode\backend
npm install
```

Dari root project:

```powershell
cd C:\Projects\FlexiNode
npx firebase-tools emulators:start
```

Secara default frontend memakai backend cloud. Jika ingin memakai emulator lokal, ubah sementara getter `_apiUrl` di `frontend/flexi_node/lib/data/demo_delivery_store.dart` ke URL emulator yang sudah disediakan di komentar file tersebut.

## Build dan Deploy

Build Flutter Web:

```powershell
cd C:\Projects\FlexiNode\frontend\flexi_node
flutter build web --dart-define-from-file=env.local.json
```

Deploy Firebase Hosting:

```powershell
cd C:\Projects\FlexiNode
npx firebase-tools deploy --only hosting
```

Deploy backend Functions:

```powershell
cd C:\Projects\FlexiNode
npx firebase-tools deploy --only functions
```

Deploy Firestore Rules:

```powershell
npx firebase-tools deploy --only firestore:rules
```

Deploy semua layanan:

```powershell
npx firebase-tools deploy
```

## Alur Demo

1. Buka aplikasi web atau jalankan aplikasi lokal.
2. Masuk ke halaman driver, receiver, atau AI Chat sesuai skenario.
3. Tekan `Demo Traffic` untuk mensimulasikan kemacetan.
4. Buka offer pickup node dari sisi receiver.
5. Terima tawaran reroute untuk mengalihkan paket ke mitra.
6. Lihat perubahan status paket dan ETA.
7. Gunakan AI Chat untuk menanyakan status, tujuan reroute, ETA, dan voucher.
8. Jalankan QR flow untuk simulasi serah terima paket.

## Catatan Keamanan

API key asli tidak ditulis langsung di source code. Untuk menjalankan program, key disediakan melalui file lokal dan `--dart-define-from-file`.

Google API key sebaiknya dibatasi dari Google Cloud Console:

- Maps JavaScript API: batasi HTTP referrer ke domain localhost dan Firebase Hosting.
- Maps SDK for Android: batasi ke Android app `com.example.flexi_node` dan SHA-1 debug/release yang digunakan.
- Routes API: batasi penggunaan hanya ke Routes API.
- Geocoding API: batasi penggunaan hanya ke Geocoding API.

Jika satu key dipakai untuk Maps JavaScript, Routes, dan Geocoding, pastikan ketiga API tersebut diizinkan pada API restrictions.

## Dokumen Pendukung

Jika menemui masalah saat setup atau demo, lihat:

- [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
