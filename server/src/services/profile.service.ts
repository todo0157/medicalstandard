import type { UserProfile as PrismaUserProfile } from '@prisma/client';
import { prisma } from '../lib/prisma';
import { env } from '../config';
import type { UserProfile } from '../types/userProfile';

export class ProfileService {
  async getCurrentUserProfile(profileId: string): Promise<UserProfile> {
    const targetId = profileId || env.DEFAULT_PROFILE_ID;
    return this.getUserProfileById(targetId);
  }

  async getUserProfileById(id: string): Promise<UserProfile> {
    const profile = await prisma.userProfile.findUnique({ where: { id } });

    if (!profile) {
      throw new Error('요청한 프로필을 찾을 수 없습니다.');
    }

    return this.map(profile);
  }

  async updateProfile(id: string, data: Partial<UserProfile>): Promise<UserProfile> {
    const updated = await prisma.userProfile.update({
      where: { id },
      data: {
        name: data.name,
        age: data.age,
        gender: data.gender,
        address: data.address,
        profileImageUrl: data.profileImageUrl,
        phoneNumber: data.phoneNumber,
        appointmentCount: data.appointmentCount,
        treatmentCount: data.treatmentCount,
        isPractitioner: data.isPractitioner,
        certificationStatus: data.certificationStatus
      }
    });

    return this.map(updated);
  }

  private map(record: PrismaUserProfile): UserProfile {
    return {
      id: record.id,
      name: record.name,
      age: record.age,
      gender: record.gender as UserProfile['gender'],
      address: record.address,
      profileImageUrl: record.profileImageUrl ?? undefined,
      phoneNumber: record.phoneNumber ?? undefined,
      appointmentCount: record.appointmentCount,
      treatmentCount: record.treatmentCount,
      isPractitioner: record.isPractitioner,
      certificationStatus: record.certificationStatus as UserProfile['certificationStatus'],
      createdAt: record.createdAt.toISOString(),
      updatedAt: record.updatedAt.toISOString()
    };
  }
}
