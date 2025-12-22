const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function syncDoctorStatus() {
  try {
    // 1. none 상태이거나 한의사가 아닌 프로필 조회
    const unverifiedProfiles = await prisma.userProfile.findMany({
      where: {
        OR: [
          { certificationStatus: 'none' },
          { isPractitioner: false }
        ]
      },
      select: { name: true }
    });

    const unverifiedNames = unverifiedProfiles.map(p => p.name);
    console.log(`Unverified profile names: ${unverifiedNames.join(', ')}`);

    // 2. 해당 이름의 Doctor 레코드 비활성화
    const updateResult = await prisma.doctor.updateMany({
      where: {
        name: { in: unverifiedNames }
      },
      data: {
        isVerified: false
      }
    });

    console.log(`Successfully deactivated ${updateResult.count} doctor records.`);
    
    // 3. 결과 확인
    const doctors = await prisma.doctor.findMany({
      where: { name: '권창한' }
    });
    console.log('\n--- Status of "권창한" ---');
    doctors.forEach(d => {
      console.log(`Name: ${d.name}, isVerified: ${d.isVerified}`);
    });

  } catch (error) {
    console.error(error);
  } finally {
    await prisma.$disconnect();
  }
}

syncDoctorStatus();

