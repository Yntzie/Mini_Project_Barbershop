-- CreateEnum
CREATE TYPE "Role" AS ENUM ('CUSTOMER', 'ADMIN');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "phone" TEXT,
    "role" "Role" NOT NULL DEFAULT 'CUSTOMER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Barber" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Barber_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Service" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "durationMin" INTEGER NOT NULL,
    "price" INTEGER NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Service_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WorkingHour" (
    "id" TEXT NOT NULL,
    "barberId" TEXT NOT NULL,
    "weekday" INTEGER NOT NULL,
    "startTime" TEXT NOT NULL,
    "endTime" TEXT NOT NULL,

    CONSTRAINT "WorkingHour_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TimeOff" (
    "id" TEXT NOT NULL,
    "barberId" TEXT NOT NULL,
    "startsAt" TIMESTAMPTZ(3) NOT NULL,
    "endsAt" TIMESTAMPTZ(3) NOT NULL,
    "reason" TEXT,

    CONSTRAINT "TimeOff_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Booking" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "barberId" TEXT NOT NULL,
    "serviceId" TEXT NOT NULL,
    "startsAt" TIMESTAMPTZ(3) NOT NULL,
    "endsAt" TIMESTAMPTZ(3) NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'CONFIRMED',
    "expiresAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Booking_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "Booking_barberId_startsAt_idx" ON "Booking"("barberId", "startsAt");

-- CreateIndex
CREATE INDEX "Booking_userId_idx" ON "Booking"("userId");

-- AddForeignKey
ALTER TABLE "WorkingHour" ADD CONSTRAINT "WorkingHour_barberId_fkey" FOREIGN KEY ("barberId") REFERENCES "Barber"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TimeOff" ADD CONSTRAINT "TimeOff_barberId_fkey" FOREIGN KEY ("barberId") REFERENCES "Barber"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_barberId_fkey" FOREIGN KEY ("barberId") REFERENCES "Barber"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- =============================================================================
-- SQL Manual: Ditambahkan secara manual sesuai AGENTS.md
-- =============================================================================

-- Aktifkan ekstensi btree_gist yang diperlukan oleh exclusion constraint.
-- Ekstensi ini memungkinkan indeks GiST pada kolom skalar (TEXT) bersama
-- tipe range (tstzrange), sehingga PostgreSQL bisa memeriksa irisan rentang
-- waktu sekaligus kesamaan barberId dalam satu constraint atomik.
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Exclusion constraint anti double-booking:
-- Menjamin tidak ada dua booking berstatus PENDING atau CONFIRMED yang
-- beririsan waktunya untuk kapster yang sama, bahkan saat ada concurrent INSERT.
-- Ini adalah lapis terakhir keamanan; pengecekan aplikasi hanyalah lapis pertama.
-- EXCLUDE USING gist: pakai indeks GiST (diaktifkan oleh btree_gist di atas)
--   "barberId" WITH =      → barberId harus sama (kapster yang sama)
--   tstzrange(...) WITH && → rentang waktu tidak boleh beririsan (overlap)
-- WHERE (status IN (...)) → hanya berlaku untuk booking aktif; CANCELLED,
--   COMPLETED, dan NO_SHOW boleh beririsan (slot sudah bebas).
ALTER TABLE "Booking"
  ADD CONSTRAINT no_overlapping_bookings
  EXCLUDE USING gist (
    "barberId" WITH =,
    tstzrange("startsAt", "endsAt") WITH &&
  )
  WHERE (status IN ('PENDING', 'CONFIRMED'));

-- Row Level Security (RLS): aktifkan untuk semua tabel aplikasi.
-- Tanpa policy, berarti TIDAK ADA akses langsung dari klien (browser, anon key).
-- Seluruh akses data hanya boleh lewat Prisma dengan service_role / connection
-- pooler yang sudah terautentikasi — sesuai arsitektur AGENTS.md.
ALTER TABLE "User"        ENABLE ROW LEVEL SECURITY;
ALTER TABLE "Barber"      ENABLE ROW LEVEL SECURITY;
ALTER TABLE "Service"     ENABLE ROW LEVEL SECURITY;
ALTER TABLE "WorkingHour" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "TimeOff"     ENABLE ROW LEVEL SECURITY;
ALTER TABLE "Booking"     ENABLE ROW LEVEL SECURITY;
