# Business Requirements Document (BRD)
## Sistem Reservasi Barbershop

| | |
|---|---|
| **Versi** | 1.0 (Draft) |
| **Tanggal** | 2 Oktober 2026 |
| **Penulis** | [Nama kamu] |
| **Status** | Draft untuk pengembangan MVP |

> Catatan: bagian bertanda `[...]` perlu kamu sesuaikan, idealnya setelah wawancara singkat dengan pemilik barbershop sungguhan.

---

## 1. Ringkasan Eksekutif

Barbershop [Nama Barbershop] saat ini menerima reservasi lewat chat WhatsApp dan antrean langsung. Cara ini menimbulkan jadwal bentrok, pelanggan yang tidak datang tanpa kabar, dan waktu admin yang habis untuk membalas chat. Proyek ini membangun aplikasi web reservasi online yang menampilkan slot kosong secara real-time, mencegah bentrok jadwal, dan memberi pemilik gambaran operasional lewat dashboard.

## 2. Latar Belakang dan Masalah

| # | Masalah | Dampak |
|---|---|---|
| 1 | Reservasi manual via chat | Admin sibuk membalas, respons lambat, pelanggan pindah ke tempat lain |
| 2 | Jadwal bentrok (double-booking) | Pelanggan menunggu lama atau kecewa |
| 3 | Pelanggan tidak datang (no-show) | Slot kapster kosong dan pendapatan hilang |
| 4 | Tidak ada data jam ramai dan performa | Pemilik sulit mengatur jadwal kapster |

## 3. Tujuan Bisnis dan Indikator Keberhasilan

| Tujuan | Indikator (KPI) | Target |
|---|---|---|
| Mengurangi beban admin | Waktu admin untuk mengurus reservasi | Turun [50]% |
| Menghilangkan bentrok jadwal | Jumlah kasus double-booking | 0 |
| Menekan no-show | Persentase no-show | Turun [30]% lewat pengingat otomatis |
| Memudahkan pelanggan | Reservasi selesai kurang dari 2 menit | Tercapai pada uji pengguna |
| Memberi insight bisnis | Pemilik memakai dashboard | Dipakai minimal [1x/minggu] |

## 4. Ruang Lingkup

**Termasuk (in scope)**
- Registrasi, login, dan manajemen peran (pelanggan, admin)
- Pemilihan layanan, kapster, tanggal, dan slot waktu
- Pembuatan, pembatalan, dan riwayat reservasi
- Pencegahan bentrok jadwal
- Pengelolaan layanan, kapster, jam kerja, dan hari libur oleh admin
- Reservasi walk-in oleh admin
- Notifikasi email (konfirmasi dan pengingat H-1)
- Dashboard statistik dasar

**Tidak termasuk (out of scope) pada versi 1**
- Aplikasi mobile native
- Program loyalitas dan voucher
- Manajemen stok produk dan penggajian
- Chatbot AI untuk booking *(direncanakan untuk versi 2.0)*

**Termasuk pada fase penguatan (setelah MVP)**
- Keamanan (rate limiting, otorisasi), reschedule, penanganan kapster berhalangan
- Pembayaran online via Midtrans sandbox
- Test end-to-end dan pemantauan error
- Guest booking, notifikasi real-time, dan multi-cabang *(opsional)*

## 5. Pemangku Kepentingan dan Pengguna

| Peran | Kebutuhan utama |
|---|---|
| **Pelanggan** | Booking cepat tanpa chat, tahu slot yang tersedia, bisa membatalkan |
| **Admin/Kasir** | Melihat jadwal hari ini, input walk-in, mengelola data master |
| **Pemilik** | Memantau jam ramai, pendapatan, dan performa kapster |
| **Kapster** | Mengetahui jadwal harian mereka |

## 6. Kebutuhan Bisnis (Business Requirements)

| ID | Kebutuhan | Prioritas |
|---|---|---|
| BR-01 | Pelanggan dapat membuat reservasi online 24 jam | Must |
| BR-02 | Sistem tidak boleh mengizinkan dua reservasi aktif yang beririsan untuk satu kapster | Must |
| BR-03 | Pelanggan dapat memilih kapster tertentu atau "siapa saja" | Should |
| BR-04 | Admin dapat mengatur layanan, durasi, harga, jam kerja, dan hari libur | Must |
| BR-05 | Pelanggan dan admin dapat membatalkan reservasi sesuai aturan pembatalan | Must |
| BR-06 | Pelanggan menerima konfirmasi dan pengingat otomatis | Should |
| BR-07 | Admin dapat memasukkan reservasi walk-in | Should |
| BR-08 | Pemilik dapat melihat statistik jam ramai dan pendapatan per kapster | Could |
| BR-09 | Reservasi yang belum dikonfirmasi/dibayar kedaluwarsa otomatis | Could |

*Prioritas mengikuti MoSCoW: Must, Should, Could, Won't.*

## 7. Kebutuhan Fungsional Ringkas

