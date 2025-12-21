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
