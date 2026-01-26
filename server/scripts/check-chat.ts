import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const email = '1234@naver.com';
  console.log(`Checking user ${email}...`);
  
  const user = await prisma.userAccount.findUnique({
    where: { email },
  });

  if (!user) {
    console.error('User not found');
    return;
  }
  console.log('User found:', user.id);

  console.log('Checking doctor...');
  const doctor = await prisma.doctor.findFirst();
  if (!doctor) {
    console.error('Doctor not found');
    return;
  }
  console.log('Doctor found:', { id: doctor.id, name: doctor.name });

  console.log('Creating chat session...');
  try {
    // 이미 존재하는 세션이 있는지 확인
    let session = await prisma.chatSession.findFirst({
        where: {
            userAccountId: user.id,
            doctorId: doctor.id
        }
    });

    if (session) {
        console.log('Session already exists:', session.id);
    } else {
        session = await prisma.chatSession.create({
            data: {
                userAccountId: user.id,
                doctorId: doctor.id,
                subject: '상담 요청',
            }
        });
        console.log('Session created:', session.id);
    }
  } catch (e) {
    console.error('Error creating session:', e);
  }
}

main()
  .catch((e) => console.error(e))
  .finally(async () => await prisma.$disconnect());

