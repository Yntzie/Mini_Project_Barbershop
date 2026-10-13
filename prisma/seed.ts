// Seed data demo untuk development.
// KEAMANAN: menolak berjalan di production kecuali ALLOW_DEMO_SEED=true di-set secara eksplisit.

import { PrismaClient, BookingStatus, Role } from "@prisma/client";
import { createHash } from "crypto";

// Gunakan bcryptjs untuk hash password (cost 12 sesuai AGENTS.md).
// eslint-disable-next-line @typescript-eslint/no-require-imports
const bcrypt = require("bcryptjs") as typeof import("bcryptjs");

const prisma = new PrismaClient();

// ---------------------------------------------------------------------------
// Guard: jangan jalankan seed di production tanpa flag eksplisit
// ---------------------------------------------------------------------------
function assertNotProduction(): void {
  if (
    process.env.NODE_ENV === "production" &&
    process.env.ALLOW_DEMO_SEED !== "true"
  ) {
    console.error(
      "[seed] DITOLAK: NODE_ENV=production dan ALLOW_DEMO_SEED bukan 'true'.",
    );
    console.error(
      "[seed] Seed ini menghapus data lama. Jalankan sekali saja di production",
    );
    console.error(
      "[seed] dengan ALLOW_DEMO_SEED=true jika memang sengaja disengaja.",
    );
    process.exit(1);
  }
}

// ---------------------------------------------------------------------------
// Helper: jam kerja per kapster
// ---------------------------------------------------------------------------
type WorkingHourInput = {
  weekday: number;
  startTime: string;
  endTime: string;
};

// Senin-Sabtu (weekday 1-6), 10:00-21:00, Minggu libur
function buildDefaultHours(): WorkingHourInput[] {
  return [1, 2, 3, 4, 5, 6].map((day) => ({
    weekday: day,
    startTime: "10:00",
    endTime: "21:00",
  }));
}

// Bima: dua jendela (10:00-12:00 dan 13:00-21:00) Senin-Sabtu
function buildBimaHours(): WorkingHourInput[] {
  const hours: WorkingHourInput[] = [];
  for (const day of [1, 2, 3, 4, 5, 6]) {
    hours.push({ weekday: day, startTime: "10:00", endTime: "12:00" });
    hours.push({ weekday: day, startTime: "13:00", endTime: "21:00" });
  }
  return hours;
}

// ---------------------------------------------------------------------------
// Main seed
// ---------------------------------------------------------------------------
async function main(): Promise<void> {
  assertNotProduction();

  console.log("[seed] Memulai seed...");

  // Hapus data lama dalam urutan yang menghormati foreign key constraint
  await prisma.booking.deleteMany();
  await prisma.timeOff.deleteMany();
  await prisma.workingHour.deleteMany();
  await prisma.barber.deleteMany();
  await prisma.service.deleteMany();
  await prisma.user.deleteMany();

  console.log("[seed] Data lama dihapus.");

  // -------------------------------------------------------------------------
  // Pengguna
  // -------------------------------------------------------------------------
  const adminHash = await bcrypt.hash("Admin123!", 12);
  const userHash = await bcrypt.hash("Demo123!", 12);

  const [admin, customer] = await Promise.all([
    prisma.user.create({
      data: {
        name: "Admin Demo",
        email: "admin@demo.test",
        passwordHash: adminHash,
        role: Role.ADMIN,
      },
    }),
    prisma.user.create({
      data: {
        name: "Pelanggan Demo",
        email: "user@demo.test",
        passwordHash: userHash,
        role: Role.CUSTOMER,
      },
    }),
  ]);

  console.log(`[seed] User: ${admin.email} (ADMIN), ${customer.email} (CUSTOMER)`);

  // -------------------------------------------------------------------------
  // Layanan
  // -------------------------------------------------------------------------
  await prisma.service.createMany({
    data: [
      { name: "Potong Rambut", durationMin: 30, price: 50_000 },
      { name: "Potong + Keramas", durationMin: 45, price: 65_000 },
      { name: "Cukur Jenggot", durationMin: 20, price: 30_000 },
      { name: "Paket Komplit", durationMin: 60, price: 100_000 },
      { name: "Hair Coloring", durationMin: 90, price: 180_000 },
    ],
  });

  console.log("[seed] 5 layanan dibuat.");

  // -------------------------------------------------------------------------
  // Kapster + jam kerja
  // -------------------------------------------------------------------------
  const dedi = await prisma.barber.create({
    data: {
      name: "Dedi",
      workingHours: { create: buildDefaultHours() },
    },
  });

  const rafi = await prisma.barber.create({
    data: {
      name: "Rafi",
      workingHours: { create: buildDefaultHours() },
    },
  });

  const bima = await prisma.barber.create({
    data: {
      name: "Bima",
      // Dua jendela per hari: 10:00-12:00 dan 13:00-21:00
      workingHours: { create: buildBimaHours() },
    },
  });

  console.log(
    `[seed] Kapster: ${dedi.name}, ${rafi.name}, ${bima.name} (dengan jam kerja).`,
  );

  console.log("[seed] Seed selesai ✅");
}

main()
  .catch((e: unknown) => {
    console.error("[seed] ERROR:", e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
