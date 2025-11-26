"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const client_1 = require("@prisma/client");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const crypto_1 = require("crypto");
const config_1 = require("../config");
const prisma_1 = require("../lib/prisma");
const token_service_1 = require("./token.service");
const mailer_service_1 = require("./mailer.service");
const SALT_ROUNDS = 10;
const REFRESH_TTL_DAYS = 14;
const KAKAO_TOKEN_URL = "https://kauth.kakao.com/oauth/token";
const KAKAO_ME_URL = "https://kapi.kakao.com/v2/user/me";
class AuthService {
    async signup(input) {
        const email = input.email.toLowerCase().trim();
        const passwordHash = await bcryptjs_1.default.hash(input.password, SALT_ROUNDS);
        const cleanedAddress = input.address?.trim() ?? "";
        const cleanedPhone = input.phoneNumber?.trim() ?? "";
        // (옵션) precheck 토큰 검증은 라우트에서 처리하거나 여기에서 처리할 수 있습니다.
        try {
            const profile = await prisma_1.prisma.userProfile.create({
                data: {
                    name: input.name.trim(),
                    age: input.age ?? 0,
                    gender: input.gender ?? "male",
                    address: cleanedAddress.length === 0 ? "미입력" : cleanedAddress,
                    phoneNumber: cleanedPhone.length === 0 ? undefined : cleanedPhone,
                },
            });
            const account = await prisma_1.prisma.userAccount.create({
                data: {
                    email,
                    passwordHash,
                    provider: "password",
                    profileId: profile.id,
                },
            });
            const tokens = await this.issueTokens({
                accountId: account.id,
                profileId: profile.id,
                provider: account.provider,
                email: account.email,
            });
            return {
                ...tokens,
                profile: this.toProfile(profile),
            };
        }
        catch (error) {
            if (error instanceof client_1.Prisma.PrismaClientKnownRequestError &&
                error.code === "P2002") {
                throw new Error("EMAIL_ALREADY_EXISTS");
            }
            throw error;
        }
    }
    async login(input) {
        const account = await prisma_1.prisma.userAccount.findUnique({
            where: { email: input.email.toLowerCase().trim() },
            include: { profile: true },
        });
        if (!account || !(await bcryptjs_1.default.compare(input.password, account.passwordHash))) {
            throw new Error("INVALID_CREDENTIALS");
        }
        const profile = account.profile;
        const tokens = await this.issueTokens({
            accountId: account.id,
            profileId: profile.id,
            provider: account.provider,
            email: account.email,
        });
        return {
            ...tokens,
            profile: this.toProfile(profile),
        };
    }
    async sendVerificationEmail(accountId, email) {
        if (!config_1.env.VERIFY_LINK_BASE)
            return;
        const { token } = await (0, token_service_1.issueEmailVerificationToken)(accountId);
        const link = `${config_1.env.VERIFY_LINK_BASE}?token=${token}`;
        await (0, mailer_service_1.sendMail)({
            to: email,
            subject: "이메일 인증을 완료해 주세요",
            html: `<p>이메일 인증을 완료하려면 아래 링크를 클릭하세요.</p><p><a href="${link}">${link}</a></p>`,
            text: `이메일 인증 링크: ${link}`,
        });
    }
    async markEmailVerified(accountId) {
        await prisma_1.prisma.userAccount.update({
            where: { id: accountId },
            data: { emailVerified: true },
        });
    }
    decodeToken(token) {
        const payload = jsonwebtoken_1.default.verify(token, config_1.env.JWT_SECRET);
        return payload;
    }
    async loginWithKakao(params) {
        if (!config_1.env.KAKAO_REST_API_KEY) {
            throw new Error("KAKAO_CONFIG_MISSING");
        }
        const redirectUri = params.redirectUri ?? config_1.env.KAKAO_REDIRECT_URI;
        if (!redirectUri) {
            throw new Error("KAKAO_CONFIG_MISSING");
        }
        const tokenRes = await fetch(KAKAO_TOKEN_URL, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: new URLSearchParams({
                grant_type: "authorization_code",
                client_id: config_1.env.KAKAO_REST_API_KEY,
                redirect_uri: redirectUri,
                code: params.code,
                ...(config_1.env.KAKAO_CLIENT_SECRET ? { client_secret: config_1.env.KAKAO_CLIENT_SECRET } : {}),
            }),
        });
        if (!tokenRes.ok) {
            const txt = await tokenRes.text();
            throw new Error(`KAKAO_TOKEN_FAILED: ${txt}`);
        }
        const tokenJson = (await tokenRes.json());
        if (!tokenJson.access_token)
            throw new Error("KAKAO_TOKEN_MISSING");
        const meRes = await fetch(KAKAO_ME_URL, {
            headers: { Authorization: `Bearer ${tokenJson.access_token}` },
        });
        if (!meRes.ok) {
            const txt = await meRes.text();
            throw new Error(`KAKAO_ME_FAILED: ${txt}`);
        }
        const me = await meRes.json();
        const kakaoId = me.id?.toString();
        if (!kakaoId)
            throw new Error("KAKAO_ID_MISSING");
        const kakaoAccount = me.kakao_account ?? {};
        const profileInfo = kakaoAccount.profile ?? {};
        const email = kakaoAccount.email ??
            kakaoAccount.email_needs_agreement ? undefined : undefined;
        const mappedEmail = email ?? `${kakaoId}@kakao.local`;
        const displayName = profileInfo.nickname ?? "카카오 사용자";
        // find or create
        let account = await prisma_1.prisma.userAccount.findFirst({
            where: { OR: [{ kakaoId }, { email: mappedEmail }] },
            include: { profile: true },
        });
        if (!account) {
            const profile = await prisma_1.prisma.userProfile.create({
                data: {
                    name: displayName,
                    age: 0,
                    gender: "male",
                    address: "카카오 로그인",
                },
            });
            const dummyHash = await bcryptjs_1.default.hash((0, crypto_1.randomBytes)(16).toString("hex"), SALT_ROUNDS);
            account = await prisma_1.prisma.userAccount.create({
                data: {
                    email: mappedEmail,
                    passwordHash: dummyHash,
                    provider: "kakao",
                    kakaoId,
                    profileId: profile.id,
                },
                include: { profile: true },
            });
        }
        const tokens = await this.issueTokens({
            accountId: account.id,
            profileId: account.profileId,
            provider: account.provider,
            email: account.email,
        });
        const profile = account.profile ?? await prisma_1.prisma.userProfile.findUniqueOrThrow({
            where: { id: account.profileId },
        });
        return { ...tokens, profile: this.toProfile(profile) };
    }
    async rotateRefreshToken(refreshToken) {
        const session = await prisma_1.prisma.session.findUnique({
            where: { refreshToken },
            include: { userAccount: { include: { profile: true } } },
        });
        if (!session) {
            throw new Error("INVALID_REFRESH");
        }
        if (new Date(session.expiresAt) < new Date()) {
            await prisma_1.prisma.session.delete({ where: { id: session.id } });
            throw new Error("EXPIRED_REFRESH");
        }
        const account = session.userAccount;
        const profile = account.profile;
        await prisma_1.prisma.session.delete({ where: { id: session.id } });
        return this.issueTokens({
            accountId: account.id,
            profileId: profile.id,
            provider: account.provider,
            email: account.email,
        });
    }
    signToken(payload) {
        return jsonwebtoken_1.default.sign(payload, config_1.env.JWT_SECRET, {
            expiresIn: config_1.env.JWT_EXPIRES_IN,
        });
    }
    async issueTokens(params) {
        const accessToken = this.signToken({
            sub: params.accountId,
            profileId: params.profileId,
            provider: params.provider,
            email: params.email,
        });
        const refreshToken = await this.createRefreshToken(params.accountId);
        return {
            token: accessToken,
            refreshToken,
            profileId: params.profileId,
            accountId: params.accountId,
        };
    }
    async createRefreshToken(accountId) {
        const token = (0, crypto_1.randomBytes)(48).toString("hex");
        const expiresAt = new Date(Date.now() + REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000);
        await prisma_1.prisma.session.create({
            data: {
                userAccountId: accountId,
                refreshToken: token,
                expiresAt,
            },
        });
        return token;
    }
    toProfile(record) {
        return {
            id: record.id,
            name: record.name,
            age: record.age,
            gender: record.gender,
            address: record.address,
            profileImageUrl: record.profileImageUrl ?? undefined,
            phoneNumber: record.phoneNumber ?? undefined,
            appointmentCount: record.appointmentCount,
            treatmentCount: record.treatmentCount,
            isPractitioner: record.isPractitioner,
            certificationStatus: record.certificationStatus,
            createdAt: (record.createdAt instanceof Date
                ? record.createdAt
                : new Date(record.createdAt)).toISOString(),
            updatedAt: (record.updatedAt instanceof Date
                ? record.updatedAt
                : new Date(record.updatedAt)).toISOString(),
        };
    }
}
exports.AuthService = AuthService;
