"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAdmin = requireAdmin;
const config_1 = require("../config");
const prisma_1 = require("../lib/prisma");
/**
 * 관리자 권한을 체크하는 미들웨어
 * ADMIN_EMAILS 환경변수에 설정된 이메일 주소만 접근 가능
 */
async function requireAdmin(req, res, next) {
    if (!req.user) {
        return res.status(401).json({ message: "인증이 필요합니다." });
    }
    try {
        // 관리자 이메일 목록 가져오기
        const adminEmails = (config_1.env.ADMIN_EMAILS || "")
            .split(",")
            .map((email) => email.trim().toLowerCase())
            .filter((email) => email.length > 0);
        if (adminEmails.length === 0) {
            console.warn("[Admin] ADMIN_EMAILS 환경변수가 설정되지 않았습니다.");
            return res.status(403).json({
                message: "관리자 기능이 설정되지 않았습니다.",
            });
        }
        // 현재 사용자의 이메일 확인
        const account = await prisma_1.prisma.userAccount.findUnique({
            where: { id: req.user.sub },
            select: { email: true },
        });
        if (!account) {
            return res.status(404).json({ message: "사용자를 찾을 수 없습니다." });
        }
        const userEmail = account.email.toLowerCase().trim();
        if (!adminEmails.includes(userEmail)) {
            return res.status(403).json({
                message: "관리자 권한이 필요합니다.",
            });
        }
        // 관리자 권한 확인됨
        return next();
    }
    catch (error) {
        console.error("[Admin] Error checking admin permission:", error);
        return res.status(500).json({
            message: "관리자 권한 확인 중 오류가 발생했습니다.",
        });
    }
}
