/**
 * Application-level error with HTTP status code.
 *
 * Throw this anywhere in services/routes, and the global error handler
 * will serialise it to a proper JSON response.
 *
 * Usage:
 *   throw new AppError(409, "EMAIL_ALREADY_EXISTS", "이미 가입된 이메일입니다.");
 */
export class AppError extends Error {
  constructor(
    /** HTTP status code (4xx / 5xx). */
    public readonly status: number,
    /** Machine-readable error code for programmatic matching. */
    public readonly code: string,
    /** Human-readable message (Korean). */
    message: string,
  ) {
    super(message);
    this.name = "AppError";
  }
}

// ─── Pre-defined factory helpers ─────────────────────────────────

export const Errors = {
  // Auth
  emailAlreadyExists: () =>
    new AppError(409, "EMAIL_ALREADY_EXISTS", "이미 가입된 이메일입니다."),
  invalidCredentials: () =>
    new AppError(401, "INVALID_CREDENTIALS", "이메일 또는 비밀번호가 올바르지 않습니다."),
  invalidRefreshToken: () =>
    new AppError(401, "INVALID_REFRESH", "유효하지 않은 리프레시 토큰입니다."),
  expiredRefreshToken: () =>
    new AppError(401, "EXPIRED_REFRESH", "리프레시 토큰이 만료되었습니다."),
  kakaoConfigMissing: () =>
    new AppError(500, "KAKAO_CONFIG_MISSING", "Kakao 설정이 누락되었습니다."),
  kakaoAuthFailed: () =>
    new AppError(401, "KAKAO_AUTH_FAILED", "Kakao 인증에 실패했습니다."),

  // General
  unauthorized: (msg = "인증 정보가 없습니다.") =>
    new AppError(401, "UNAUTHORIZED", msg),
  forbidden: (msg = "권한이 없습니다.") =>
    new AppError(403, "FORBIDDEN", msg),
  notFound: (msg = "요청한 리소스를 찾을 수 없습니다.") =>
    new AppError(404, "NOT_FOUND", msg),
  badRequest: (msg: string) =>
    new AppError(400, "BAD_REQUEST", msg),

  // Appointment
  invalidSlot: () =>
    new AppError(400, "INVALID_SLOT", "유효하지 않은 슬롯입니다."),
  appointmentNotFound: () =>
    new AppError(404, "APPOINTMENT_NOT_FOUND", "예약을 찾을 수 없습니다."),
} as const;
