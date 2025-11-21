"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const config_1 = require("../config");
const profile_service_1 = require("../services/profile.service");
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
router.get('/me', async (req, res, next) => {
    try {
        const profile = await profileService.getCurrentUserProfile();
        return res.json({ data: profile });
    }
    catch (error) {
        return next(error);
    }
});
router.put('/me', async (req, res, next) => {
    try {
        const payload = profileUpdateSchema.parse(req.body);
        const updated = await profileService.updateProfile(config_1.env.DEFAULT_PROFILE_ID, payload);
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
        const payload = profileUpdateSchema.parse(req.body);
        const updated = await profileService.updateProfile(req.params.id, payload);
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
