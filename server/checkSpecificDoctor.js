const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkDoctorStatus() {
  try {
    const doctors = await prisma.doctor.findMany({
      include: { clinic: true }
    });
    
    console.log('--- Doctor Table ---');
    doctors.forEach(d => {
      console.log(`ID: ${d.id}, Name: ${d.name}, isVerified: ${d.isVerified}, Clinic: ${d.clinic?.name}`);
    });

    const profiles = await prisma.userProfile.findMany({
      where: { name: { in: doctors.map(d => d.name) } }
    });

    console.log('\n--- Associated UserProfiles ---');
    profiles.forEach(p => {
      console.log(`Name: ${p.name}, Status: ${p.certificationStatus}, isPractitioner: ${p.isPractitioner}`);
    });
  } catch (error) {
    console.error(error);
  } finally {
    await prisma.$disconnect();
  }
}

checkDoctorStatus();

