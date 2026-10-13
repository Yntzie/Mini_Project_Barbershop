// Singleton PrismaClient yang aman untuk hot reload Next.js.
// Next.js dev mode membuat ulang module di setiap perubahan; tanpa global cache,
// setiap reload akan membuka koneksi baru dan menguras connection pool.
// Solusi: simpan instance di `globalThis` yang tidak di-reset saat hot reload.

import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log:
      process.env.NODE_ENV === "development"
        ? ["query", "error", "warn"]
        : ["error"],
  });

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}
