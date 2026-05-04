# Flexi Node - Agentic AI Context

## Tujuan Utama
Mengatasi masalah *operational drag* pada *last-mile delivery* akibat kemacetan perkotaan, yang dapat menunda puluhan paket dan menyedot hingga 53% dari total biaya operasional pengiriman.

## Solusi (Flexi Nodes)
Modul ekstensi cerdas (SDK/API) bernama **Urban Nodes** yang disuntikkan ke dalam aplikasi logistik *mobile*. Solusi ini mengubah hambatan lalu lintas menjadi titik distribusi adaptif.

## Peran Agentic AI (Gemini)
Gemini AI bertindak sebagai agen otonom yang mengambil alih kendali rute statis:
- **Predictive Sensing:** Secara *real-time* memonitor pergerakan kurir dan mengevaluasi rute.
- **Cost of Delay Kalkulasi:** Menghitung *Cost of Delay* (biaya bensin + waktu akibat macet).
- **Intervensi Otonom:** Jika *Cost of Delay* melampaui ambang batas toleransi, AI melakukan intervensi dengan mencari dan merekomendasikan mitra penitipan terdekat (minimarket/warung) dalam radius <100 meter dari lokasi konsumen.
- **Negosiasi:** Mengajukan *Opt-in Micro-Incentive* (contoh: *Cashback* Rp 5.000) kepada pelanggan agar bersedia mengambil paket di *node* tersebut.

## Metrik Kunci
- **Cost of Delay:** Metrik kerugian operasional yang menentukan ambang batas intervensi AI.
- **Micro-Incentive:** Kompensasi instan untuk pelanggan yang lebih murah dibandingkan membiarkan satu kurir terjebak selama 45 menit (berpotensi menunda 10 paket lain).

---

## Detail Teknis Agentic AI dan Arsitektur

Sistem menggunakan arsitektur *cloud-native* dengan Google Tech Stack untuk latensi rendah.

### Core Tech Stack
| Komponen | Teknologi | Peran Kontekstual untuk Agentic AI |
| :--- | :--- | :--- |
| **Agentic Brain** | Gemini 1.5 Flash API | Melakukan *reasoning* (membandingkan kerugian macet vs. kompensasi) dan memicu *Function Calling* untuk mencari *node* alternatif. |
| **Geospatial Engine** | Google Maps Platform (Routes & Places API) | Menyediakan data *real-time traffic* dan menghitung *Distance Matrix* secara instan. Parameter dinamis ini diproses oleh AI untuk keputusan intervensi. |
| **Backend & Database**| Firebase (Cloud Functions & Firestore) | Sinkronisasi koordinat *real-time*, mengelola status serah terima, dan sebagai pemicu (trigger) alur kerja. |
| **Keamanan** | Cryptographic OTP Handover | Mekanisme keamanan untuk serah terima paket yang divalidasi oleh kasir mitra. |
| **Frontend** | Flutter | Antarmuka *mobile* kurir dan pengguna untuk visualisasi peta interaktif dan notifikasi persetujuan. |

### Alur Kerja Sistem Agentic (System Flow)
1. **Trigger:** Firebase mendeteksi kurir terjebak macet (menggunakan Routes API).
2. **Reasoning:** Gemini menghitung efisiensi berdasarkan *Cost of Delay* dan menyetujui pengalihan rute.
3. **Action:** Firestore mengirim *Push Notification* (FCM) berisi penawaran kompensasi ke pelanggan.
4. **Execution:** Jika pelanggan setuju, rute kurir diubah seketika di aplikasi, dan OTP dikirimkan ke kasir mitra untuk serah-terima.
