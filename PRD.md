# Product Requirements Document (PRD)
## Sistem Reservasi Barbershop

| | |
|---|---|
| **Versi** | 1.0 (Draft) |
| **Tanggal** | 2 Oktober 2026 |
| **Penulis** | [Nama kamu] |
| **Dokumen terkait** | BRD-Reservasi-Barbershop.md |

---

## 1. Ringkasan Produk

Aplikasi web yang memungkinkan pelanggan memesan layanan barbershop secara online dengan memilih layanan, kapster, dan slot waktu yang tersedia. Admin mengelola jadwal dan data master, sedangkan sistem menjamin tidak ada reservasi yang bentrok.

**Visi:** reservasi barbershop semudah memesan tiket, tanpa perlu chat dan menunggu balasan.

## 2. Tujuan dan Non-Tujuan

**Tujuan**
- Pelanggan menyelesaikan reservasi dalam kurang dari 2 menit.
- Nol kasus double-booking.
- Mengurangi no-show lewat pengingat otomatis.
- Admin melihat jadwal harian dalam satu layar.

**Non-tujuan (versi 1)**
- Aplikasi mobile native, program loyalitas, manajemen stok.
- Chatbot AI untuk booking (direncanakan untuk versi berikutnya, lihat bagian 12).

## 3. Persona

| Persona | Deskripsi | Kebutuhan |
|---|---|---|
| **Raka, 22, mahasiswa** | Pelanggan, memakai HP, tidak suka antre | Lihat slot kosong cepat, booking tanpa chat |
| **Bang Dedi, 35, admin/kasir** | Mengelola jadwal harian | Melihat siapa datang jam berapa, input walk-in |
| **Pak Hendra, 45, pemilik** | Ingin memahami bisnisnya | Jam ramai, pendapatan, performa kapster |

## 4. User Stories dan Kriteria Penerimaan

### Epic A: Akun
| ID | User story | Kriteria penerimaan | Prioritas |
|---|---|---|---|
| A1 | Sebagai pelanggan, saya ingin mendaftar dan login agar reservasi saya tersimpan | Email unik; password minimal 8 karakter; error jelas jika gagal | Must |
| A2 | Sebagai admin, saya ingin akses khusus agar data tidak dapat diubah pelanggan | Halaman `/admin` menolak akun non-admin dengan 403/redirect | Must |

### Epic B: Reservasi (pelanggan)
| ID | User story | Kriteria penerimaan | Prioritas |
|---|---|---|---|
| B1 | Sebagai pelanggan, saya ingin memilih layanan agar tahu durasi dan harganya | Daftar layanan menampilkan nama, durasi, harga | Must |
| B2 | Saya ingin memilih kapster atau "siapa saja" | Pilihan "siapa saja" otomatis menetapkan kapster yang kosong | Should |
| B3 | Saya ingin melihat slot kosong pada tanggal tertentu | Slot hanya muncul dalam jam kerja, di luar libur, muat untuk durasi layanan, dan belum lewat | Must |
| B4 | Saya ingin mengonfirmasi reservasi | Reservasi tersimpan dengan status PENDING/CONFIRMED; ringkasan ditampilkan | Must |
| B5 | Jika slot diambil orang lain, saya diberi tahu | Pesan "Slot baru saja diambil" dan daftar slot diperbarui | Must |
| B6 | Saya ingin melihat dan membatalkan reservasi | Pembatalan diizinkan sampai [2] jam sebelum jadwal; di luar itu ditolak dengan alasan | Must |
| B7 | Saya ingin menerima email konfirmasi dan pengingat | Email konfirmasi saat sukses; pengingat H-1 pukul [18.00] WIB | Should |

### Epic C: Admin
| ID | User story | Kriteria penerimaan | Prioritas |
|---|---|---|---|
| C1 | Sebagai admin, saya ingin mengelola layanan | CRUD; layanan nonaktif tidak tampil ke pelanggan | Must |
| C2 | Saya ingin mengelola kapster dan jam kerjanya | CRUD kapster; jam kerja per hari; time off/libur | Must |
| C3 | Saya ingin melihat daftar dan kalender booking | Filter tanggal, kapster, dan status | Must |
| C4 | Saya ingin menandai booking selesai atau no-show | Perubahan status tercatat | Should |
| C5 | Saya ingin input walk-in | Walk-in memblokir slot yang sama seperti booking online | Should |
| C6 | Saya ingin melihat statistik | Jumlah booking, jam ramai, pendapatan per kapster pada rentang tanggal | Could |

