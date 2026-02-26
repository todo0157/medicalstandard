import { Router } from "express";
import { z } from "zod";

import { authenticate, type AuthenticatedRequest } from "../middleware/auth.middleware";
import { asyncHandler } from "../middleware/async-handler";
import { validateBody } from "../middleware/validate";
import { AuthService, type SignupInput, type LoginInput } from "../services/auth.service";
import { ProfileService } from "../services/profile.service";
import {
  issuePasswordResetToken,
  consumePasswordResetToken,
  consumeEmailVerificationToken,
  issuePreSignupVerificationToken,
  consumePreSignupVerificationToken,
  issueEmailVerificationToken,
} from "../services/token.service";
import { sendMail } from "../services/mailer.service";
import { env } from "../config";
import { logger } from "../lib/logger";
import { prisma } from "../lib/prisma";
import bcrypt from "bcryptjs";

const router = Router();
const authService = new AuthService();
const profileService = new ProfileService();

// ─── Schemas ─────────────────────────────────────────────────────

const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(64),
  name: z.string().min(1).max(50),
  age: z.coerce.number().int().min(0).max(120).optional(),
  gender: z.enum(["male", "female"]).optional(),
  address: z.string().max(200).optional(),
  phoneNumber: z.string().regex(/^[0-9+\-]{7,20}$/).optional(),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(64),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(10),
});

const kakaoSchema = z.object({
  code: z.string().min(5),
  redirectUri: z.string().url().optional(),
});

const emailSchema = z.object({
  email: z.string().email(),
});

const tokenSchema = z.object({
  token: z.string().min(10),
});

const resetSchema = z.object({
  token: z.string().min(10),
  password: z.string().min(8).max(64),
});

// Auth errors are now AppError instances thrown by AuthService.
// They propagate to the global error handler via asyncHandler/next.

// ─── Routes ──────────────────────────────────────────────────────

router.post(
  "/signup",
  validateBody(signupSchema),
  asyncHandler(async (req, res) => {
    const payload = req.body as SignupInput;
    const email = payload.email.toLowerCase().trim();

    // Pre-signup email verification check
    const preToken = await prisma.preSignupEmailToken.findFirst({
      where: { email, used: true },
      orderBy: { createdAt: "desc" },
    });
    if (!preToken || preToken.expiresAt < new Date()) {
      return res.status(400).json({ message: "이메일 인증을 먼저 완료해 주세요." });
    }

    const result = await authService.signup(payload);

    // Send verification email (non-critical)
    authService.sendVerificationEmail(result.accountId, payload.email).catch((e) => {
      logger.warn("[Auth] Failed to send verification email", e);
    });

    return res.status(201).json({ data: result });
  }),
);

router.post(
  "/login",
  validateBody(loginSchema),
  asyncHandler(async (req, res) => {
    const result = await authService.login(req.body as LoginInput);
    return res.json({ data: result });
  }),
);

router.post(
  "/refresh",
  validateBody(refreshSchema),
  asyncHandler(async (req, res) => {
    const result = await authService.rotateRefreshToken(req.body.refreshToken);
    return res.json({ data: result });
  }),
);

router.post(
  "/kakao",
  validateBody(kakaoSchema),
  asyncHandler(async (req, res) => {
    const result = await authService.loginWithKakao({
      code: req.body.code,
      redirectUri: req.body.redirectUri,
    });
    return res.json({ data: result });
  }),
);

// Password reset request
router.post(
  "/forgot",
  validateBody(emailSchema),
  asyncHandler(async (req, res) => {
    const { email } = req.body;
    const account = await prisma.userAccount.findUnique({ where: { email } });
    if (!account) {
      // Don't reveal whether the email exists
      return res.json({ message: "재설정 메일이 발송되었습니다." });
    }
    if (!env.RESET_LINK_BASE) {
      return res.status(500).json({ message: "비밀번호 재설정 링크가 구성되지 않았습니다." });
    }

    const { token } = await issuePasswordResetToken(account.id);
    const link = `${env.RESET_LINK_BASE}?token=${token}`;
    await sendMail({
      to: account.email,
      subject: "비밀번호 재설정 안내",
      html: `<p>비밀번호를 재설정하려면 아래 링크를 클릭하세요.</p><p><a href="${link}">${link}</a></p>`,
      text: `비밀번호 재설정 링크: ${link}`,
    });
    return res.json({ message: "재설정 메일이 발송되었습니다." });
  }),
);

