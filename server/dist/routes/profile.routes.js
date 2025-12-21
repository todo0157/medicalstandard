"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const profile_service_1 = require("../services/profile.service");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = (0, express_1.Router)();
const profileService = new profile_service_1.ProfileService();
const profileUpdateSchema = zod_1.z.object({
    name: zod_1.z.string().min(1).max(50),
    age: zod_1.z.coerce.number().int().min(0).max(120),
    gender: zod_1.z.enum(['male', 'female']),
    address: zod_1.z.string().min(1).max(120),
    profileImageUrl: zod_1.z
        .union([zod_1.z.string().url().min(1), zod_1.z.literal('')])
        .optional()
        .transform((value) => (value === '' ? undefined : value)),
    phoneNumber: zod_1.z
        .union([
        zod_1.z
            .string()
            .regex(/^[0-9+\-]{7,20}$/)
            .min(7)
            .max(20),
        zod_1.z.literal('')
    ])
        .optional()
        .transform((value) => (value === '' ? undefined : value)),
    appointmentCount: zod_1.z.coerce.number().int().min(0).optional(),
    treatmentCount: zod_1.z.coerce.number().int().min(0).optional(),
    isPractitioner: zod_1.z.coerce.boolean().optional(),
    certificationStatus: zod_1.z.enum(['none', 'pending', 'verified']).optional(),
    licenseNumber: zod_1.z.string().max(50).optional(),
    clinicName: zod_1.z.string().max(100).optional()
});
router.use(auth_middleware_1.authenticate);
router.get('/me', async (req, res, next) => {
    try {
        const profileId = req.user?.profileId;
        if (!profileId) {
            return res.status(401).json({ message: '인증 정보가 없습니다.' });
        }
        const profile = await profileService.getCurrentUserProfile(profileId);
        return res.json({ data: profile });
    }
    catch (error) {
        return next(error);
    }
});
router.put('/me', async (req, res, next) => {
    try {
        const profileId = req.user?.profileId;
        if (!profileId) {
            return res.status(401).json({ message: '인증 정보가 없습니다.' });
        }
        const payload = profileUpdateSchema.parse(req.body);
        const updated = await profileService.updateProfile(profileId, payload);
        return res.json({ data: updated });
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: '입력값이 올바르지 않습니다.',
                issues: error.flatten().fieldErrors
            });
        }
        return next(error);
    }
});
router.put('/:id', async (req, res, next) => {
    try {
        const profileId = req.user?.profileId;
        if (!profileId) {
            return res.status(401).json({ message: '인증 정보가 없습니다.' });
        }
        if (req.params.id !== profileId) {
            return res.status(403).json({ message: '자신의 프로필만 수정할 수 있습니다.' });
        }
        const payload = profileUpdateSchema.parse(req.body);
        const updated = await profileService.updateProfile(profileId, payload);
        return res.json({ data: updated });
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: '입력값이 올바르지 않습니다.',
                issues: error.flatten().fieldErrors
            });
        }
        return next(error);
    }
});
const photoSchema = zod_1.z.object({
    imageData: zod_1.z.string().min(32),
    fileName: zod_1.z.string().max(200).optional(),
});
router.post('/:id/photo', async (req, res, next) => {
    try {
        const profileId = req.user?.profileId;
        if (!profileId || profileId !== req.params.id) {
            return res.status(403).json({ message: '자신의 프로필 사진만 변경할 수 있습니다.' });
        }
        const payload = photoSchema.parse(req.body);
        const imageData = payload.imageData.replace(/\s/g, '');
        // 이미지 크기 체크 (약 10MB 제한)
        if (imageData.length > 10 * 1024 * 1024) {
            return res.status(400).json({
                message: '이미지 크기가 너무 큽니다. 10MB 이하의 이미지를 선택해주세요.',
            });
        }
        const extension = payload.fileName?.split('.').pop()?.toLowerCase() ?? 'png';
        const allowed = new Set(['png', 'jpg', 'jpeg', 'webp']);
        const normalized = allowed.has(extension) ? extension : 'png';
        const mime = normalized === 'jpg' ? 'jpeg' : normalized;
        const dataUrl = `data:image/${mime};base64,${imageData}`;
        const updated = await profileService.updateProfile(profileId, {
            profileImageUrl: dataUrl,
        });
        return res.json({ data: updated });
    }
    catch (error) {
        console.error('[Profile Photo Upload] Error:', error);
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: '입력값이 올바르지 않습니다.',
                issues: error.flatten().fieldErrors,
            });
        }
        return next(error);
    }
});
const certificationSchema = zod_1.z.object({
    status: zod_1.z.enum(['none', 'pending', 'verified']),
    isPractitioner: zod_1.z.boolean().optional(),
    licenseNumber: zod_1.z.string().max(50).optional(),
    clinicName: zod_1.z.string().max(100).optional(),
});
router.post('/:id/certification', async (req, res, next) => {
    try {
        const profileId = req.user?.profileId;
        if (!profileId || profileId !== req.params.id) {
            return res.status(403).json({ message: '자신의 프로필만 인증 상태를 변경할 수 있습니다.' });
        }
        const payload = certificationSchema.parse(req.body);
        console.log('[Certification Update] Request:', {
            profileId,
            status: payload.status,
            licenseNumber: payload.licenseNumber,
            clinicName: payload.clinicName,
        });
        const updated = await profileService.updateProfile(profileId, {
            certificationStatus: payload.status,
            isPractitioner: payload.isPractitioner ?? payload.status === 'verified',
            licenseNumber: payload.licenseNumber,
            clinicName: payload.clinicName,
        });
        return res.json({ data: updated });
    }
    catch (error) {
        console.error('[Certification Update] Error:', error);
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: '입력값이 올바르지 않습니다.',
                issues: error.flatten().fieldErrors,
            });
        }
        return next(error);
    }
});
exports.default = router;
