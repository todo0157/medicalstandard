// Resets demo@hanbang.app password to "password123"
const bcrypt = require('bcryptjs');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const hash = await bcrypt.hash('password123', 10);
  const user = await prisma.userAccount.update({
    where: { email: 'demo@hanbang.app' },
    data: { passwordHash: hash },
    select: { email: true, provider: true, updatedAt: true },
  });
  console.log('Updated user:', user);
  await prisma.$disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
