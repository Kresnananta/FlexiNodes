# FlexiNode

FlexiNode adalah demo platform last-mile delivery yang memakai AI untuk mendeteksi kemacetan, menawarkan reroute ke partner node terdekat, menghitung ETA berbasis traffic, menerbitkan voucher kompensasi, dan membantu pelanggan lewat chatbot Flexi AI.

## Struktur Proyek

- `frontend/flexi_node` - Flutter app untuk web/mobile preview.
- `backend` - Express API di Firebase Cloud Functions v2.
- `firestore.rules` - aturan akses Firestore.
- `firebase.json` - konfigurasi Functions, Firestore, dan emulator.

## Prasyarat

Install tool berikut:

- Flutter SDK
- Node.js LTS
- Firebase CLI, bisa via `npx firebase-tools`
- Chrome untuk preview Flutter Web

Login Firebase jika ingin memakai project cloud:

```powershell
npx firebase-tools login
```

## Secret Lokal

API key tidak disimpan di GitHub. Setelah pull repo, buat file lokal berikut.

### 1. Frontend Dart Defines

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

Catatan:
- `FIREBASE_WEB_API_KEY` diperlukan untuk menjalankan app web dengan Firebase.
- `GOOGLE_MAPS_API_KEY` dipakai untuk reverse geocoding.
- `GOOGLE_ROUTES_API_KEY` dipakai untuk route/ETA traffic.

### 2. Google Maps Script Untuk Web

```powershell
Copy-Item web\maps_config.example.js web\maps_config.js
```

Isi `web/maps_config.js`:

```js
window.FLEXINODE_GOOGLE_MAPS_API_KEY = 'isi_key_maps_javascript';
```

File `env.local.json` dan `web/maps_config.js` sudah di-ignore Git.

### 3. Backend Gemini Key

Buat `backend/.env`:

```env
GEMINI_API_KEY=isi_gemini_api_key
```

`backend/.env` juga sudah di-ignore Git.

## Menjalankan Frontend

```powershell
cd C:\Projects\FlexiNode\frontend\flexi_node
flutter pub get
flutter run -d chrome --dart-define-from-file=env.local.json
```

Kalau memakai VS Code, konfigurasi `.vscode/launch.json` membaca environment variables. Pastikan variable berikut tersedia di terminal/OS:

- `FIREBASE_WEB_API_KEY`
- `FIREBASE_ANDROID_API_KEY`
- `GOOGLE_MAPS_API_KEY`
- `GOOGLE_ROUTES_API_KEY`

## Menjalankan Backend Lokal

```powershell
cd C:\Projects\FlexiNode\backend
npm install
```

Dari root project:

```powershell
cd C:\Projects\FlexiNode
npx firebase-tools emulators:start
```

Jika ingin frontend memakai emulator, ubah sementara getter `_apiUrl` di `frontend/flexi_node/lib/data/demo_delivery_store.dart` ke URL emulator yang sudah disediakan di komentar file tersebut.

## Seeding Data

Jika Firestore cloud masih kosong:

```powershell
cd C:\Projects\FlexiNode\backend
node seed-cloud.js
```

Pastikan kredensial Firebase Admin sudah benar sebelum menjalankan script seed.

## Build Web

```powershell
cd C:\Projects\FlexiNode\frontend\flexi_node
flutter build web --dart-define-from-file=env.local.json
```

## Deploy

Deploy backend/functions:

```powershell
cd C:\Projects\FlexiNode
npx firebase-tools deploy --only functions
```

Deploy Firestore rules:

```powershell
npx firebase-tools deploy --only firestore:rules
```

Deploy frontend hosting setelah `flutter build web`:

```powershell
npx firebase-tools deploy --only hosting
```

Deploy semuanya:

```powershell
npx firebase-tools deploy
```

## API Key Dan Keamanan

Jangan commit API key asli ke repo. Gunakan file lokal dan `--dart-define-from-file`.

Key yang perlu dibatasi di Google Cloud:

- Maps JavaScript API key: batasi HTTP referrer ke `localhost`, `127.0.0.1`, dan domain Firebase Hosting.
- Routes API key: batasi API restriction ke Routes API.
- Geocoding API key: batasi API restriction ke Geocoding API.
- Firebase client keys: boleh ada di client app secara konsep, tetapi tetap wajib didukung Firestore Rules/Auth Rules yang aman.

Jika GitHub Secret Scanning pernah mendeteksi key, rotate atau restrict key tersebut di Google Cloud Console.

## Troubleshooting

### `Geocoding API returned REQUEST_DENIED`

Biasanya karena Geocoding API belum aktif, billing belum aktif, HTTP referrer belum mengizinkan `localhost`, atau `GOOGLE_MAPS_API_KEY` belum diisi.

### ETA tetap `Sesuai jadwal`

Ini normal jika belum ada realtime traffic check atau Routes API key belum tersedia. Tekan `Realtime Traffic` setelah `GOOGLE_ROUTES_API_KEY` valid.

### Maps tidak muncul di Flutter Web

Pastikan `web/maps_config.js` ada dan berisi `window.FLEXINODE_GOOGLE_MAPS_API_KEY`.

### Android build gagal karena NDK

Jika muncul pesan `NDK ... did not have a source.properties file`, hapus folder NDK yang disebutkan oleh Flutter lalu biarkan Android Gradle Plugin mengunduh ulang.

## Alur Demo Cepat

1. Jalankan frontend di Chrome.
2. Masuk sebagai driver/receiver sesuai skenario.
3. Buka AI Chat atau tracking.
4. Tekan `Demo Traffic` untuk membuat delay.
5. Buka offer dan accept pickup node.
6. Cek AI Chat untuk pertanyaan ETA, voucher, dan tujuan reroute.
7. Gunakan QR flow untuk simulasi handover driver, mitra, dan customer.
