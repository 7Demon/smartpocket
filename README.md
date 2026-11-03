# 💰 SmartPocket

> **Aplikasi Keuangan Mobile Android Sederhana, Cepat, dan 100% Offline.**

SmartPocket dirancang untuk membantu Anda mengelola keuangan harian dengan praktis tanpa ribet. Catat pemasukan & pengeluaran dalam hitungan detik, pantau arus kas melalui grafik visual, dan kejar target tabungan impian Anda secara konsisten.

---

## 📥 Download Aplikasi (APK)

Unduh versi terbaru secara langsung untuk smartphone Android Anda:

[![Download APK](https://img.shields.io/badge/Download_APK-v1.0.0-2EA44F?style=for-the-badge&logo=android&logoColor=white)](https://github.com/7Demon/smartpocket/releases/latest)

> 🔗 **Link Download Langsung**: [Download SmartPocket APK (v1.0.0)](https://github.com/7Demon/smartpocket/releases/latest/download/app-release.apk)

### 📲 Cara Memasang APK di Android:
1. Klik link download APK di atas melalui browser HP Anda.
2. Buka file `.apk` yang telah diunduh.
3. Jika muncul peringatan *"Install from unknown sources"* / *"Izinkan dari sumber ini"*, klik **Izinkan** (*Allow*).
4. Tekan tombol **Install** dan buka aplikasi SmartPocket.

---

## ✨ Fitur Utama

- ⚡ **Catat Cepat Pemasukan & Pengeluaran**: Input nominal angka terformat otomatis Rupiah (`Rp`), pilihan kategori lengkap, pemilih tanggal, dan catatan transaksi.
- 📜 **Riwayat Transaksi Interaktif**: Lihat seluruh riwayat transaksi yang tersusun rapi secara kronologis, lengkap dengan tombol filter (*Semua*, *Pemasukan*, *Pengeluaran*) serta fitur hapus transaksi.
- 🎯 **Target Tabungan (Savings Goals)**: Buat target tabungan impian (misal: Beli Laptop, Dana Liburan) dengan indikator *progress bar* dinamis dan tombol cepat untuk setor atau tarik tabungan.
- 📊 **Visualisasi Grafik Keuangan**:
  - **Bar Chart**: Perbandingan arus kas bulanan Pemasukan vs Pengeluaran.
  - **Donut / Pie Chart**: Distribusi persentase pengeluaran berdasarkan kategori beserta nominal detail.
- 🔒 **100% Offline & Privat**: Menggunakan database lokal **SQLite** (`sqflite`). Tidak ada data keuangan yang dikirim ke internet, tidak memerlukan registrasi akun, dan bebas iklan.

---

## 🛠️ Menjalankan dari Source Code

Pastikan Anda telah memasang **Flutter SDK** (v3.x+) dan **JDK 17**:

```bash
# Clone repository
git clone -b dev https://github.com/7Demon/smartpocket.git

# Masuk ke direktori
cd smartpocket

# Ambil dependencies
flutter pub get

# Jalankan pengujian
flutter test

# Jalankan aplikasi ke HP yang terhubung
flutter run
```

---

## 📄 Lisensi
Didistribusikan di bawah lisensi MIT.
