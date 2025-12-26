import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function createAdmin() {
  const email = 'thf5662@gmail.com';
  const password = 'admin123456';

  console.log(`🚀 Creating/Updating admin account: ${email}...`);

  try {
    const passwordHash = await bcrypt.hash(password, 10);

    // 1. 프로필 생성 또는 조회
    let profile = await prisma.userProfile.findFirst({
      where: { name: 'Admin' }
    });

    if (!profile) {
      profile = await prisma.userProfile.create({
        data: {
          name: 'Admin',
          age: 30,
          gender: 'male',
          address: 'Seoul',
          isPractitioner: false,
          certificationStatus: 'verified' // 관리자는 기본 인증 상태로 설정
        }
      });
    }

    // 2. 계정 생성 또는 업데이트 (Upsert)
    const account = await prisma.userAccount.upsert({
      where: { email },
      update: {
        passwordHash,
        emailVerified: true
      },
      create: {
        email,
        passwordHash,
        profileId: profile.id,
        emailVerified: true,
        provider: 'password'
      }
    });

    console.log(`✅ Admin account is ready! ID: ${account.id}`);
  } catch (error) {
    console.error('❌ Failed to create admin account:', error);
  } finally {
    await prisma.$disconnect();
  }
}

createAdmin();

