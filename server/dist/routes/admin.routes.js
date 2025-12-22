"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const auth_middleware_1 = require("../middleware/auth.middleware");
const admin_middleware_1 = require("../middleware/admin.middleware");
const profile_service_1 = require("../services/profile.service");
const prisma_1 = require("../lib/prisma");
const router = (0, express_1.Router)();
const profileService = new profile_service_1.ProfileService();
// 모든 관리자 라우트는 인증 및 관리자 권한 필요
router.use(auth_middleware_1.authenticate);
router.use(admin_middleware_1.requireAdmin);
/**
 * GET /api/admin/certifications
 * 대기 중인 한의사 인증 신청 목록 조회
 */
router.get("/certifications", async (req, res, next) => {
    try {
        const { status = "pending", page = "1", limit = "20" } = req.query;
        const pageNum = parseInt(page, 10) || 1;
        const limitNum = parseInt(limit, 10) || 20;
        const skip = (pageNum - 1) * limitNum;
        // 인증 상태 필터링
        const statusFilter = status === "all" ? undefined : status;
        const where = {};
        if (statusFilter) {
            where.certificationStatus = statusFilter;
        }
        // 인증 신청이 있는 프로필만 조회 (licenseNumber가 있거나 certificationStatus가 none이 아닌 경우)
        if (statusFilter === "pending") {
            where.certificationStatus = "pending";
        }
        const [profiles, total] = await Promise.all([
            prisma_1.prisma.userProfile.findMany({
                where,
                skip,
                take: limitNum,
                orderBy: { updatedAt: "desc" },
                include: {
                    account: {
                        select: {
                            id: true,
                            email: true,
                            createdAt: true,
                        },
                    },
                },
            }),
            prisma_1.prisma.userProfile.count({ where }),
        ]);
        return res.json({
            data: profiles.map((profile) => ({
                id: profile.id,
                name: profile.name,
                email: profile.account?.email,
                certificationStatus: profile.certificationStatus,
                isPractitioner: profile.isPractitioner,
                licenseNumber: profile.licenseNumber,
                clinicName: profile.clinicName,
                createdAt: profile.createdAt.toISOString(),
                updatedAt: profile.updatedAt.toISOString(),
            })),
            pagination: {
                page: pageNum,
                limit: limitNum,
                total,
                totalPages: Math.ceil(total / limitNum),
            },
        });
    }
    catch (error) {
        console.error("[Admin] Error fetching certifications:", error);
        return next(error);
    }
});
/**
 * GET /api/admin/certifications/:profileId
 * 특정 프로필의 인증 정보 상세 조회
 */
router.get("/certifications/:profileId", async (req, res, next) => {
    try {
        const { profileId } = req.params;
        const profile = await prisma_1.prisma.userProfile.findUnique({
            where: { id: profileId },
            include: {
                account: {
                    select: {
                        id: true,
                        email: true,
                        createdAt: true,
                    },
                },
            },
        });
        if (!profile) {
            return res.status(404).json({ message: "프로필을 찾을 수 없습니다." });
        }
        return res.json({
            data: {
                id: profile.id,
                name: profile.name,
                email: profile.account?.email,
                age: profile.age,
                gender: profile.gender,
                address: profile.address,
                phoneNumber: profile.phoneNumber,
                certificationStatus: profile.certificationStatus,
                isPractitioner: profile.isPractitioner,
                licenseNumber: profile.licenseNumber,
                clinicName: profile.clinicName,
                profileImageUrl: profile.profileImageUrl, // 자격증 이미지가 여기에 저장됨
                createdAt: profile.createdAt.toISOString(),
                updatedAt: profile.updatedAt.toISOString(),
            },
        });
    }
    catch (error) {
        console.error("[Admin] Error fetching certification detail:", error);
        return next(error);
    }
});
const approveSchema = zod_1.z.object({
    notes: zod_1.z.string().max(500).optional(), // 승인 메모
});
/**
 * POST /api/admin/certifications/:profileId/approve
 * 한의사 인증 승인
 */