// Password reset complete
router.post(
  "/reset",
  validateBody(resetSchema),
  asyncHandler(async (req, res) => {
    const { token, password } = req.body;
    const userAccountId = await consumePasswordResetToken(token);
    if (!userAccountId) {
      return res.status(400).json({ message: "유효하지 않거나 만료된 토큰입니다." });
    }
    const hash = await bcrypt.hash(password, 10);
    const account = await prisma.userAccount.update({
      where: { id: userAccountId },
      data: { passwordHash: hash },
    });
    return res.json({ message: "비밀번호가 재설정되었습니다.", email: account.email });
  }),
);

// Re-send email verification
router.post(
  "/verify-email",
  validateBody(emailSchema),
  asyncHandler(async (req, res) => {
    const { email } = req.body;
    const account = await prisma.userAccount.findUnique({ where: { email } });
    if (!account) {
      return res.json({ message: "인증 메일이 발송되었습니다." });
    }
    if (!env.VERIFY_LINK_BASE) {
      return res.status(500).json({ message: "이메일 인증 링크가 구성되지 않았습니다." });
    }
    const { token } = await issueEmailVerificationToken(account.id);
    const link = `${env.VERIFY_LINK_BASE}?token=${token}`;
    await sendMail({
      to: account.email,
      subject: "이메일 인증을 완료해 주세요",
      html: `<p>아래 링크를 클릭해 이메일 인증을 완료하세요.</p><p><a href="${link}">${link}</a></p>`,
      text: `이메일 인증 링크: ${link}`,
    });
    return res.json({ message: "인증 메일이 발송되었습니다." });
  }),
);

// Confirm email verification
router.post(
  "/verify-email/confirm",
  validateBody(tokenSchema),
  asyncHandler(async (req, res) => {
    const userAccountId = await consumeEmailVerificationToken(req.body.token);
    if (!userAccountId) {
      return res.status(400).json({ message: "유효하지 않거나 만료된 토큰입니다." });
    }
    await authService.markEmailVerified(userAccountId);
    return res.json({ message: "이메일 인증이 완료되었습니다." });
  }),
);

// Pre-signup email verification send
router.post(
  "/verify-email/precheck",
  validateBody(emailSchema),
  asyncHandler(async (req, res) => {
    const { email } = req.body;
    if (!env.VERIFY_PRE_LINK_BASE) {
      return res.status(500).json({ message: "사전 이메일 인증 링크가 구성되지 않았습니다." });
    }
    const { token } = await issuePreSignupVerificationToken(email);
    const link = `${env.VERIFY_PRE_LINK_BASE}?token=${token}`;
    await sendMail({
      to: email,
      subject: "회원가입을 위한 이메일 인증",
      html: `<p>아래 링크를 클릭해 이메일 인증을 완료하세요.</p><p><a href="${link}">${link}</a></p>`,
      text: `이메일 인증 링크: ${link}`,
    });
    return res.json({ message: "인증 메일을 발송했습니다." });
  }),
);

// Pre-signup email verification confirm
router.post(
  "/verify-email/precheck/confirm",
  validateBody(tokenSchema),
  asyncHandler(async (req, res) => {
    const email = await consumePreSignupVerificationToken(req.body.token);
    if (!email) {
      return res.status(400).json({ message: "유효하지 않거나 만료된 토큰입니다." });
    }
    return res.json({ message: "이메일 인증이 완료되었습니다.", email });
  }),
);

// Current user info
router.get(
  "/me",
  authenticate,
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    if (!req.user?.profileId) {
      return res.status(401).json({ message: "인증 정보가 없습니다." });
    }
    const profile = await profileService.getUserProfileById(req.user.profileId);
    return res.json({ data: profile });
  }),
);

export default router;
