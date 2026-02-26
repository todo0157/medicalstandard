import { Router } from "express";
import { z } from "zod";

import { authenticate, type AuthenticatedRequest } from "../middleware/auth.middleware";
import { asyncHandler } from "../middleware/async-handler";
import { validateBody, validateQuery } from "../middleware/validate";
import { env } from "../config";
import { logger } from "../lib/logger";
import postalCodeService from "../services/postal-code.service";

const router = Router();

// ─── Schemas ─────────────────────────────────────────────────────

const searchSchema = z.object({
  query: z.string().min(1).max(200),
});

const geocodeSchema = z.object({
  roadAddress: z.string().optional(),
  jibunAddress: z.string().optional(),
});

// ─── Naver Map API helper ────────────────────────────────────────

const NAVER_GEOCODE_URL = "https://maps.apigw.ntruss.com/map-geocode/v2/geocode";
const NAVER_REVERSE_URL = "https://maps.apigw.ntruss.com/map-reversegeocode/v2/gc";

function getNaverHeaders(): Record<string, string> | null {
  const clientId = env.NAVER_MAP_CLIENT_ID?.trim();
  const clientSecret = env.NAVER_MAP_CLIENT_SECRET?.trim();
  if (!clientId || !clientSecret) return null;

  return {
    Accept: "application/json",
    "x-ncp-apigw-api-key-id": clientId,
    "x-ncp-apigw-api-key": clientSecret,
  };
}

async function naverGeocode(query: string) {
  const headers = getNaverHeaders();
  if (!headers) {
    throw new NaverApiError(500, "네이버 지도 API가 설정되지 않았습니다.");
  }

  const url = `${NAVER_GEOCODE_URL}?query=${encodeURIComponent(query.trim())}`;
  const response = await fetch(url, { method: "GET", headers });

  if (!response.ok) {
    const status = response.status === 401 ? 500 : response.status;
    throw new NaverApiError(status, "네이버 지도 API 오류가 발생했습니다.");
  }

  const data = await response.json();
  if (data.status !== "OK") {
    throw new NaverApiError(500, data.errorMessage || `네이버 지도 API 오류: ${data.status}`);
  }

  return (data.addresses || []).map((addr: any) => ({
    roadAddress: addr.roadAddress || "",
    jibunAddress: addr.jibunAddress || "",
    englishAddress: addr.englishAddress || "",
    addressElements: addr.addressElements || [],
    x: parseFloat(addr.x || "0"),
    y: parseFloat(addr.y || "0"),
    distance: addr.distance || 0,
  }));
}

class NaverApiError extends Error {
  constructor(
    public readonly statusCode: number,
    message: string,
  ) {
    super(message);
    this.name = "NaverApiError";
  }
}

// ─── Routes ──────────────────────────────────────────────────────

router.get(
  "/search",
  authenticate,
  validateQuery(searchSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { query } = (req as any).validatedQuery;
    const isPostalCode = /^\d{5}$/.test(query.trim());

    // Postal code search
    if (isPostalCode) {
      try {
        const postalResults = await postalCodeService.searchByPostalCode(query.trim());
        if (postalResults.length === 0) {
          return res.status(404).json({
            message: "해당 우편번호로 주소를 찾을 수 없습니다.",
            data: { addresses: [], total: 0 },
          });
        }

        const MAX_POSTAL_RESULTS = 100;
        const addresses = postalResults
          .slice(0, MAX_POSTAL_RESULTS)
          .map((r) => {
            const road = r.roadAddress || "";
            const jibun = r.jibunAddress || "";
            if (!road && !jibun) return null;
            return { roadAddress: road, jibunAddress: jibun, englishAddress: "", x: 0.0, y: 0.0, distance: 0.0, addressElements: [] as any[] };
          })
          .filter(Boolean);

        return res.json({ data: { addresses, total: addresses.length } });
      } catch (err) {
        logger.error("[PostalCodeService] Error:", err);
        return res.status(500).json({ message: "우편번호 검색 중 오류가 발생했습니다." });
      }
    }

    // General address search via Naver Geocode API
    try {
      const addresses = await naverGeocode(query);

      if (addresses.length === 0) {
        return res.status(404).json({
          message: "해당 주소를 찾을 수 없습니다.",
          data: { addresses: [], total: 0 },
        });
      }

      return res.json({ data: { addresses, total: addresses.length } });
    } catch (err) {
      if (err instanceof NaverApiError) {
        return res.status(err.statusCode).json({ message: err.message });
      }
      throw err;
    }
  }),
);

// Reverse geocoding (coordinates → address)
router.get(
  "/reverse",
  authenticate,
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const lat = parseFloat(req.query.lat as string);
    const lng = parseFloat(req.query.lng as string);

    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({ message: "위도와 경도가 올바르지 않습니다." });
    }

    const headers = getNaverHeaders();
    if (!headers) {
      return res.status(500).json({ message: "네이버 지도 API가 설정되지 않았습니다." });
    }

    const url = `${NAVER_REVERSE_URL}?coords=${lng},${lat}&output=json`;
    const response = await fetch(url, { method: "GET", headers });

    if (!response.ok) {
      const status = response.status === 401 ? 500 : response.status;
      return res.status(status).json({ message: "주소 변환에 실패했습니다." });
    }

    const data = await response.json();
    const statusCode = typeof data.status === "object" ? data.status?.code : null;
    const statusName = typeof data.status === "string" ? data.status : data.status?.name;

    if ((statusCode !== null && statusCode !== 0) || (statusName && statusName !== "OK")) {
      return res.status(500).json({ message: "주소 변환에 실패했습니다." });
    }

    if (!data.results || data.results.length === 0) {
      return res.status(404).json({ message: "해당 좌표의 주소를 찾을 수 없습니다." });
    }

    const r = data.results[0];
    const parts = [
      r.region?.area1?.name,
      r.region?.area2?.name,
      r.region?.area3?.name,
      r.region?.area4?.name,
    ]
      .filter(Boolean)
      .join(" ");

    return res.json({
      data: { roadAddress: parts, jibunAddress: parts, x: lng, y: lat },
    });
  }),
);

// Forward geocoding (address → coordinates) for postal code results
router.post(
  "/geocode",
  authenticate,
  validateBody(geocodeSchema),
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { roadAddress, jibunAddress } = req.body;
    if (!roadAddress && !jibunAddress) {
      return res.status(400).json({ message: "도로명 주소 또는 지번 주소가 필요합니다." });
    }

    try {
      const searchQuery = roadAddress || jibunAddress;
      const addresses = await naverGeocode(searchQuery);

      if (addresses.length === 0) {
        return res.status(404).json({ message: "해당 주소의 좌표를 찾을 수 없습니다." });
      }

      const addr = addresses[0];
      return res.json({
        data: {
          roadAddress: addr.roadAddress || roadAddress,
          jibunAddress: addr.jibunAddress || jibunAddress,
          x: addr.x,
          y: addr.y,
        },
      });
    } catch (err) {
      if (err instanceof NaverApiError) {
        return res.status(err.statusCode).json({ message: err.message });
      }
      throw err;
    }
  }),
);

export default router;
