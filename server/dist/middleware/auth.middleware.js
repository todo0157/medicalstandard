"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authenticate = authenticate;
const config_1 = require("../config");
const auth_service_1 = require("../services/auth.service");
const authService = new auth_service_1.AuthService();
function authenticate(req, res, next) {
    const header = req.headers.authorization;
    if (!header || !header.startsWith("Bearer ")) {
        return res.status(401).json({ message: "인증 토큰이 없습니다." });
    }
    const token = header.replace("Bearer ", "").trim();
    try {
        const payload = authService.decodeToken(token);
        req.user = payload;
        return next();
    }
    catch (error) {
        if (config_1.env.NODE_ENV === "development") {
            console.error("JWT verification failed", error);
        }
        return res.status(401).json({ message: "인증에 실패했습니다." });
    }
}
