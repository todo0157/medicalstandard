import { Router } from "express";
import { z } from "zod";

import { ProfileService } from "../services/profile.service";
import { authenticate, type AuthenticatedRequest } from "../middleware/auth.middleware";
import { asyncHandler } from "../middleware/async-handler";
import { validateBody } from "../middleware/validate";
import { uploadImageToS3 } from "../lib/s3";

const router = Router();
const profileService = new ProfileService();

// ─── Schemas ─────────────────────────────────────────────────────

const profileUpdateSchema = z.object({
  name: z.string().min(1).max(50),
  age: z.coerce.number().int().min(0).max(120),
  gender: z.enum(["male", "female"]),
  address: z.string().min(1).max(120),
  profileImageUrl: z
    .union([z.string().url().min(1), z.literal("")])
    .optional()
    .transform((v) => (v === "" ? undefined : v)),
  phoneNumber: z
    .union([z.string().regex(/^[0-9+\-]{7,20}$/).min(7).max(20), z.literal("")])
    .optional()
    .transform((v) => (v === "" ? undefined : v)),
  appointmentCount: z.coerce.number().int().min(0).optional(),
  treatmentCount: z.coerce.number().int().min(0).optional(),
  isPractitioner: z.coerce.boolean().optional(),
  certificationStatus: z.enum(["none", "pending", "verified"]).optional(),
  licenseNumber: z.string().max(50).optional(),
  clinicName: z.string().max(100).optional(),
});

const photoSchema = z.object({
  imageData: z.string().min(32),
  fileName: z.string().max(200).optional(),
});

const certificationSchema = z.object({
  status: z.enum(["none", "pending", "verified"]),
  isPractitioner: z.boolean().optional(),
  licenseNumber: z.string().max(50).optional(),
  clinicName: z.string().max(100).optional(),
});

const MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10 MB
const ALLOWED_EXTENSIONS = new Set(["png", "jpg", "jpeg", "webp"]);

// ─── Routes ──────────────────────────────────────────────────────

router.use(authenticate);

router.get(
  "/me",
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: "인증 정보가 없습니다." });
    }
    const profile = await profileService.getCurrentUserProfile(profileId);
    return res.json({ data: profile });
  }),
);

router.put(
  "/me",
  validateBody(profileUpdateSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: "인증 정보가 없습니다." });
    }
    const updated = await profileService.updateProfile(profileId, req.body);
    return res.json({ data: updated });
  }),
);

router.put(
  "/:id",
  validateBody(profileUpdateSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const profileId = req.user?.profileId;
    if (!profileId) {
      return res.status(401).json({ message: "인증 정보가 없습니다." });
    }
    if (req.params.id !== profileId) {
      return res.status(403).json({ message: "자신의 프로필만 수정할 수 있습니다." });
    }
    const updated = await profileService.updateProfile(profileId, req.body);
    return res.json({ data: updated });
  }),
);

router.post(
  "/:id/photo",
  validateBody(photoSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const profileId = req.user?.profileId;
    if (!profileId || profileId !== req.params.id) {
      return res.status(403).json({ message: "자신의 프로필 사진만 변경할 수 있습니다." });
    }

    const imageData = req.body.imageData.replace(/\s/g, "");
    if (imageData.length > MAX_IMAGE_SIZE) {
      return res.status(400).json({
        message: "이미지 크기가 너무 큽니다. 10MB 이하의 이미지를 선택해주세요.",
      });
    }

    const ext = req.body.fileName?.split(".").pop()?.toLowerCase() ?? "png";
    const normalized = ALLOWED_EXTENSIONS.has(ext) ? ext : "png";
    const mime = normalized === "jpg" ? "jpeg" : normalized;
    const dataUrl = `data:image/${mime};base64,${imageData}`;

    const s3Url = await uploadImageToS3(dataUrl, "profiles");
    const updated = await profileService.updateProfile(profileId, { profileImageUrl: s3Url });
    return res.json({ data: updated });
  }),
);

router.post(
  "/:id/certification",
  validateBody(certificationSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const profileId = req.user?.profileId;
    if (!profileId || profileId !== req.params.id) {
      return res.status(403).json({ message: "자신의 프로필만 인증 상태를 변경할 수 있습니다." });
    }

    const updated = await profileService.updateProfile(profileId, {
      certificationStatus: req.body.status,
      isPractitioner: req.body.isPractitioner ?? req.body.status === "verified",
      licenseNumber: req.body.licenseNumber,
      clinicName: req.body.clinicName,
    });
    return res.json({ data: updated });
  }),
);

export default router;
