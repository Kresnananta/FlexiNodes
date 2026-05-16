# Troubleshooting FlexiNode

Dokumen ini berisi masalah umum yang mungkin muncul saat menjalankan FlexiNode dan cara mengatasinya.

## `FirebaseError: auth/invalid-api-key`

Penyebab umum:

- app dijalankan tanpa `--dart-define-from-file=env.local.json`;
- `FIREBASE_WEB_API_KEY` masih placeholder;
- hot restart dilakukan setelah mengubah env, padahal perlu full restart.

Solusi:

```powershell
cd C:\Projects\FlexiNode\frontend\flexi_node
flutter run -d chrome --dart-define-from-file=env.local.json
```

Jika baru mengubah `env.local.json`, hentikan proses Flutter lalu jalankan ulang.

## `Geocoding API returned REQUEST_DENIED`

Penyebab umum:

- Geocoding API belum aktif di Google Cloud;
- billing belum aktif;
- HTTP referrer belum mengizinkan `localhost` atau domain Firebase Hosting;
- `GOOGLE_MAPS_API_KEY` belum diisi atau salah.

Solusi:

1. Aktifkan Geocoding API di Google Cloud Console.
2. Pastikan billing aktif.
3. Tambahkan allowed referrer:

```text
http://localhost:*
http://127.0.0.1:*
https://flexi-nodes.web.app/*
https://flexi-nodes.firebaseapp.com/*
```

## ETA tetap `Sesuai jadwal`

Ini normal jika belum ada realtime traffic check atau Routes API key belum tersedia.

Solusi:

1. Pastikan `GOOGLE_ROUTES_API_KEY` sudah diisi.
2. Pastikan Routes API aktif.
3. Tekan tombol `Realtime Traffic` atau `Demo Traffic`.

## Maps tidak muncul di Flutter Web

Penyebab umum:

- `web/maps_config.js` belum dibuat;
- Maps JavaScript API key belum diisi;
- domain Firebase Hosting belum masuk HTTP referrer.

Solusi:

```powershell
cd C:\Projects\FlexiNode\frontend\flexi_node
Copy-Item web\maps_config.example.js web\maps_config.js
```

Isi:

```js
window.FLEXINODE_GOOGLE_MAPS_API_KEY = 'isi_key_maps_javascript';
```

## Chatbot terasa seperti template

Penyebab umum:

- frontend dibuild tanpa `FIREBASE_WEB_API_KEY` valid;
- Firestore rules belum dideploy;
- Functions belum dideploy;
- `backend/.env` belum berisi `GEMINI_API_KEY`;
- browser masih memakai cache lama.

Solusi:

```powershell
cd C:\Projects\FlexiNode
npx firebase-tools deploy --only firestore:rules,functions
```

Lalu build dan deploy ulang frontend:

```powershell
cd C:\Projects\FlexiNode\frontend\flexi_node
flutter build web --dart-define-from-file=env.local.json

cd C:\Projects\FlexiNode
npx firebase-tools deploy --only hosting
```

Jika masih sama, lakukan hard refresh `Ctrl + Shift + R` atau clear site data browser.

## Pesan chat dobel

Penyebab umum:

- browser masih menjalankan bundle lama;
- pesan lama masih tersimpan di Firestore;
- tombol submit diklik dua kali cepat.

Solusi:

1. Hard refresh `Ctrl + Shift + R`.
2. Clear site data jika perlu.
3. Reset demo dari tombol refresh di AI Chat.

## Android build gagal karena NDK

Jika muncul error:

```text
NDK ... did not have a source.properties file
```

Solusi:

1. Hapus folder NDK yang disebutkan oleh Flutter.
2. Jalankan build lagi agar Android Gradle Plugin mengunduh ulang NDK.

Contoh path:

```text
C:\Users\raina\AppData\Local\Android\sdk\ndk\28.2.13676358
```

## Secret scanning GitHub masih muncul

Jika GitHub masih menampilkan secret scanning alert, kemungkinan key pernah ada di Git history.

Solusi:

- rotate atau restrict key di Google Cloud Console;
- pastikan working tree saat ini tidak lagi memiliki literal API key;
- tutup alert GitHub setelah mitigasi dilakukan.

Scan lokal:

```powershell
rg --hidden -n "AIza[0-9A-Za-z_-]{20,}" -S . -g !.git
```
