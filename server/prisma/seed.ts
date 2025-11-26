import { PrismaClient } from '@prisma/client';
import { addMinutes } from 'date-fns';

const prisma = new PrismaClient();

async function main() {
  // cleanup for deterministic seed reruns
  await prisma.chatMessage.deleteMany({});
  await prisma.chatSession.deleteMany({});
  await prisma.medicalRecord.deleteMany({});

  // 기본 프로필 시드
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
      certificationStatus: 'none',
    },
  });

  const account = await prisma.userAccount.upsert({
    where: { email: 'demo@hanbang.app' },
    update: {},
    create: {
      email: 'demo@hanbang.app',
      passwordHash: '$2a$10$5bqQxzIEPow33P1mb9OLmuK24VVUqrT/SF.EuEIO7Wjt3fsBwhLQ.', // 'password123'
      provider: 'password',
      emailVerified: true,
      profileId: defaultProfile.id,
    },
  });

  // PreSignupEmailToken 예시 (사용되지 않은 토큰)
  await prisma.preSignupEmailToken.create({
    data: {
      email: 'demo@hanbang.app',
      token: 'presignup-demo-token',
      expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      used: false,
    },
  });

  // 클리닉/의사/슬롯 시드 (좌표 포함)
  const clinic = await prisma.clinic.upsert({
    where: { id: 'clinic_001' },
    update: {
      name: '한방의료원',
      address: '서울특별시 강남구 테헤란로 123',
      lat: 37.498095,
      lng: 127.02761,
      phone: '02-123-4567',
    },
    create: {
      id: 'clinic_001',
      name: '한방의료원',
      address: '서울특별시 강남구 테헤란로 123',
      lat: 37.498095,
      lng: 127.02761,
      phone: '02-123-4567',
    },
  });

  const doctor = await prisma.doctor.upsert({
    where: { id: 'doctor_001' },
    update: {
      name: '이길환 한의사',
      specialty: '침과 / 통증',
      bio: '10년 경력의 통증 클리닉 전문 한의사입니다.',
      imageUrl: 'https://readdy.ai/api/search-image?query=doctor',
      clinicId: clinic.id,
    },
    create: {
      id: 'doctor_001',
      name: '이길환 한의사',
      specialty: '침과 / 통증',
      bio: '10년 경력의 통증 클리닉 전문 한의사입니다.',
      imageUrl: 'https://readdy.ai/api/search-image?query=doctor',
      clinicId: clinic.id,
    },
  });

  // 오늘 기준 슬롯 생성
  const now = new Date();
  const base = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 14, 0, 0);
  const slots = [0, 30, 60, 90, 120].map((m, idx) => ({
    id: `slot_${idx + 1}`,
    doctorId: doctor.id,
    startsAt: addMinutes(base, m),
    endsAt: addMinutes(base, m + 25),
    isBooked: false,
  }));

  for (const slot of slots) {
    await prisma.slot.upsert({
      where: { id: slot.id },
      update: { startsAt: slot.startsAt, endsAt: slot.endsAt, isBooked: slot.isBooked },
      create: slot,
    });
  }

  // 기본 채팅 세션/메시지
  const chatSession = await prisma.chatSession.upsert({
    where: { id: 'chat_001' },
    update: {},
    create: {
      id: 'chat_001',
      userAccountId: account.id,
      doctorId: doctor.id,
      subject: '방문 진료 상담',
    },
  });

  await prisma.chatMessage.createMany({
    data: [
      {
        id: 'chat_msg_001',
        sessionId: chatSession.id,
        sender: 'doctor',
        content: '방문 예정 시간과 증상을 알려주시면 빠르게 안내드릴게요.',
        createdAt: addMinutes(now, -30),
      },
      {
        id: 'chat_msg_002',
        sessionId: chatSession.id,
        sender: 'user',
        content: '어깨 통증으로 방문 진료 받고 싶어요.',
        createdAt: addMinutes(now, -28),
      },
    ],
  });

  // 기본 진료 기록
  await prisma.medicalRecord.upsert({
    where: { id: 'record_001' },
    update: {},
    create: {
      id: 'record_001',
      userAccountId: account.id,
      doctorId: doctor.id,
      title: '한방 침 치료',
      summary: '좌측 어깨 근막통증 증후군으로 침 치료 및 한약 처방',
      prescriptions: '청파전 3일분, 온열 찜질 하루 2회',
      createdAt: addMinutes(now, -60 * 24 * 5),
    },
  });
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
