"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProfileService = void 0;
const prisma_1 = require("../lib/prisma");
const config_1 = require("../config");
class ProfileService {
    async getCurrentUserProfile() {
        return this.getUserProfileById(config_1.env.DEFAULT_PROFILE_ID);
    }
    async getUserProfileById(id) {
        const profile = await prisma_1.prisma.userProfile.findUnique({ where: { id } });
        if (!profile) {
            throw new Error('요청한 프로필을 찾을 수 없습니다.');
        }
        return this.map(profile);
    }
    async updateProfile(id, data) {
        const updated = await prisma_1.prisma.userProfile.update({
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
