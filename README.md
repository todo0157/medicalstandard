# Hanbang App

Flutter + Node/Prisma stack for the 한방 방문 진료 MVP.

## What changed in ver1.3.9
- **우편번호 검색 기능**: 로컬 우편번호 DB 통합으로 우편번호 검색 기능 추가
- **PostalCodeService 구현**: TSV 형식 우편번호 파일 파싱 및 검색 서비스 구현
- **타임아웃 설정 최적화**: 우편번호 검색용 30초 타임아웃 추가 (기본 12초)
- **세부 주소 입력**: 주소 선택 후 상세 주소(동/호수 등) 입력 기능 추가
- **에러 처리 개선**: 상세한 에러 로깅 및 디바운싱 로직 개선
- **API 엔드포인트 추가**: `/api/addresses/geocode` 엔드포인트 추가 (주소 문자열로 좌표 조회)

## What changed in ver1.3.8
- **네이버 지도 API 통합**: 주소 검색(Geocoding) 및 역지오코딩(Reverse Geocoding) 기능 추가
- **주소 검색 UI**: 실시간 주소 검색 화면 구현, 디바운싱 및 최소 검색어 길이 제한 적용
- **예약 화면 통합**: 예약 화면에서 주소 선택 및 변경 기능 추가
- **서버 API 엔드포인트**: `/api/addresses/search`, `/api/addresses/reverse` 엔드포인트 구현
- **공식 문서 기준 수정**: 네이버 지도 API 공식 문서에 맞춰 엔드포인트 URL, 헤더, 응답 파싱 수정
- **에러 처리 개선**: API 키 및 Application 설정 관련 상세한 에러 메시지 및 트러블슈팅 가이드 제공

## What changed in ver1.3.7
- Appointment booking 화면이 실제 Doctor/Slot API와 연동되어 동일한 데이터 모델을 사용합니다.
- 실시간 채팅용 WebSocket 게이트웨이(`/ws/chat`)를 추가하고 Flutter 채팅 화면에서 수신 스트림을 사용합니다.
- 프로필 사진 업로드·인증 상태 갱신 API가 추가되었고, 의료진만 진료 기록을 생성할 수 있도록 서버 권한 검증을 강화했습니다.
- 앱/서버 공통 환경 개선: WS URL 자동 추론, Mock 프로필 fallback 제거, 버전 `ver1.3.7`.
- **프로필 저장 버그 수정**: `/profiles/me` 엔드포인트 사용 및 서버 스키마에 맞는 데이터 전송으로 프로필 업데이트가 정상 작동하도록 수정.

## What changed in ver1.3.6
- Added pre-signup email verification flow (precheck token required before signup).
- Added password-reset link from login screen; email links open the reset page.
- Hooked Flutter routes for `/verify-pre`, `/verify-email`, `/reset-password`.
- SendGrid wiring documented; server env keys aligned for local Flutter web.

## Quick start

### Server (Node/Prisma)
```bash
cd server
npm install
npm run db:migrate
npm run build
npm start    # runs on http://localhost:8080
```

Set `server/.env` (copy from `.env.example`):
- `SENDGRID_API_KEY`, `MAIL_FROM`, `MAIL_FROM_NAME`
- `RESET_LINK_BASE`, `VERIFY_LINK_BASE`, `VERIFY_PRE_LINK_BASE`  
  e.g. for local Flutter web: `http://localhost:5173/reset-password`, `http://localhost:5173/verify-email`, `http://localhost:5173/verify-pre`

### Flutter web
```bash
flutter pub get
flutter run -d chrome --web-port 5173 \
  --dart-define API_BASE_URL=http://localhost:8080/api \
  --dart-define APP_ENV=development \
  --dart-define ENABLE_HTTP_LOGGING=true
```

## Email flows (local)
- **Pre-signup verify:** Login screen “인증” button → `/auth/verify-email/precheck` sends email → click link (opens `/verify-pre?...`) → signup allowed only for that verified email.
- **Post-signup verify resend:** `/auth/verify-email` always sends (even if already verified).
- **Password reset:** Login screen “비밀번호 재설정하기” → `/auth/forgot` email → link opens `/reset-password?...` → submit new password → `/auth/reset`.

## Notes
- Prisma DB stored at `server/prisma/dev.db` by default (SQLite). Update `DATABASE_URL` for Postgres when ready.
- Protects signup server-side: `/auth/signup` returns 400 if the email has not completed precheck.
- Routes for reset/verify/pre-verify are allowed without auth; other app routes still require the token guard.

## ver1.3.7 작업 참고 사항
1. `AppointmentBookingScreen`은 가장 최근 등록된 한의사/슬롯 데이터를 순차로 노출합니다. 지도 기반 탐색이 필요한 경우 `FindDoctorScreen`을 유지하면서 동일 서비스/노티파이어를 공유하도록 확장하세요.
2. 실시간 채팅은 WebSocket 수신 기반입니다. 메시지 송신은 기존 REST API를 사용하며, 서버가 저장하는 즉시 WebSocket으로 push 됩니다.
3. 프로필 사진 업로드는 임시로 Data URL을 DB에 저장합니다. 파일 스토리지 혹은 CDN을 붙일 경우 `profile.routes.ts` 내 업로드 로직을 교체하면 됩니다.
4. **프로필 저장 버그 수정**: `/profiles/me` 엔드포인트 사용 및 서버 스키마에 맞는 데이터 전송으로 프로필 업데이트가 정상 작동하도록 수정.

## 📊 코드베이스 분석 및 개선 계획
상세한 분석과 개선 계획은 [ver1.3.7_analysis_and_improvements.md](docs/ver1.3.7_analysis_and_improvements.md)를 참고하세요.
