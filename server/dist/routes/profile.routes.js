"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const profile_service_1 = require("../services/profile.service");
const router = (0, express_1.Router)();
const profileService = new profile_service_1.ProfileService();
router.get('/me', async (req, res, next) => {
    try {
        const profile = await profileService.getCurrentUserProfile();
        return res.json({ data: profile });
    }
    catch (error) {
        return next(error);
    }
});
exports.default = router;
