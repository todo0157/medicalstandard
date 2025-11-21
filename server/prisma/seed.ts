import { PrismaClient } from '@prisma/client';
import { addMinutes } from 'date-fns';

const prisma = new PrismaClient();

async function main() {
  // 기본 프로필/계정이 이미 존재하면 스킵
  const defaultProfile = await prisma.userProfile.upsert({
    where: { id: 'user_123' },
    update: {},
    create: {
      id: 'user_123',
      name: '김민수',
      age: 34,
      gender: 'male',
      address: '경기도 성남시 분당구 불정로 6',
      profileImageUrl: 'https://readdy.ai/api/images/user/doctor_male_1.jpg',
      phoneNumber: '010-1234-5678',
      appointmentCount: 12,
      treatmentCount: 8,
      isPractitioner: false,
      certificationStatus: 'none'
    }
  });

  await prisma.userAccount.upsert({
    where: { email: 'demo@hanbang.app' },
    update: {},
    create: {
      email: 'demo@hanbang.app',
      passwordHash: '$2a$10$5bqQxzIEPow33P1mb9OLmuK24VVUqrT/SF.EuEIO7Wjt3fsBwhLQ.', // 'password123'
      provider: 'password',
      profileId: defaultProfile.id
    }
  });

  // 클리닉/의사/슬롯 시드
  const clinic = await prisma.clinic.upsert({
    where: { id: 'clinic_001' },
    update: {},
    create: {
      id: 'clinic_001',
      name: '한방의료의원',
      address: '서울특별시 강남구 테헤란로 123',
      phone: '02-123-4567'
    }
  });

  const doctor = await prisma.doctor.upsert({
    where: { id: 'doctor_001' },
    update: {},
    create: {
      id: 'doctor_001',
      name: '홍길동 한의사',
      specialty: '내과 / 통증',
      bio: '10년 경력의 통증 클리닉 전문 한의사',
      imageUrl: 'https://readdy.ai/api/search-image?query=doctor',
      clinicId: clinic.id
    }
  });

  // 오늘 기준 슬롯 생성
  const now = new Date();
  const base = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 14, 0, 0);
  const slots = [0, 30, 60, 90, 120].map((m, idx) => ({
    id: `slot_${idx + 1}`,
    doctorId: doctor.id,
    startsAt: addMinutes(base, m),
    endsAt: addMinutes(base, m + 25),
    isBooked: false
  }));

  for (const slot of slots) {
    await prisma.slot.upsert({
      where: { id: slot.id },
      update: { startsAt: slot.startsAt, endsAt: slot.endsAt, isBooked: slot.isBooked },
      create: slot
    });
  }
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error('Failed to seed database', error);
    await prisma.$disconnect();
    process.exit(1);
  });