### Epic D: Penguatan (Fase 2)
| ID | User story | Kriteria penerimaan | Prioritas |
|---|---|---|---|
| D1 | Sebagai sistem, saya harus mengamankan akses agar data pengguna terlindungi | Rate limiting pada login dan endpoint booking; otorisasi server memastikan pelanggan hanya dapat mengakses dan membatalkan booking miliknya (tes IDOR lulus); batas maksimal [2] booking aktif per pelanggan | Must |
| D2 | Sebagai pelanggan, saya ingin mengganti jadwal tanpa membatalkan | Reschedule memakai aturan slot dan anti-bentrok yang sama; batas waktu mengikuti aturan pembatalan; riwayat perubahan tercatat | Should |
| D3 | Sebagai pelanggan, saya ingin membayar DP/penuh secara online | Integrasi Midtrans sandbox; status booking berubah lewat webhook; webhook idempoten (notifikasi ganda tidak menghasilkan efek ganda); verifikasi signature | Should |
| D4 | Sebagai admin, saya ingin menangani kapster yang berhalangan mendadak | Sistem menampilkan booking terdampak; admin dapat memindahkan ke kapster lain atau membatalkan; pelanggan menerima notifikasi | Should |
| D5 | Sebagai tim, kami ingin kualitas terjaga | Test E2E Playwright untuk alur booking utama dan alur admin; pelacakan error produksi (Sentry); berjalan di CI | Should |
| D6 | Sebagai pelanggan, saya ingin booking tanpa membuat akun | Guest booking dengan nama, email, dan nomor telepon; tautan kelola/batal dikirim via email dengan token aman | Could |
| D7 | Sebagai admin, saya ingin booking baru muncul tanpa refresh | Pembaruan real-time (SSE/polling terkontrol) pada daftar booking admin | Could |
| D8 | Sebagai pemilik, saya ingin mengelola lebih dari satu cabang | Entitas cabang/tenant; data kapster, layanan, dan booking terisolasi per cabang; admin dibatasi per cabang | Could (stretch) |

## 5. Alur Pengguna

**Alur booking pelanggan**
`Pilih layanan` → `Pilih kapster` → `Pilih tanggal` → `Pilih slot` → `Login/daftar (jika perlu)` → `Konfirmasi` → `Halaman sukses + email`

**Status booking**
`PENDING` → `CONFIRMED` → `COMPLETED`
`PENDING/CONFIRMED` → `CANCELLED`
`CONFIRMED` → `NO_SHOW`

## 6. Daftar Halaman

| Rute | Akses | Isi |
|---|---|---|
| `/` | Publik | Landing, layanan unggulan, tombol "Booking" |
| `/services` | Publik | Daftar layanan dan harga |
| `/book` | Publik (login saat konfirmasi) | Wizard booking |
| `/login`, `/register` | Publik | Autentikasi |
| `/my-bookings` | Pelanggan | Riwayat dan pembatalan |
| `/admin` | Admin | Ringkasan hari ini dan statistik |
| `/admin/bookings` | Admin | Daftar/kalender booking, walk-in |
| `/admin/barbers` | Admin | Kelola kapster, jam kerja, time off |
| `/admin/services` | Admin | Kelola layanan |

## 7. Spesifikasi Logika Inti

### 7.1 Perhitungan slot
Input: tanggal, kapster (atau semua), durasi layanan.

1. Ambil jam kerja kapster pada hari tersebut.
2. Kurangi dengan booking aktif (PENDING, CONFIRMED) dan time off.
3. Pecah sisa waktu menjadi slot per [30] menit.
4. Buang slot yang tidak muat untuk durasi layanan dan slot yang sudah lewat (dengan jeda minimal [60] menit dari sekarang).
5. Untuk "siapa saja": gabungkan slot semua kapster aktif; saat konfirmasi, pilih kapster yang kosong (aturan tie-break: beban booking hari itu paling sedikit).

### 7.2 Anti double-booking
- Dijaga di level database dengan exclusion constraint PostgreSQL pada `barberId` dan rentang `startsAt-endsAt` untuk status aktif.
- Aplikasi menangkap error pelanggaran constraint dan menampilkan pesan ramah.
- Wajib ada test yang mengirim request paralel ke slot yang sama dan memastikan hanya satu yang berhasil.

### 7.3 Zona waktu
Simpan sebagai `timestamptz` (UTC), tampilkan dalam `Asia/Jakarta`.

### 7.4 Kedaluwarsa
Cron berjalan tiap [5] menit, mengubah booking PENDING yang melewati `expiresAt` menjadi CANCELLED.

## 8. Kebutuhan Non-Fungsional

