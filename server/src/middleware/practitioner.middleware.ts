import type { Response, NextFunction } from "express";
import type { Doctor } from "@prisma/client";

import { prisma } from "../lib/prisma";
import { logger } from "../lib/logger";
import type { AuthenticatedRequest } from "./auth.middleware";

/**
 * Extended request that includes the resolved practitioner Doctor record.
 */
export interface PractitionerRequest extends AuthenticatedRequest {
  practitionerDoctor: Doctor;
}

/**
 * Resolve the best-matching Doctor record for a practitioner profile.
 *
 * When multiple Doctor rows share the same name, we disambiguate by
 * comparing `UserProfile.clinicName` with `Doctor → Clinic.name`.
 * Falls back to the first match if clinic info is unavailable.
 */
async function resolveDoctor(
  profileName: string,
  clinicName: string | null,
): Promise<Doctor | null> {
  const candidates = await prisma.doctor.findMany({
    where: { name: profileName },
    include: { clinic: { select: { name: true } } },
  });

  if (candidates.length === 0) return null;
  if (candidates.length === 1) return candidates[0];

  // Multiple doctors share the same name — try clinic-based disambiguation
  if (clinicName) {
    const matched = candidates.find((d) => d.clinic.name === clinicName);
    if (matched) return matched;
  }

  logger.warn(
    `[Practitioner] Ambiguous match: ${candidates.length} doctors named "${profileName}". ` +
      `Using first result (id=${candidates[0].id}). Consider linking Doctor ↔ UserProfile directly.`,
  );
  return candidates[0];
}

/**
 * Middleware that resolves the authenticated user's corresponding Doctor record.
 *
 * Requires `authenticate` middleware to run first.
 *
 * Flow:
 *   1. Read profileId from the JWT payload.
 *   2. Look up the UserProfile; verify isPractitioner === true.
 *   3. Find the Doctor row matching profile name (disambiguated by clinic).
 *   4. Attach the Doctor to `req.practitionerDoctor`.
 *
 * Responds with 401/403/404 if any step fails.
 */
export async function resolvePractitionerDoctor(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
) {
  const profileId = req.user?.profileId;
  if (!profileId) {
    return res.status(401).json({ message: "인증 정보가 없습니다." });
  }

  const profile = await prisma.userProfile.findUnique({
    where: { id: profileId },
    select: { name: true, isPractitioner: true, clinicName: true },
  });

  if (!profile || !profile.isPractitioner) {
    return res.status(403).json({ message: "한의사 인증이 필요합니다." });
  }

  const doctor = await resolveDoctor(profile.name, profile.clinicName ?? null);

  if (!doctor) {
    return res.status(404).json({ message: "한의사 정보를 찾을 수 없습니다." });
  }

  (req as PractitionerRequest).practitionerDoctor = doctor;
  return next();
}

/**
 * Helper: resolves the Doctor for an authenticated user without failing the request.
 * Returns the Doctor or null. Useful inside route handlers that need optional practitioner context.
 */
export async function findPractitionerDoctor(
  accountId: string,
): Promise<Doctor | null> {
  const account = await prisma.userAccount.findUnique({
    where: { id: accountId },
    select: { profileId: true },
  });
  if (!account) return null;

  const profile = await prisma.userProfile.findUnique({
    where: { id: account.profileId },
    select: { name: true, isPractitioner: true, clinicName: true },
  });
  if (!profile?.isPractitioner) return null;

  return resolveDoctor(profile.name, profile.clinicName ?? null);
}
