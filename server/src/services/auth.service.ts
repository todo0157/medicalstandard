import { Prisma } from "@prisma/client";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { randomBytes } from "crypto";

import { env } from "../config";
import { prisma } from "../lib/prisma";
import type { AuthResult, AuthTokenPayload } from "../types/auth";
import type { UserProfile } from "../types/userProfile";
import { issueEmailVerificationToken } from "./token.service";
import { sendMail } from "./mailer.service";

export interface SignupInput {
  email: string;
  password: string;
  name: string;
  age?: number;
  gender?: "male" | "female";
  address?: string;
  phoneNumber?: string;
}

export interface LoginInput {
  email: string;
  password: string;
}

const SALT_ROUNDS = 10;
const REFRESH_TTL_DAYS = 14;
const KAKAO_TOKEN_URL = "https://kauth.kakao.com/oauth/token";
const KAKAO_ME_URL = "https://kapi.kakao.com/v2/user/me";

export class AuthService {
  async signup(input: SignupInput): Promise<AuthResult & { profile: UserProfile }> {
    const email = input.email.toLowerCase().trim();
    const passwordHash = await bcrypt.hash(input.password, SALT_ROUNDS);
    const cleanedAddress = input.address?.trim() ?? "";
    const cleanedPhone = input.phoneNumber?.trim() ?? "";
    // (옵션) precheck 토큰 검증은 라우트에서 처리하거나 여기에서 처리할 수 있습니다.

    try {
      const profile = await prisma.userProfile.create({
        data: {
          name: input.name.trim(),
          age: input.age ?? 0,
          gender: input.gender ?? "male",
          address: cleanedAddress.length === 0 ? "미입력" : cleanedAddress,
          phoneNumber: cleanedPhone.length === 0 ? undefined : cleanedPhone,
        },
      });

      const account = await prisma.userAccount.create({
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
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === "P2002"
      ) {
        throw new Error("EMAIL_ALREADY_EXISTS");
      }
      throw error;
    }
  }

  async login(input: LoginInput): Promise<AuthResult & { profile: UserProfile }> {
    const account = await prisma.userAccount.findUnique({
      where: { email: input.email.toLowerCase().trim() },
      include: { profile: true },
    });

    if (!account || !(await bcrypt.compare(input.password, account.passwordHash))) {
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

  async sendVerificationEmail(accountId: string, email: string) {
    if (!env.VERIFY_LINK_BASE) return;
    const { token } = await issueEmailVerificationToken(accountId);
    const link = `${env.VERIFY_LINK_BASE}?token=${token}`;
    await sendMail({
      to: email,
      subject: "이메일 인증을 완료해 주세요",
      html: `<p>이메일 인증을 완료하려면 아래 링크를 클릭하세요.</p><p><a href="${link}">${link}</a></p>`,
      text: `이메일 인증 링크: ${link}`,
    });
  }

  async markEmailVerified(accountId: string) {
    await prisma.userAccount.update({
      where: { id: accountId },
      data: { emailVerified: true },
    });
  }

  decodeToken(token: string): AuthTokenPayload {
    const payload = jwt.verify(token, env.JWT_SECRET) as AuthTokenPayload;
    return payload;
  }

  async loginWithKakao(params: { code: string; redirectUri?: string }): Promise<AuthResult & { profile: UserProfile }> {
    if (!env.KAKAO_REST_API_KEY) {
      throw new Error("KAKAO_CONFIG_MISSING");
    }
    const redirectUri = params.redirectUri ?? env.KAKAO_REDIRECT_URI;
    if (!redirectUri) {
      throw new Error("KAKAO_CONFIG_MISSING");
    }

    const tokenRes = await fetch(KAKAO_TOKEN_URL, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "authorization_code",
        client_id: env.KAKAO_REST_API_KEY,
        redirect_uri: redirectUri,
        code: params.code,
        ...(env.KAKAO_CLIENT_SECRET ? { client_secret: env.KAKAO_CLIENT_SECRET } : {}),
      }),
    });

    if (!tokenRes.ok) {
      const txt = await tokenRes.text();
      throw new Error(`KAKAO_TOKEN_FAILED: ${txt}`);
    }
    const tokenJson = (await tokenRes.json()) as { access_token: string };
    if (!tokenJson.access_token) throw new Error("KAKAO_TOKEN_MISSING");

    const meRes = await fetch(KAKAO_ME_URL, {
      headers: { Authorization: `Bearer ${tokenJson.access_token}` },
    });
    if (!meRes.ok) {
      const txt = await meRes.text();
      throw new Error(`KAKAO_ME_FAILED: ${txt}`);
    }
    const me = await meRes.json() as any;
    const kakaoId: string = me.id?.toString();
    if (!kakaoId) throw new Error("KAKAO_ID_MISSING");
    const kakaoAccount = me.kakao_account ?? {};
    const profileInfo = kakaoAccount.profile ?? {};
    const email: string = kakaoAccount.email ??
      kakaoAccount.email_needs_agreement ? undefined : undefined;

    const mappedEmail = email ?? `${kakaoId}@kakao.local`;
    const displayName = profileInfo.nickname ?? "카카오 사용자";

    // find or create
    let account = await prisma.userAccount.findFirst({
      where: { OR: [{ kakaoId }, { email: mappedEmail }] },
      include: { profile: true },
    });

    if (!account) {
      const profile = await prisma.userProfile.create({
        data: {
          name: displayName,
          age: 0,
          gender: "male",
          address: "카카오 로그인",
        },
      });

      const dummyHash = await bcrypt.hash(randomBytes(16).toString("hex"), SALT_ROUNDS);

      account = await prisma.userAccount.create({
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

    const profile = account.profile ?? await prisma.userProfile.findUniqueOrThrow({
      where: { id: account.profileId },
    });

    return { ...tokens, profile: this.toProfile(profile) };
  }

  async rotateRefreshToken(refreshToken: string): Promise<AuthResult> {
    const session = await prisma.session.findUnique({
      where: { refreshToken },
      include: { userAccount: { include: { profile: true } } },
    });
    if (!session) {
      throw new Error("INVALID_REFRESH");
    }
    if (new Date(session.expiresAt) < new Date()) {
      await prisma.session.delete({ where: { id: session.id } });
      throw new Error("EXPIRED_REFRESH");
    }
    const account = session.userAccount;
    const profile = account.profile!;
    await prisma.session.delete({ where: { id: session.id } });

    return this.issueTokens({
      accountId: account.id,
      profileId: profile.id,
      provider: account.provider,
      email: account.email,
    });
  }

  private signToken(payload: AuthTokenPayload): string {
    return jwt.sign(payload, env.JWT_SECRET, {
      expiresIn: env.JWT_EXPIRES_IN as jwt.SignOptions["expiresIn"],
    });
  }

  private async issueTokens(params: {
    accountId: string;
    profileId: string;
    provider: string;
    email: string;
  }): Promise<AuthResult> {
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

  private async createRefreshToken(accountId: string): Promise<string> {
    const token = randomBytes(48).toString("hex");
    const expiresAt = new Date(Date.now() + REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000);
    await prisma.session.create({
      data: {
        userAccountId: accountId,
        refreshToken: token,
        expiresAt,
      },
    });
    return token;
  }

  private toProfile(record: any): UserProfile {
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
        : new Date(record.createdAt)
      ).toISOString(),
      updatedAt: (record.updatedAt instanceof Date
        ? record.updatedAt
        : new Date(record.updatedAt)
      ).toISOString(),
    };
  }
}
