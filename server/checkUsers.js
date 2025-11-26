// Quick helper to inspect seeded user accounts.
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.userAccount.findMany({
    select: { email: true, provider: true },
  });
  console.log(users);
  await prisma.$disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
