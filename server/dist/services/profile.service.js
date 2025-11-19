"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProfileService = void 0;
const mockProfile = {
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
    createdAt: new Date(Date.now() - 86400 * 365 * 1000).toISOString(),
    updatedAt: new Date().toISOString()
};
class ProfileService {
    async getCurrentUserProfile() {
        // TODO: Replace with DB query once persistence is available.
        return mockProfile;
    }
}
exports.ProfileService = ProfileService;
