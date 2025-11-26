import { Router } from "express";
import { z } from "zod";

import { authenticate, AuthenticatedRequest } from "../middleware/auth.middleware";
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
import { prisma } from "../lib/prisma";
import bcrypt from "bcryptjs";

const router = Router();
const authService = new AuthService();
const profileService = new ProfileService();

const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(64),
  name: z.string().min(1).max(50),
  age: z.coerce.number().int().min(0).max(120).optional(),
  gender: z.enum(["male", "female"]).optional(),
  address: z.string().max(200).optional(),
  phoneNumber: z
    .string()
    .regex(/^[0-9+\-]{7,20}$/)
    .optional(),
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

const forgotSchema = z.object({
  email: z.string().email(),
});

const resetSchema = z.object({
  token: z.string().min(10),
  password: z.string().min(8).max(64),
});

const verifySchema = z.object({
  email: z.string().email(),
});

const verifyConfirmSchema = z.object({
  token: z.string().min(10),
});

const preVerifySchema = z.object({
  email: z.string().email(),
});

const preVerifyConfirmSchema = z.object({
  token: z.string().min(10),
});

router.post("/signup", async (req, res, next) => {
  try {
    const payload = signupSchema.parse(req.body) as SignupInput;
    const email = payload.email.toLowerCase().trim();

    // pre-signup email verification check
    const preToken = await prisma.preSignupEmailToken.findFirst({
      where: { email, used: true },
      orderBy: { createdAt: "desc" },
    });
    if (!preToken || preToken.expiresAt < new Date()) {
      return res.status(400).json({
        message: "이메일 인증을 먼저 완료해 주세요.",
      });
    }

    const result = await authService.signup(payload);
    // 이메일 인증 메일 전송 (가능한 경우)
    try {
      await authService.sendVerificationEmail(result.accountId, payload.email);
    } catch (e) {
      // 이메일 전송 실패는 로그만 남기고 진행
      console.warn("Failed to send verification email", e);
    }
    return res.status(201).json({ data: result });
  } catch (error) {
    if (error instanceof z.ZodError) {
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
    const payload = loginSchema.parse(req.body) as LoginInput;
    const result = await authService.login(payload);
    return res.json({ data: result });
  } catch (error) {
    if (error instanceof z.ZodError) {
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
  } catch (error) {
    if (error instanceof z.ZodError) {
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
  } catch (error) {
    if (error instanceof z.ZodError) {
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

// 비밀번호 재설정 요청 (메일 발송)
router.post("/forgot", async (req, res, next) => {
  try {
    const { email } = forgotSchema.parse(req.body);
    const account = await prisma.userAccount.findUnique({ where: { email } });
    if (!account) {
      // 존재 여부 노출 방지
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
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "입력값이 올바르지 않습니다.",
        issues: error.flatten().fieldErrors,
      });
    }
    return next(error);
  }
});

// 비밀번호 재설정 완료
router.post("/reset", async (req, res, next) => {
  try {
    const { token, password } = resetSchema.parse(req.body);
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
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "입력값이 올바르지 않습니다.",
        issues: error.flatten().fieldErrors,
      });
    }
    return next(error);
  }
});

// 이메일 인증 메일 재발송
router.post("/verify-email", async (req, res, next) => {
  try {
    const { email } = verifySchema.parse(req.body);
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
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "입력값이 올바르지 않습니다.",
        issues: error.flatten().fieldErrors,
      });
    }
    return next(error);
  }
});

// 이메일 인증 완료
router.post("/verify-email/confirm", async (req, res, next) => {
  try {
    const { token } = verifyConfirmSchema.parse(req.body);
    const userAccountId = await consumeEmailVerificationToken(token);
    if (!userAccountId) {
      return res.status(400).json({ message: "유효하지 않거나 만료된 토큰입니다." });
    }
    await authService.markEmailVerified(userAccountId);
    return res.json({ message: "이메일 인증이 완료되었습니다." });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "입력값이 올바르지 않습니다.",
        issues: error.flatten().fieldErrors,
      });
    }
    return next(error);
  }
});

// 회원가입 전 이메일 인증 토큰 발송
router.post("/verify-email/precheck", async (req, res, next) => {
  try {
    const { email } = preVerifySchema.parse(req.body);
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
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "입력값이 올바르지 않습니다.",
        issues: error.flatten().fieldErrors,
      });
    }
    return next(error);
  }
});

// 회원가입 전 이메일 인증 완료
router.post("/verify-email/precheck/confirm", async (req, res, next) => {
  try {
    const { token } = preVerifyConfirmSchema.parse(req.body);
    const email = await consumePreSignupVerificationToken(token);
    if (!email) {
      return res.status(400).json({ message: "유효하지 않거나 만료된 토큰입니다." });
    }
    return res.json({ message: "이메일 인증이 완료되었습니다.", email });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "입력값이 올바르지 않습니다.",
        issues: error.flatten().fieldErrors,
      });
    }
    return next(error);
  }
});

router.get(
  "/me",
  authenticate,
  async (req: AuthenticatedRequest, res, next) => {
    try {
      if (!req.user?.profileId) {
        return res.status(401).json({ message: "인증 정보가 없습니다." });
      }
      const profile = await profileService.getUserProfileById(req.user.profileId);
      return res.json({ data: profile });
    } catch (error) {
      return next(error);
    }
  },
);

export default router;
