import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const email = '1234@naver.com';

  // 1. 사용자 찾기
  const user = await prisma.userAccount.findUnique({
    where: { email },
  });

  if (!user) {
    console.error(`User with email ${email} not found.`);
    return;
  }
  console.log(`Found user: ${user.id}`);

  // 2. 병원 및 의사 생성 (또는 찾기)
  let clinic = await prisma.clinic.findFirst({
    where: { name: '경희한방병원' }
  });

  if (!clinic) {
    clinic = await prisma.clinic.create({
      data: {
        name: '경희한방병원',
        address: '서울시 동대문구 경희대로 23',
        phone: '02-1234-5678',
      }
    });
    console.log('Created test clinic');
  }

  let doctor = await prisma.doctor.findFirst({
    where: { name: '김한방' }
  });

  if (!doctor) {
    doctor = await prisma.doctor.create({
      data: {
        name: '김한방',
        specialty: '침구과',
        clinicId: clinic.id,
        bio: '침구과 전문의',
      }
    });
    console.log('Created test doctor');
  }

  // 3. 진료 기록 생성
  const records = [
    {
      title: '허리 통증 침 치료',
      summary: '요추 4-5번 디스크 의심 증상으로 침 치료 및 물리치료 시행함. 3일간 무리한 운동 금지.',
      prescriptions: '갈근탕 3일분',
      createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 2), // 2일 전
    },
    {
      title: '소화불량 상담',
      summary: '과식 후 지속되는 소화불량으로 내원. 맥진 결과 위장 기능 저하 소견.',
      prescriptions: '평위산 5일분',
      createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 10), // 10일 전
    },
    {
      title: '어깨 결림 추나 요법',
      summary: '오십견 초기 증상으로 추나 요법 시행. 스트레칭 교육 완료.',
      createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 45), // 45일 전
    }
  ];

  for (const record of records) {
    await prisma.medicalRecord.create({
      data: {
        userAccountId: user.id,
        doctorId: doctor.id,
        title: record.title,
        summary: record.summary,
        prescriptions: record.prescriptions,
        createdAt: record.createdAt, // 생성일 지정
      }
    });
  }

  console.log(`Created ${records.length} medical records for user ${email}`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