router.post("/certifications/:profileId/approve", async (req, res, next) => {
    try {
        const { profileId } = req.params;
        const payload = approveSchema.parse(req.body);
        const profile = await prisma_1.prisma.userProfile.findUnique({
            where: { id: profileId },
        });
        if (!profile) {
            return res.status(404).json({ message: "프로필을 찾을 수 없습니다." });
        }
        // 인증 승인: status를 verified로, isPractitioner를 true로 변경
        // 모든 상태에서 승인 가능 (이미 승인된 경우 재승인, 거부된 경우 재승인)
        const updated = await profileService.updateProfile(profileId, {
            certificationStatus: "verified",
            isPractitioner: true,
        });
        // Doctor 테이블에 한의사 정보 추가 또는 업데이트 (강제로 처리)
        try {
            console.log(`[Admin] Starting Doctor creation/update for profile ${profileId}, name: ${profile.name}`);
            // Clinic 찾기 또는 생성
            let clinic = await prisma_1.prisma.clinic.findFirst({
                where: {
                    name: profile.clinicName || `${profile.name} 클리닉`,
                },
            });
            if (!clinic) {
                clinic = await prisma_1.prisma.clinic.create({
                    data: {
                        name: profile.clinicName || `${profile.name} 클리닉`,
                        address: profile.address,
                        lat: 0, // TODO: 주소를 기반으로 좌표 변환 필요
                        lng: 0,
                    },
                });
                console.log(`[Admin] Clinic created: ${clinic.name} (${clinic.id})`);
            }
            else {
                console.log(`[Admin] Clinic found: ${clinic.name} (${clinic.id})`);
            }
            // 이름으로 Doctor 찾기 (정확히 일치하는 경우만)
            let existingDoctor = await prisma_1.prisma.doctor.findFirst({
                where: {
                    name: profile.name,
                },
                include: {
                    clinic: true,
                },
            });
            if (!existingDoctor) {
                // Doctor 생성
                const newDoctor = await prisma_1.prisma.doctor.create({
                    data: {
                        name: profile.name,
                        specialty: "한의학", // 기본값, 추후 수정 가능
                        bio: `자격증 번호: ${profile.licenseNumber || "없음"}`,
                        imageUrl: profile.profileImageUrl || null,
                        clinicId: clinic.id,
                        isVerified: true,
                    },
                    include: {
                        clinic: true,
                    },
                });
                console.log(`[Admin] ✅ Doctor record CREATED for profile ${profileId}:`, {
                    doctorId: newDoctor.id,
                    name: newDoctor.name,
                    specialty: newDoctor.specialty,
                    clinicId: clinic.id,
                    clinicName: clinic.name,
                });
                // 생성 후 바로 조회하여 검증
                const verifyDoctor = await prisma_1.prisma.doctor.findUnique({
                    where: { id: newDoctor.id },
                    include: { clinic: true },
                });
                if (verifyDoctor) {
                    console.log(`[Admin] ✅ Doctor verification successful: ${verifyDoctor.name} exists in database`);
                }
                else {
                    console.error(`[Admin] ❌ Doctor verification FAILED: ${newDoctor.name} not found after creation!`);
                }
            }
            else {
                // 기존 Doctor가 있으면 정보 업데이트
                const updateData = {
                    clinicId: clinic.id,
                    isVerified: true,
                };
                // 이미지가 있으면 업데이트
                if (profile.profileImageUrl) {
                    updateData.imageUrl = profile.profileImageUrl;
                }
                // 자격증 번호가 있으면 bio 업데이트
                if (profile.licenseNumber) {
                    updateData.bio = `자격증 번호: ${profile.licenseNumber}`;
                }
                const updatedDoctor = await prisma_1.prisma.doctor.update({
                    where: { id: existingDoctor.id },
                    data: updateData,
                    include: {
                        clinic: true,
                    },
                });
                console.log(`[Admin] ✅ Doctor record UPDATED for profile ${profileId}:`, {
                    doctorId: updatedDoctor.id,
                    name: updatedDoctor.name,
                    clinicId: clinic.id,
                    clinicName: clinic.name,
                });
            }
            // 최종 검증: Doctor 목록에 포함되는지 확인
            const allDoctors = await prisma_1.prisma.doctor.findMany({
                where: {
                    name: profile.name,
                },
                include: {
                    clinic: true,
                },
            });
            console.log(`[Admin] Final verification: Found ${allDoctors.length} doctor(s) with name "${profile.name}"`);
            if (allDoctors.length > 0) {
                console.log(`[Admin] ✅ Doctor "${profile.name}" is in the database and will appear in the list`);
            }
            else {
                console.error(`[Admin] ❌ Doctor "${profile.name}" NOT FOUND in database after creation/update!`);
            }
        }
        catch (doctorError) {
            console.error(`[Admin] ❌ Error creating/updating doctor record for profile ${profileId}:`, doctorError);
            console.error(`[Admin] Error details:`, JSON.stringify(doctorError, null, 2));
            // Doctor 생성 실패해도 인증 승인은 완료
        }
        console.log(`[Admin] Certification approved for profile ${profileId} by admin ${req.user?.email}`);
        return res.json({
            data: updated,
            message: "인증이 승인되었습니다.",
        });
    }
    catch (error) {
        console.error("[Admin] Error approving certification:", error);
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: "입력값이 올바르지 않습니다.",
                issues: error.flatten().fieldErrors,
            });
        }
        return next(error);
    }
});
const rejectSchema = zod_1.z.object({
    reason: zod_1.z.string().min(1).max(500), // 거부 사유 (필수)
    notes: zod_1.z.string().max(500).optional(), // 추가 메모
});
/**
 * POST /api/admin/certifications/:profileId/reject
 * 한의사 인증 거부
 */
router.post("/certifications/:profileId/reject", async (req, res, next) => {
    try {
        const { profileId } = req.params;
        const payload = rejectSchema.parse(req.body);
        const profile = await prisma_1.prisma.userProfile.findUnique({
            where: { id: profileId },
        });
        if (!profile) {
            return res.status(404).json({ message: "프로필을 찾을 수 없습니다." });
        }
        // 인증 거부: status를 none으로 변경, isPractitioner는 false로 유지
        // 모든 상태에서 거부 가능 (이미 거부된 경우 재거부, 승인된 경우 거부)
        const updated = await profileService.updateProfile(profileId, {
            certificationStatus: "none",
            isPractitioner: false,
        });
        // Doctor 정보 비활성화
        try {
            await prisma_1.prisma.doctor.updateMany({
                where: { name: profile.name },
                data: { isVerified: false },
            });
            console.log(`[Admin] Doctor records for "${profile.name}" deactivated (isVerified: false)`);
        }
        catch (doctorError) {
            console.error(`[Admin] Failed to deactivate doctor records for "${profile.name}":`, doctorError);
        }
        console.log(`[Admin] Certification rejected for profile ${profileId} by admin ${req.user?.email}. Reason: ${payload.reason}`);
        return res.json({
            data: updated,
            message: "인증이 거부되었습니다.",
            reason: payload.reason,
        });
    }
    catch (error) {
        console.error("[Admin] Error rejecting certification:", error);
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: "입력값이 올바르지 않습니다.",
                issues: error.flatten().fieldErrors,
            });
        }
        return next(error);
    }
});
exports.default = router;