| ID | Fungsi | Terkait |
|---|---|---|
| FR-01 | Registrasi dan login (email/password) dengan peran | BR-01, BR-04 |
| FR-02 | Perhitungan slot kosong berdasarkan jam kerja, booking, libur, dan durasi layanan | BR-01, BR-02 |
| FR-03 | Wizard booking: layanan, kapster, tanggal, slot, konfirmasi | BR-01, BR-03 |
| FR-04 | Constraint database untuk mencegah rentang waktu beririsan | BR-02 |
| FR-05 | Halaman "Booking Saya" dengan fitur batal | BR-05 |
| FR-06 | CRUD layanan, kapster, jam kerja, dan time off | BR-04 |
| FR-07 | Kirim email konfirmasi dan pengingat H-1 | BR-06 |
| FR-08 | Input walk-in oleh admin | BR-07 |
| FR-09 | Dashboard: jumlah booking, jam ramai, pendapatan | BR-08 |
| FR-10 | Job terjadwal untuk membatalkan booking kedaluwarsa | BR-09 |

## 8. Kebutuhan Non-Fungsional

| Aspek | Kebutuhan |
|---|---|
| **Kinerja** | Halaman slot termuat di bawah 2 detik pada koneksi normal |
| **Keamanan** | Password di-hash, validasi input di server, akses admin dilindungi middleware |
| **Keandalan** | Tidak ada double-booking walau terjadi request bersamaan |
| **Zona waktu** | Waktu disimpan dalam UTC, ditampilkan dalam WIB |
| **Kegunaan** | Responsif untuk ponsel, karena mayoritas pelanggan memakai HP |
| **Pemeliharaan** | Logika inti punya unit test, ada CI otomatis |
| **Privasi** | Data pribadi pelanggan hanya dipakai untuk reservasi |

## 9. Aturan Bisnis

- Satu kapster tidak boleh punya dua reservasi aktif pada rentang waktu yang sama.
- Slot ditampilkan per [30] menit dan harus muat untuk durasi layanan.
- Reservasi hanya dapat dibuat maksimal [14] hari ke depan dan minimal [1] jam sebelum mulai.
- Pembatalan oleh pelanggan diizinkan sampai [2] jam sebelum jadwal.
- Reservasi PENDING yang tidak dikonfirmasi dalam [15] menit dibatalkan otomatis.
- Pelanggan dengan no-show berulang ([3x]) dapat dibatasi oleh admin.

## 10. Alur Utama

1. Pelanggan membuka situs dan memilih layanan.
2. Pelanggan memilih kapster atau "siapa saja".
3. Sistem menampilkan slot kosong pada tanggal yang dipilih.
4. Pelanggan memilih slot dan mengonfirmasi (login jika belum).
5. Sistem menyimpan reservasi. Jika slot baru saja diambil orang lain, pelanggan diminta memilih slot lain.
6. Pelanggan menerima email konfirmasi, lalu pengingat H-1.
7. Admin melihat jadwal harian dan menandai reservasi sebagai selesai atau no-show.

## 11. Asumsi, Batasan, dan Risiko

**Asumsi**
- Pelanggan memiliki email aktif dan akses internet.
- Barbershop memiliki satu lokasi dengan jam kerja yang tetap per kapster.

**Batasan**
- Proyek dikerjakan perorangan dalam sekitar 4-6 minggu.
- Memakai layanan gratis (Vercel, Neon/Supabase, Resend tier gratis).

| Risiko | Mitigasi |
|---|---|
| Request bersamaan menyebabkan double-booking | Exclusion constraint di PostgreSQL dan test konkurensi |
| Pelanggan kurang terbiasa memakai aplikasi | UI sederhana, alur maksimal 4 langkah |
| Scope melebar | Pegang daftar in/out of scope, tunda fitur Could |
| Email masuk spam | Gunakan domain terverifikasi di Resend |

## 12. Rencana Rilis

| Fase | Isi | Estimasi |
|---|---|---|
| MVP | Auth, CRUD admin, slot, booking, anti-bentrok, pembatalan | Minggu 1-3 |
| Rilis 1 | Notifikasi email, walk-in, cron kedaluwarsa | Minggu 4 |
| Rilis 2 | Dashboard statistik, deploy, CI/CD, dokumentasi | Minggu 5-6 |
| Penguatan | Keamanan, E2E test, reschedule, pembayaran, kapster berhalangan | Minggu 7-10 |
| Opsional | Guest booking, real-time, multi-cabang | Minggu 11+ |
| Versi 2.0 | Chatbot AI untuk booking | Setelah v1.x stabil |

## 13. Kriteria Penerimaan (Acceptance Criteria)

- [ ] Pelanggan dapat menyelesaikan reservasi dari awal sampai akhir dalam kurang dari 2 menit.
- [ ] Dua request bersamaan ke slot yang sama menghasilkan tepat satu reservasi berhasil.
- [ ] Slot di luar jam kerja, hari libur, dan waktu yang sudah lewat tidak tampil.
- [ ] Pembatalan di luar batas waktu ditolak dengan pesan yang jelas.
- [ ] Email konfirmasi terkirim setelah reservasi berhasil.
- [ ] Halaman admin tidak dapat diakses oleh akun pelanggan.
- [ ] Seluruh unit test logika slot dan test konkurensi lulus di CI.

## 14. Glosarium

| Istilah | Arti |
|---|---|
| **Slot** | Rentang waktu yang dapat dipesan |
| **Double-booking** | Dua reservasi pada kapster dan waktu yang beririsan |
| **No-show** | Pelanggan tidak datang tanpa membatalkan |
| **Walk-in** | Pelanggan yang datang langsung tanpa reservasi online |
| **MVP** | Versi minimum yang sudah bisa dipakai |