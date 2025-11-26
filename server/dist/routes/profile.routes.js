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
    certificationStatus: zod_1.z.enum(['none', 'pending', 'verified']).optional()
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
exports.default = router;
