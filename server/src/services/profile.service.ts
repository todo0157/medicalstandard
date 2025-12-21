import type { Prisma, UserProfile as PrismaUserProfile } from '@prisma/client';
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
    try {
      const updateData: Prisma.UserProfileUpdateInput = {};
      if (typeof data.name !== 'undefined') updateData.name = data.name;
      if (typeof data.age !== 'undefined') updateData.age = data.age;
      if (typeof data.gender !== 'undefined') updateData.gender = data.gender;
      if (typeof data.address !== 'undefined') updateData.address = data.address;
      if (typeof data.profileImageUrl !== 'undefined') {
        updateData.profileImageUrl = data.profileImageUrl;
      }
      if (typeof data.phoneNumber !== 'undefined') updateData.phoneNumber = data.phoneNumber;
      if (typeof data.appointmentCount !== 'undefined') {
        updateData.appointmentCount = data.appointmentCount;
      }
      if (typeof data.treatmentCount !== 'undefined') {
        updateData.treatmentCount = data.treatmentCount;
      }
      if (typeof data.isPractitioner !== 'undefined') {
        updateData.isPractitioner = data.isPractitioner;
      }
      if (typeof data.certificationStatus !== 'undefined') {
        updateData.certificationStatus = data.certificationStatus;
      }
      if (typeof data.licenseNumber !== 'undefined') {
        updateData.licenseNumber = data.licenseNumber;
      }
      if (typeof data.clinicName !== 'undefined') {
        updateData.clinicName = data.clinicName;
      }

      console.log('[ProfileService] Updating profile:', { id, updateData });

      const updated = await prisma.userProfile.update({
        where: { id },
        data: updateData,
      });

      return this.map(updated);
    } catch (error) {
      console.error('[ProfileService] Update error:', error);
      throw error;
    }
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
      licenseNumber: record.licenseNumber ?? undefined,
      clinicName: record.clinicName ?? undefined,
      createdAt: record.createdAt.toISOString(),
      updatedAt: record.updatedAt.toISOString()
    };
  }
}
