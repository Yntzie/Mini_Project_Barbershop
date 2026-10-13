# Roadmap Pengerjaan: Reservasi Barbershop

> Asumsi: mulai **Selasa, 13 Oktober 2026**, sekitar **10-12 jam per minggu**.
> Kalau waktumu berbeda, geser tanggalnya, jangan menambah fitur.
> Centang `[x]` setiap tugas selesai dan commit file ini bersama kodenya.

## Aturan main

- [ ] Commit minimal sekali per hari kerja dengan pesan yang jelas
- [ ] Satu hari kosong per minggu sebagai buffer (jangan diisi tugas lain)
- [ ] Review tiap Minggu malam (template di bagian bawah)
- [ ] Macet lebih dari 45 menit pada satu error: tulis pertanyaan (error + yang sudah dicoba), lalu tanya
- [ ] Fitur dibekukan di akhir Minggu 5

**Tidak boleh dibuang:** anti double-booking, test, deploy, README.

**Cut-list jika tertinggal lebih dari 2 hari** (buang berurutan, jangan perpanjang jadwal):
1. Dashboard statistik
2. Booking walk-in
3. Pengingat H-1 (email konfirmasi tetap ada)
4. Opsi "kapster mana saja"

---

## Fase 1: v1.0 (target rilis 23 November 2026)

### Minggu 1 (13-19 Okt): Setup dan pemahaman

**Setup**
- [ ] Buat project Next.js, pasang dependensi
- [ ] Salin semua file fondasi backend dan UI
- [ ] Buat database Neon (satu untuk dev, satu branch untuk test)
- [ ] Isi `.env` (DATABASE_URL, DIRECT_URL, AUTH_SECRET)
- [ ] Jalankan migrasi dengan `--create-only`, tempel `exclusion.sql`, lalu migrate
- [ ] Verifikasi constraint: `SELECT conname FROM pg_constraint WHERE conname = 'no_overlapping_bookings';`
- [ ] Jalankan seed
- [ ] Push ke GitHub (repo publik, `.env` tidak ikut)

**Verifikasi**
- [ ] `npm test`: unit test slot lulus
- [ ] Test konkurensi (`booking.db.test.ts`) lulus terhadap database test
- [ ] Coba manual: daftar, login, booking, batal, lihat "Booking Saya"
- [ ] Login admin: `/admin` terbuka; login pelanggan: `/admin` ditolak
- [ ] Catat dan perbaiki semua error yang muncul

**Pemahaman**
- [ ] Baca ulang `slots.ts` dan `booking.ts` sampai bisa dijelaskan tanpa melihat kode
- [ ] Tulis 5 kalimat di catatan pribadi: kenapa exclusion constraint, bukan hanya cek di aplikasi

**Riset**
- [ ] Wawancara pemilik barbershop (15-30 menit), catat jawabannya
- [ ] Perbarui angka `[...]` di BRD dan PRD sesuai hasil wawancara

**Selesai jika:** semua test lulus dan kamu bisa menjelaskan logika slot serta constraint secara lisan.

---

### Minggu 2 (20-26 Okt): CRUD admin dan deploy pertama

**CRUD admin** (setiap server action wajib memeriksa `session.user.role === "ADMIN"`)
- [ ] Layanan: tambah, ubah, nonaktifkan
- [ ] Kapster: tambah, ubah, nonaktifkan
- [ ] Jam kerja per kapster per hari (termasuk dua jendela untuk istirahat)
- [ ] Time off kapster (cuti atau libur)
- [ ] Validasi Zod untuk semua form admin
- [ ] Test sederhana: akun pelanggan tidak bisa memanggil action admin

**Deploy**
- [ ] Deploy ke Vercel, set environment variable
- [ ] Migrasi database produksi (constraint ikut terpasang)
- [ ] Seed akun demo di produksi (hati-hati: seed menghapus data, jalankan sekali saja)
- [ ] Tes alur booking di URL publik
- [ ] Minta satu teman mencoba dan catat masukannya

**Selesai jika:** ada link publik dan admin bisa mengubah data tanpa menyentuh database langsung.

---

### Minggu 3 (27 Okt-2 Nov): Penyempurnaan alur booking

- [ ] Validasi maksimal 14 hari dan minimal jeda 1 jam di `createBooking` (server)
- [ ] Opsi "kapster mana saja" (pilih kapster kosong dengan beban paling sedikit)
- [ ] Test untuk "kapster mana saja" (termasuk saat semua penuh)
- [ ] Test kasus tepi: pergantian hari, durasi 90 menit di akhir jam kerja, time off di tengah hari
- [ ] Pertahankan pilihan wizard setelah login (query string atau penyimpanan sementara)
- [ ] GitHub Actions: jalankan lint dan test setiap push
- [ ] Tambahkan badge status CI di README

**Selesai jika:** CI hijau dan pelanggan bisa booking tanpa memilih kapster tertentu.

---

### Minggu 4 (3-9 Nov): Sisi admin dan notifikasi

