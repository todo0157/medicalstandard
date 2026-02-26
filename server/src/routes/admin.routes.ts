import { Router } from "express";
import { z } from "zod";

import { authenticate, type AuthenticatedRequest } from "../middleware/auth.middleware";
import { requireAdmin } from "../middleware/admin.middleware";
import { asyncHandler } from "../middleware/async-handler";
import { validateBody } from "../middleware/validate";
import { ProfileService } from "../services/profile.service";
import { prisma } from "../lib/prisma";
import { logger } from "../lib/logger";

const router = Router();
const profileService = new ProfileService();

const approveSchema = z.object({
  notes: z.string().max(500).optional(),
});

const rejectSchema = z.object({
  reason: z.string().min(1).max(500),
  notes: z.string().max(500).optional(),
});

router.use(authenticate);
router.use(requireAdmin);

// ─── Certification List ──────────────────────────────────────────

router.get(
  "/certifications",
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { status = "pending", page = "1", limit = "20" } = req.query;
    const pageNum = parseInt(page as string, 10) || 1;
    const limitNum = parseInt(limit as string, 10) || 20;
    const skip = (pageNum - 1) * limitNum;

    const statusFilter = status === "all" ? undefined : (status as string);
    const where: any = {};
    if (statusFilter) {
      where.certificationStatus = statusFilter;
    }

    const [profiles, total] = await Promise.all([
      prisma.userProfile.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: { updatedAt: "desc" },
        include: { account: { select: { id: true, email: true, createdAt: true } } },
      }),
      prisma.userProfile.count({ where }),
    ]);

    return res.json({
      data: profiles.map((p) => ({
        id: p.id,
        name: p.name,
        email: p.account?.email,
        certificationStatus: p.certificationStatus,
        isPractitioner: p.isPractitioner,
        licenseNumber: p.licenseNumber,
        clinicName: p.clinicName,
        createdAt: p.createdAt.toISOString(),
        updatedAt: p.updatedAt.toISOString(),
      })),
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages: Math.ceil(total / limitNum),
      },
    });
  }),
);

// ─── Certification Detail ────────────────────────────────────────

router.get(
  "/certifications/:profileId",
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const profile = await prisma.userProfile.findUnique({
      where: { id: req.params.profileId },
      include: { account: { select: { id: true, email: true, createdAt: true } } },
    });
    if (!profile) {
      return res.status(404).json({ message: "프로필을 찾을 수 없습니다." });
    }

    return res.json({
      data: {
        id: profile.id,
        name: profile.name,
        email: profile.account?.email,
        age: profile.age,
        gender: profile.gender,
        address: profile.address,
        phoneNumber: profile.phoneNumber,
        certificationStatus: profile.certificationStatus,
        isPractitioner: profile.isPractitioner,
        licenseNumber: profile.licenseNumber,
        clinicName: profile.clinicName,
        profileImageUrl: profile.profileImageUrl,
        createdAt: profile.createdAt.toISOString(),
        updatedAt: profile.updatedAt.toISOString(),
      },
    });
  }),
);

// ─── Approve ─────────────────────────────────────────────────────

router.post(
  "/certifications/:profileId/approve",
  validateBody(approveSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { profileId } = req.params;
    const profile = await prisma.userProfile.findUnique({ where: { id: profileId } });
    if (!profile) {
      return res.status(404).json({ message: "프로필을 찾을 수 없습니다." });
    }

    const updated = await profileService.updateProfile(profileId, {
      certificationStatus: "verified",
      isPractitioner: true,
    });

    // Ensure a Doctor record exists
    try {
      await ensureDoctorRecord(profile);
    } catch (err) {
      logger.error(`[Admin] Failed to create/update doctor record for ${profileId}:`, err);
    }

    logger.info(`[Admin] Certification approved for ${profileId} by ${req.user?.email}`);
    return res.json({ data: updated, message: "인증이 승인되었습니다." });
  }),
);

// ─── Reject ──────────────────────────────────────────────────────

router.post(
  "/certifications/:profileId/reject",
  validateBody(rejectSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { profileId } = req.params;
    const profile = await prisma.userProfile.findUnique({ where: { id: profileId } });
    if (!profile) {
      return res.status(404).json({ message: "프로필을 찾을 수 없습니다." });
    }

    const updated = await profileService.updateProfile(profileId, {
      certificationStatus: "none",
      isPractitioner: false,
    });

    // Deactivate Doctor records
    try {
      await prisma.doctor.updateMany({
        where: { name: profile.name },
        data: { isVerified: false },
      });
    } catch (err) {
      logger.error(`[Admin] Failed to deactivate doctor for ${profile.name}:`, err);
    }

    logger.info(
      `[Admin] Certification rejected for ${profileId} by ${req.user?.email}. Reason: ${req.body.reason}`,
    );
    return res.json({ data: updated, message: "인증이 거부되었습니다.", reason: req.body.reason });
  }),
);

// ─── Helper ──────────────────────────────────────────────────────

async function ensureDoctorRecord(profile: {
  id: string;
  name: string;
  address: string;
  clinicName: string | null;
  licenseNumber: string | null;
  profileImageUrl: string | null;
}) {
  // Find or create clinic
  const clinicName = profile.clinicName || `${profile.name} 클리닉`;
  let clinic = await prisma.clinic.findFirst({ where: { name: clinicName } });
  if (!clinic) {
    clinic = await prisma.clinic.create({
      data: { name: clinicName, address: profile.address, lat: 0, lng: 0 },
    });
  }

  // Find or create doctor
  const existing = await prisma.doctor.findFirst({ where: { name: profile.name } });
  if (!existing) {
    await prisma.doctor.create({
      data: {
        name: profile.name,
        specialty: "한의학",
        bio: `자격증 번호: ${profile.licenseNumber || "없음"}`,
        imageUrl: profile.profileImageUrl,
        clinicId: clinic.id,
        isVerified: true,
      },
    });
  } else {
    const updateData: Record<string, any> = { clinicId: clinic.id, isVerified: true };
    if (profile.profileImageUrl) updateData.imageUrl = profile.profileImageUrl;
    if (profile.licenseNumber) updateData.bio = `자격증 번호: ${profile.licenseNumber}`;
    await prisma.doctor.update({ where: { id: existing.id }, data: updateData });
  }
}

export default router;
