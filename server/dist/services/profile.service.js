"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProfileService = void 0;
const prisma_1 = require("../lib/prisma");
const config_1 = require("../config");
class ProfileService {
    async getCurrentUserProfile(profileId) {
        const targetId = profileId || config_1.env.DEFAULT_PROFILE_ID;
        return this.getUserProfileById(targetId);
    }
    async getUserProfileById(id) {
        const profile = await prisma_1.prisma.userProfile.findUnique({ where: { id } });
        if (!profile) {
            throw new Error('요청한 프로필을 찾을 수 없습니다.');
        }
        return this.map(profile);
    }
    async updateProfile(id, data) {
        const updateData = {};
        if (typeof data.name !== 'undefined')
            updateData.name = data.name;
        if (typeof data.age !== 'undefined')
            updateData.age = data.age;
        if (typeof data.gender !== 'undefined')
            updateData.gender = data.gender;
        if (typeof data.address !== 'undefined')
            updateData.address = data.address;
        if (typeof data.profileImageUrl !== 'undefined') {
            updateData.profileImageUrl = data.profileImageUrl;
        }
        if (typeof data.phoneNumber !== 'undefined')
            updateData.phoneNumber = data.phoneNumber;
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
        const updated = await prisma_1.prisma.userProfile.update({
            where: { id },
            data: updateData,
        });
        return this.map(updated);
    }
    map(record) {
        return {
            id: record.id,
            name: record.name,
            age: record.age,
            gender: record.gender,
            address: record.address,
            profileImageUrl: record.profileImageUrl ?? undefined,
            phoneNumber: record.phoneNumber ?? undefined,
            appointmentCount: record.appointmentCount,
            treatmentCount: record.treatmentCount,
            isPractitioner: record.isPractitioner,
            certificationStatus: record.certificationStatus,
            createdAt: record.createdAt.toISOString(),
            updatedAt: record.updatedAt.toISOString()
        };
    }
}
exports.ProfileService = ProfileService;
