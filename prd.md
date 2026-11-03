# Product Requirements Document (PRD) - Versi Simpel

## 1. Overview
* **Nama Produk**: SmartPocket
* **Platform**: Mobile Android (Flutter / Dart)
* **Penyimpanan**: 100% Offline Lokal (SQLite)
* **Format Mata Uang**: Rupiah (IDR - `Rp`)
* **Konsep Inti**: Aplikasi pencatat keuangan harian yang **ringan, cepat, dan to-the-point** tanpa menu atau konfigurasi yang membingungkan.

---

## 2. Problem & Goals
* **Problem**: Banyak aplikasi keuangan terlalu rumit, banyak menu tidak perlu, wajib registrasi/login, dan membutuhkan koneksi internet.
* **Goals**:
  * Pengguna bisa mencatat pemasukan/pengeluaran dalam 1 layar cepat (< 3 detik).
  * Saldo otomatis terhitung (Pemasukan - Pengeluaran).
  * Riwayat transaksi jelas dan mudah dihapus/diedit.
  * Target tabungan simpel dengan indikator progres visual.
  * Grafik ringkas untuk melihat perbandingan pemasukan vs pengeluaran dan kategori boros.

---

## 3. Users & Roles
* **User**: Pengguna tunggal (*single user*) pada perangkat smartphone Android masing-masing.
* **Role**: Pemilik perangkat (tanpa login/akun/password).

---

## 4. Scope

### 4.1 In-Scope (Fitur Utama)
1. **Catat Transaksi**: Form cepat untuk Pemasukan dan Pengeluaran (Nominal, Kategori, Catatan, Tanggal).
2. **Riwayat Transaksi**: Daftar transaksi terbaru, filter (Semua / Masuk / Keluar), serta tombol hapus.
3. **Target Tabungan**: Daftar impian/target tabungan (Nama target, Nominal target, Saldo terkumpul saat ini, tombol "Tambah Tabungan").
4. **Grafik & Ringkasan**:
   * Ringkasan Total Saldo, Total Pemasukan, Total Pengeluaran.
   * Grafik Pie/Donut (Pengeluaran per kategori).
   * Grafik Bar (Pemasukan vs Pengeluaran).

### 4.2 Out-of-Scope (Tidak Perlu Dibangun)
* Tidak ada login / registrasi / akun cloud.
* Tidak ada sinkronisasi multi-perangkat.
* Tidak ada integrasi SMS / bank otomatis.
* Tidak ada multi-mata uang.

---

## 5. Functional Requirements (FR)

* **FR-01: Catat Pemasukan & Pengeluaran**
  * Input nominal angka (format otomatis Rp).
  * Pilihan jenis transaksi: `Pemasukan` atau `Pengeluaran`.
  * Pilihan kategori sederhana (Contoh: Makanan, Belanja, Transportasi, Gaji, Bonus, Lainnya).
  * Pilihan tanggal (default: hari ini).
  * Catatan opsional.
* **FR-02: Riwayat Transaksi**
  * Menampilkan seluruh transaksi yang diurutkan dari tanggal terbaru.
  * Tombol filter: `Semua`, `Masuk`, `Keluar`.
  * Aksi hapus transaksi (dengan konfirmasi singkat).
* **FR-03: Target Tabungan**
  * Tambah target: Nama target (misal: "Beli HP") dan Nominal target (misal: Rp 3.000.000).
  * Update tabungan: Tombol cepat untuk menambah atau mengurangi saldo tabungan.
  * Menampilkan persentase pencapaian (contoh: `Rp 1.500.000 / Rp 3.000.000 - 50%`) dengan progress bar.
* **FR-04: Grafik & Visualisasi**
  * Diagram Donut: Persentase pengeluaran berdasarkan kategori.
  * Diagram Bar: Perbandingan Pemasukan vs Pengeluaran.

---

## 6. Non-Functional Requirements (NFR)
* **Kecepatan**: Buka aplikasi instan (< 1 detik).
* **Ukuran Ringan**: File aplikasi kecil dan hemat memori RAM (< 50MB).
* **Privasi**: Data keuangan 100% tersimpan di memori lokal HP pengguna.

---

## 7. Use Cases & User Flows

### Alur Navigasi Utama (3 Tab Sederhana):
1. **Tab 1: Beranda & Grafik**
   * Kartu Saldo (Total Saldo, Total Masuk, Total Keluar).
   * Grafik visual ringkas (Pemasukan vs Pengeluaran & Donut Kategori).
   * 3 Transaksi terakhir.
2. **Tab 2: Transaksi (Riwayat & Catat)**
   * Tombol `+ Catat Transaksi` (buka dialog / form modal cepat).
   * Daftar riwayat transaksi dengan filter (Semua, Masuk, Keluar).
