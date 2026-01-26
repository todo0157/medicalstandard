import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Checking user 1234@naver.com...');
  const user = await prisma.userAccount.findUnique({
    where: { email: '1234@naver.com' },
    include: { profile: true }
  });

  if (!user) {
    console.log('User not found.');
    return;
  }

  console.log('User found:', {
    id: user.id,
    email: user.email,
    profileId: user.profileId,
  });

  if (user.profile) {
    console.log('Profile found:', user.profile);
  } else {
    console.log('❌ Profile NOT found (linked profile is missing)');
    
    console.log('Attempting to restore profile...');
    const existingProfile = await prisma.userProfile.findUnique({
        where: { id: user.profileId }
    });

    if (!existingProfile) {
        const newProfile = await prisma.userProfile.create({
            data: {
                id: user.profileId,
                name: '테스트 유저',
                age: 30,
                address: '서울시 강남구',
                isPractitioner: false,
            }
        });
        console.log('✅ Profile restored:', newProfile);
    } else {
        console.log('Profile exists but relation failed? This should not happen if FK is correct.');
    }
  }
}

main()
  .catch((e) => console.error(e))
  .finally(async () => await prisma.$disconnect());
