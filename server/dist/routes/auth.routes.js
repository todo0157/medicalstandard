"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const zod_1 = require("zod");
const auth_middleware_1 = require("../middleware/auth.middleware");
const auth_service_1 = require("../services/auth.service");
const profile_service_1 = require("../services/profile.service");
const router = (0, express_1.Router)();
const authService = new auth_service_1.AuthService();
const profileService = new profile_service_1.ProfileService();
const signupSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(8).max(64),
    name: zod_1.z.string().min(1).max(50),
    age: zod_1.z.coerce.number().int().min(0).max(120).optional(),
    gender: zod_1.z.enum(["male", "female"]).optional(),
    address: zod_1.z.string().max(200).optional(),
    phoneNumber: zod_1.z
        .string()
        .regex(/^[0-9+\-]{7,20}$/)
        .optional(),
});
const loginSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(8).max(64),
});
const refreshSchema = zod_1.z.object({
    refreshToken: zod_1.z.string().min(10),
});
const kakaoSchema = zod_1.z.object({
    code: zod_1.z.string().min(5),
    redirectUri: zod_1.z.string().url().optional(),
});
router.post("/signup", async (req, res, next) => {
    try {
        const payload = signupSchema.parse(req.body);
        const result = await authService.signup(payload);
        return res.status(201).json({ data: result });
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: "입력값이 올바르지 않습니다.",
                issues: error.flatten().fieldErrors,
            });
        }
        if (error instanceof Error && error.message === "EMAIL_ALREADY_EXISTS") {
            return res.status(409).json({ message: "이미 가입된 이메일입니다." });
        }
        return next(error);
    }
});
router.post("/login", async (req, res, next) => {
    try {
        const payload = loginSchema.parse(req.body);
        const result = await authService.login(payload);
        return res.json({ data: result });
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: "입력값이 올바르지 않습니다.",
                issues: error.flatten().fieldErrors,
            });
        }
        if (error instanceof Error && error.message === "INVALID_CREDENTIALS") {
            return res.status(401).json({ message: "이메일 또는 비밀번호가 올바르지 않습니다." });
        }
        return next(error);
    }
});
router.post("/refresh", async (req, res, next) => {
    try {
        const payload = refreshSchema.parse(req.body);
        const result = await authService.rotateRefreshToken(payload.refreshToken);
        return res.json({ data: result });
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: "입력값이 올바르지 않습니다.",
                issues: error.flatten().fieldErrors,
            });
        }
        if (error instanceof Error && error.message === "INVALID_REFRESH") {
            return res.status(401).json({ message: "유효하지 않은 리프레시 토큰입니다." });
        }
        if (error instanceof Error && error.message === "EXPIRED_REFRESH") {
            return res.status(401).json({ message: "리프레시 토큰이 만료되었습니다." });
        }
        return next(error);
    }
});
router.post("/kakao", async (req, res, next) => {
    try {
        const payload = kakaoSchema.parse(req.body);
        const result = await authService.loginWithKakao({
            code: payload.code,
            redirectUri: payload.redirectUri,
        });
        return res.json({ data: result });
    }
    catch (error) {
        if (error instanceof zod_1.z.ZodError) {
            return res.status(400).json({
                message: "입력값이 올바르지 않습니다.",
                issues: error.flatten().fieldErrors,
            });
        }
        if (error instanceof Error && error.message === "KAKAO_CONFIG_MISSING") {
            return res.status(500).json({ message: "Kakao 설정이 누락되었습니다." });
        }
        if (error instanceof Error && error.message.startsWith("KAKAO_")) {
            return res.status(401).json({ message: "Kakao 인증에 실패했습니다." });
        }
        return next(error);
    }
});
router.get("/me", auth_middleware_1.authenticate, async (req, res, next) => {
    try {
        if (!req.user?.profileId) {
            return res.status(401).json({ message: "인증 정보가 없습니다." });
        }
        const profile = await profileService.getUserProfileById(req.user.profileId);
        return res.json({ data: profile });
    }
    catch (error) {
        return next(error);
    }
});
exports.default = router;