- [ ] Halaman daftar booking admin dengan filter (tanggal, kapster, status)
- [ ] Tandai booking selesai atau no-show
- [ ] Booking walk-in oleh admin (memblokir slot yang sama)
- [ ] Setup Resend dan verifikasi domain/pengirim
- [ ] Email konfirmasi saat booking berhasil
- [ ] Vercel Cron: pengingat H-1 pukul 18.00 WIB
- [ ] Endpoint cron dilindungi secret
- [ ] Tes email di akun nyata (cek folder spam)

**Selesai jika:** admin bisa menjalankan satu hari operasional penuh lewat aplikasi.

---

### Minggu 5 (10-16 Nov): Dashboard dan kualitas

- [ ] Dashboard: jumlah booking, jam ramai, pendapatan per kapster, dengan filter rentang tanggal
- [ ] Rapikan tampilan mobile (uji lebar 360 px)
- [ ] State kosong, loading, dan pesan error di semua halaman
- [ ] Periksa aksesibilitas dasar: label form, fokus keyboard, kontras
- [ ] Hapus kode mati dan `console.log` sisa
- [ ] Jalankan `npm run lint` dan perbaiki semuanya
- [ ] **Bekukan fitur** (setelah ini hanya bug dan dokumentasi)

**Selesai jika:** tidak ada halaman yang rusak di ponsel dan tidak ada fitur setengah jadi.

---

### Minggu 6 (17-23 Nov): Pemolesan dan rilis

- [ ] README: deskripsi singkat, demo link, akun demo, screenshot
- [ ] GIF alur booking (pelanggan) dan alur admin
- [ ] Diagram ERD dan diagram arsitektur
- [ ] Bagian "Tantangan & solusi": double-booking, timestamptz/UTC, test konkurensi
- [ ] Bagian "Rencana pengembangan": reschedule, pembayaran, multi-cabang, chatbot AI
- [ ] Pindahkan BRD dan PRD ke `docs/` dan tautkan dari README
- [ ] Video demo 1-2 menit
- [ ] Minta satu orang yang belum pernah melihat proyek mencoba hanya dari README
- [ ] Tag rilis `v1.0`
- [ ] Tautkan proyek di CV dan LinkedIn

**Selesai jika:** orang asing bisa mencoba booking hanya dari README.

---

## Fase 2: penguatan (v1.1, target 21 Desember 2026)

### Minggu 7 (24-30 Nov): Keamanan dan kualitas
- [ ] Rate limiting pada login dan endpoint booking
- [ ] Batas maksimal 2 booking aktif per pelanggan
- [ ] Audit otorisasi: tes IDOR untuk setiap action yang memakai ID
- [ ] Test E2E Playwright: alur booking pelanggan
- [ ] Test E2E Playwright: alur admin
- [ ] Sentry untuk pelacakan error produksi
- [ ] E2E berjalan di CI

### Minggu 8 (1-7 Des): Reschedule
- [ ] Fungsi reschedule memakai aturan slot dan anti-bentrok yang sama
- [ ] Batas waktu reschedule mengikuti aturan pembatalan
- [ ] Riwayat perubahan tercatat
- [ ] Test konkurensi untuk reschedule

### Minggu 9-10 (8-21 Des): Pembayaran dan kapster berhalangan
- [ ] Integrasi Midtrans sandbox
- [ ] Status PENDING dengan `expiresAt`, cron pembatalan kedaluwarsa
- [ ] Webhook dengan verifikasi signature
- [ ] Webhook idempoten (notifikasi ganda tidak menghasilkan efek ganda) beserta tesnya
- [ ] Penanganan kapster berhalangan: daftar booking terdampak, pindahkan atau batalkan, notifikasi pelanggan
- [ ] Perbarui README dan tag rilis `v1.1`

### Minggu 11+ (opsional)
- [ ] Guest booking
- [ ] Notifikasi real-time di admin
- [ ] Multi-cabang (hanya jika semua di atas sudah rapi)

### Versi 2.0
- [ ] Chatbot AI untuk booking (tulis PRD v2.0 lebih dulu)

---

## Template review mingguan (isi tiap Minggu malam, 15 menit)

```
Minggu ke-: 
Tanggal:

Selesai:
- 

Tertinggal:
- 

Penyebab keterlambatan (jika ada):

Keputusan: [ ] lanjut sesuai jadwal  [ ] aktifkan cut-list (item: ...)

Fokus minggu depan (maks. 3 hal):
1.
2.
3.
```

## Checkpoint akhir minggu

| Minggu | Pertanyaan yang harus bisa dijawab "ya" |
|---|---|
| 1 | Bisakah saya menjelaskan constraint anti-bentrok tanpa melihat kode? |
| 2 | Apakah temanku bisa membuka link publik dan booking? |
| 4 | Bisakah admin menjalankan satu hari operasional lewat aplikasi? |
| 6 | Bisakah orang asing mencoba booking hanya dari README? |