3. **Tab 3: Target Tabungan**
   * Daftar target tabungan aktif dengan progress bar.
   * Tombol tambah target baru dan tombol isi saldo tabungan.

---

## 8. System Architecture

Arsitektur simpel & efisien (tanpa layer berlebihan):

```text
[UI Screens / Widgets]
         |
         v
[Database Helper (SQLite - sqflite)]
         |
         v
[smartpocket.db (Lokal di HP)]
```

* **Struktur Folder Ringkas**:
  ```text
  lib/
  ├── main.dart
  ├── db/
  │   └── database_helper.dart      (Koneksi & CRUD SQLite)
  ├── models/
  │   ├── transaction_item.dart     (Model transaksi)
  │   └── savings_goal.dart         (Model target tabungan)
  ├── screens/
  │   ├── home_screen.dart          (Tab beranda & grafik)
  │   ├── transaction_screen.dart   (Tab riwayat & catat)
  │   └── savings_screen.dart       (Tab target tabungan)
  └── widgets/
      └── transaction_dialog.dart   (Form modal input cepat)
  ```

---

## 9. Components & Data Flow

1. Pengguna mengisi form transaksi $\to$ Tekan "Simpan".
2. `DatabaseHelper.insertTransaction()` memasukkan data ke tabel `transactions`.
3. Tampilan langsung me-refresh data via `setState()` / state lokal yang simpel.

---

## 10. Database Design

Hanya menggunakan **2 tabel sederhana**:

```sql
-- 1. Tabel Transaksi
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    amount REAL NOT NULL,
    type TEXT NOT NULL, -- 'income' atau 'expense'
    category TEXT NOT NULL,
    date TEXT NOT NULL -- Format: YYYY-MM-DD
);

-- 2. Tabel Target Tabungan
CREATE TABLE savings_goals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    target_amount REAL NOT NULL,
    current_amount REAL NOT NULL DEFAULT 0
);
```

---

## 11. API / Interface Design
Tidak ada API internet. Semua operasi langsung melalui fungsi helper lokal:
* `DatabaseHelper.getTransactions()`
* `DatabaseHelper.insertTransaction(item)`
* `DatabaseHelper.deleteTransaction(id)`
* `DatabaseHelper.getSavingsGoals()`
* `DatabaseHelper.insertSavingsGoal(goal)`
* `DatabaseHelper.updateSavingsGoal(goal)`
* `DatabaseHelper.deleteSavingsGoal(id)`

---

## 12. Authentication & Authorization
* Tidak ada login / autentikasi. Aplikasi langsung siap pakai saat dibuka.

---

## 13. Security
* Menggunakan prepared statement bawaan SQLite untuk mencegah SQL injection.
* Data tersimpan di internal private storage Android.

---

## 14. Performance & Scalability
* Menggunakan query SQL standar yang langsung mengembalikan data yang diperlukan.
* Rendering grafik ringan tanpa animasi berat yang memakan baterai.

---

## 15. Reliability & Error Handling
* Validasi input: nominal tidak boleh kosong atau $\le 0$.
* Jika data kosong, tampilkan pesan ramah (*empty state*, misal: "Belum ada transaksi").

---

## 16. Deployment & Operations
* Build target: APK Android standar (`flutter build apk`).
* Tidak ada server / backend maintenance (biaya \$0).

---

## 17. Constraints & Technical Decisions
* **Kenapa SQLite (`sqflite`)?** Sangat stabil, native di Android, dan data tidak hilang saat aplikasi ditutup.
* **Kenapa arsitektur simpel?** Menghindari kerumitan *over-engineering* sesuai kebutuhan aplikasi keuangan personal.

---

## 18. Edge Cases
* **Nominal 0**: Ditolak oleh validasi form.
* **Tabungan ditarik melebihi saldo**: Tombol kurangi tabungan dibatasi agar tidak minus.
* **Belum ada transaksi untuk grafik**: Tampilkan placeholder "Belum cukup data untuk grafik".

---

## 19. Acceptance Criteria
* [ ] Pengguna bisa mencatat pemasukan & pengeluaran dengan nominal, kategori, dan tanggal.
* [ ] Saldo utama terhitung otomatis secara tepat.
* [ ] Riwayat transaksi tampil urut tanggal terbaru dan bisa dihapus.
* [ ] Pengguna bisa membuat target tabungan dan menambah uang yang terkumpul (progress bar bertambah).
* [ ] Grafik pie kategori dan bar pemasukan vs pengeluaran muncul dengan jelas.

---

## 20. TODO / Open Questions
* Tidak ada blokade. Desain sudah simpel dan langsung siap diimplementasikan.
