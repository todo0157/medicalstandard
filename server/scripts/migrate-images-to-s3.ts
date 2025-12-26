import { PrismaClient } from '@prisma/client';
import { uploadImageToS3, isS3Url } from '../src/lib/s3';
import dotenv from 'dotenv';

dotenv.config();

const prisma = new PrismaClient();

async function migrateImages() {
  console.log('🚀 Starting image migration to S3...');

  try {
    // 1. UserProfile 마이그레이션
    const profiles = await prisma.userProfile.findMany({
      where: {
        profileImageUrl: {
          not: null,
        },
      },
    });

    console.log(`Found ${profiles.length} profiles with images.`);

    let successCount = 0;
    let skipCount = 0;
    let failCount = 0;

    for (const profile of profiles) {
      if (!profile.profileImageUrl) continue;

      // 이미 S3 URL인 경우 스킵
      if (isS3Url(profile.profileImageUrl)) {
        console.log(`Skipping profile ${profile.id}: Already S3 URL`);
        skipCount++;
        continue;
      }

      // Base64 형식이 아닌 짧은 문자열 등은 스킵 (혹은 로깅)
      if (profile.profileImageUrl.length < 100 && !profile.profileImageUrl.startsWith('data:image')) {
        console.warn(`Skipping profile ${profile.id}: Invalid image data length or format`);
        failCount++;
        continue;
      }

      try {
        console.log(`Migrating profile ${profile.id}...`);
        const s3Url = await uploadImageToS3(profile.profileImageUrl, 'profiles');
        
        await prisma.userProfile.update({
          where: { id: profile.id },
          data: { profileImageUrl: s3Url },
        });

        // Doctor 테이블에도 동일한 이미지가 있다면 업데이트 (프로필과 동기화)
        // Doctor 모델은 UserProfile과 직접 연결되진 않았지만, 이름 등으로 매칭되는 경우
        // 현재 로직상 프로필 업데이트 시 닥터 정보 업데이트는 별도이므로 여기선 프로필만 처리
        // 단, Doctor 테이블에 별도로 저장된 Base64 이미지가 있을 수 있음 -> 별도 처리 필요

        successCount++;
        console.log(`✅ Migrated profile ${profile.id}`);
      } catch (error) {
        console.error(`❌ Failed to migrate profile ${profile.id}:`, error);
        failCount++;
      }
    }

    console.log(`\nUserProfile Migration Summary:`);
    console.log(`Total: ${profiles.length}`);
    console.log(`Success: ${successCount}`);
    console.log(`Skipped: ${skipCount}`);
    console.log(`Failed: ${failCount}`);

    // 2. Doctor 마이그레이션 (선택 사항: Doctor 테이블에도 imageUrl 필드가 있음)
    const doctors = await prisma.doctor.findMany({
      where: {
        imageUrl: {
          not: null,
        },
      },
    });

    console.log(`\nFound ${doctors.length} doctors with images.`);
    
    let docSuccess = 0;
    let docSkip = 0;
    let docFail = 0;

    for (const doctor of doctors) {
      if (!doctor.imageUrl) continue;

      if (isS3Url(doctor.imageUrl)) {
        docSkip++;
        continue;
      }

      if (doctor.imageUrl.length < 100 && !doctor.imageUrl.startsWith('data:image')) {
        docFail++;
        continue;
      }

      try {
        console.log(`Migrating doctor ${doctor.id} (${doctor.name})...`);
        const s3Url = await uploadImageToS3(doctor.imageUrl, 'doctors');
        
        await prisma.doctor.update({
          where: { id: doctor.id },
          data: { imageUrl: s3Url },
        });

        docSuccess++;
        console.log(`✅ Migrated doctor ${doctor.id}`);
      } catch (error) {
        console.error(`❌ Failed to migrate doctor ${doctor.id}:`, error);
        docFail++;
      }
    }

    console.log(`\nDoctor Migration Summary:`);
    console.log(`Total: ${doctors.length}`);
    console.log(`Success: ${docSuccess}`);
    console.log(`Skipped: ${docSkip}`);
    console.log(`Failed: ${docFail}`);

  } catch (error) {
    console.error('Migration failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

migrateImages();
