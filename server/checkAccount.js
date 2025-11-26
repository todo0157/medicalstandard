const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const user = await prisma.userAccount.findUnique({
    where: { email: 'demo@hanbang.app' },
    select: {
      email: true,
      provider: true,
      passwordHash: true,
      createdAt: true,
      updatedAt: true,
    },
  });
  console.log(user);
  await prisma.$disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