| Aspek | Target |
|---|---|
| Kinerja | Pengambilan slot di bawah 500 ms (server), halaman termuat di bawah 2 detik |
| Keamanan | Password hash (bcrypt/argon2), validasi Zod di server, proteksi rute admin, rate limit pada login dan booking |
| Aksesibilitas | Kontras memadai, navigasi keyboard pada wizard, label form jelas |
| Responsif | Prioritas tampilan mobile (lebar 360 px ke atas) |
| Kualitas | Unit test logika slot, test konkurensi, CI pada setiap pull request |
| Observabilitas | Log error server, pesan error terstruktur |

## 9. Model Data (ringkas)

Entitas: `User`, `Barber`, `Service`, `WorkingHour`, `TimeOff`, `Booking`.
Relasi utama: satu `Booking` terhubung ke satu `User`, `Barber`, dan `Service`. Skema lengkap ada di `prisma/schema.prisma`.

## 10. Arsitektur dan Teknologi

| Lapisan | Pilihan |
|---|---|
| Framework | Next.js (App Router) + TypeScript |
| Database | PostgreSQL (Neon/Supabase) + Prisma |
| Auth | Auth.js |
| UI | Tailwind CSS + shadcn/ui |
| Validasi | Zod |
| Email | Resend |
| Job terjadwal | Vercel Cron |
| Test | Vitest |
| CI/CD | GitHub Actions + Vercel |

## 11. Metrik Keberhasilan

| Metrik | Target |
|---|---|
| Waktu menyelesaikan booking | Di bawah 2 menit (uji dengan [5] orang) |
| Kasus double-booking | 0 pada test konkurensi dan penggunaan nyata |
| Tingkat penyelesaian wizard | Di atas [70]% dari yang memulai |
| No-show | Turun dibanding sebelum aplikasi |
| Cakupan test logika inti | Di atas [80]% |

## 12. Rencana Rilis

| Milestone | Cakupan | Minggu |
|---|---|---|
| M1 | Setup, seed data, auth, role | 1-2 |
| M2 | CRUD admin, logika slot + test | 2-3 |
| M3 | Wizard booking, anti-bentrok, "Booking Saya" | 3-4 |
| M4 | Email, walk-in, cron kedaluwarsa | 4-5 |
| M5 | Dashboard, deploy, CI, README, demo (**rilis v1.0**) | 5-6 |
| M6 | D1 keamanan (rate limit, otorisasi), D5 test E2E + Sentry | 7 |
| M7 | D2 reschedule, D4 kapster berhalangan, D3 pembayaran + webhook (**rilis v1.1**) | 8-10 |
| M8 | D6 guest booking, D7 real-time, D8 multi-cabang (opsional, kerjakan sesuai sisa waktu) | 11+ |

**Roadmap versi berikutnya (v2.0): Chatbot AI Booking**
Pelanggan memesan lewat bahasa natural, misalnya "Besok sore potong rambut sama Bang Dedi". Chatbot memanggil fungsi yang sama dengan wizard booking (cek slot, buat booking) sehingga aturan bisnis dan anti-bentrok tetap satu sumber kebenaran. Pertimbangan awal: batasi chatbot hanya untuk aksi booking, validasi semua output model di server, dan siapkan fallback ke wizard biasa. Detail kebutuhan akan ditulis pada PRD v2.0.

**Catatan:** v1.0 sengaja dirilis dulu dan di-deploy sebelum M6 dimulai, agar portofolio sudah bisa dilihat meskipun fase berikutnya belum selesai.

## 13. Risiko dan Pertanyaan Terbuka

| Item | Catatan / keputusan |
|---|---|
| Interval slot 15 atau 30 menit? | Putuskan setelah bicara dengan pemilik |
| Apakah wajib login sebelum melihat slot? | Disarankan tidak; login saat konfirmasi |
| Perlu DP/pembayaran online? | Masuk Fase 2 (D3), memakai Midtrans sandbox |
| Chatbot AI booking | Ditunda ke v2.0; putuskan model dan penyedia saat PRD v2.0 ditulis |
| Multi-cabang (D8) | Berisiko memperbesar scope; kerjakan hanya jika D1-D5 sudah selesai |
| Notifikasi WhatsApp? | Di luar versi 1; email dulu |
| Batas booking per pelanggan per hari? | Usul: maksimal [2] aktif |
| Batas gratis layanan cloud | Pantau penggunaan database dan email |

## 14. Lampiran

- BRD: `docs/BRD.md`
- ERD dan diagram arsitektur: `docs/diagrams/` *(buat setelah skema final)*
- Wireframe: [tautan Figma/sketsa]