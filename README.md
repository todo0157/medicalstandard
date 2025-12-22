# Hanbang App

Flutter + Node/Prisma stack for the 한방 방문 진료 MVP.

## What changed in ver1.3.9.4
- **진료 예약 및 채팅 연동 강화**:
  - 진료 예약 시 해당 한의사와의 채팅방 자동 생성 로직 구현
  - 예약 시 입력한 '증상 및 요청사항'을 채팅방 첫 메시지로 자동 전달 (`[신규 진료 예약]` 말머리)
  - 예약 수정 시 변경된 내용을 채팅방에 자동으로 알림 (`[진료 예약 수정]` 말머리)
  - 예약 수정 중 한의사 변경 시, 이전 한의사와의 채팅 내역 자동 삭제 및 새 채팅방 생성 기능
- **한의사 노출 관리 로직 개선**:
  - `Doctor` 모델에 `isVerified` 필드 도입 및 데이터베이스 마이그레이션 적용
  - 관리자 대시보드에서 인증 거부 시, 한의사 찾기 목록에서 즉시 제외되도록 필터링 강화
  - 기존 데이터 전수 조사를 통한 인증 상태와 노출 상태 동기화 완료
- **사용자 경험(UX) 개선**:
  - 예약 수정 중 한의사 선택 시 채팅 내역 삭제에 대한 안내 팝업(AlertDialog) 추가
  - 채팅방 초기 자동 안내 메시지를 실제 예약 정보로 대체하여 가독성 향상

## What changed in ver1.3.9.3
- **채팅 목록 자동 새로고침 최적화**: 채팅 목록 화면이 활성화되어 있을 때만 자동 새로고침 (10초 간격)
  - 채팅 화면으로 이동 시 자동 새로고침 중지하여 입력 방해 최소화
  - 화면 활성화 상태 추적을 위한 `ModalRoute.isCurrent` 사용
- **읽지 않은 메시지 수 표시 기능 개선**: UI 모드(환자/한의사)에 따라 정확한 읽지 않은 메시지 수 표시
  - 서버 API에 UI 모드 파라미터 추가 (`?uiMode=patient|practitioner`)
  - 환자 모드: 한의사가 보낸 읽지 않은 메시지 수 표시
  - 한의사 모드: 환자가 보낸 읽지 않은 메시지 수 표시
- **서버 API 개선**: 
  - `GET /api/chat/sessions?uiMode=patient|practitioner` - UI 모드에 따라 unreadCount 계산
  - `GET /api/chat/sessions/:id/messages?uiMode=patient|practitioner` - UI 모드에 따라 읽음 처리
- **클라이언트 서비스 개선**:
  - `ChatService.fetchSessions(isPractitionerMode)` - UI 모드 전달
  - `ChatService.fetchMessages(sessionId, isPractitionerMode)` - UI 모드 전달
  - `chatSessionsProvider`에서 `uiModeProvider`를 읽어 서버에 전달
- **채팅 목록 UI 개선**: 읽지 않은 메시지 수 배지 표시 (환자 모드: 초록색, 한의사 모드: 파란색)

## What changed in ver1.3.9.2
- **한의사 인증 프로세스 구현**: 한의사 인증 신청 화면 구현 (자격증 번호, 클리닉 이름, 자격증 이미지 업로드)
- **프로필 화면 인증 상태 표시**: 프로필 화면에 한의사 인증 상태 카드 추가 (대기 중/승인됨/거부됨)
- **관리자 대시보드 구현**: HTML/JavaScript 기반 관리자 대시보드 구현 (로그인, 인증 신청 목록, 상세 정보, 승인/거부)
- **관리자 API 구현**: 관리자 전용 API 엔드포인트 구현 (`/api/admin/certifications`)
  - 인증 신청 목록 조회 (필터링: 대기 중/승인됨/전체)
  - 인증 신청 상세 정보 조회
  - 인증 승인/거부 기능
- **승인/거부 기능 개선**: 모든 상태(pending/verified/none)에서 승인/거부 가능하도록 개선
- **데이터베이스 스키마 확장**: UserProfile 모델에 `licenseNumber`, `clinicName` 필드 추가
- **날짜 표시 수정**: 신청 일시를 `createdAt` 대신 `updatedAt` 사용 (실제 인증 신청 시점 반영)
- **이미지 표시 개선**: data URL 형식 이미지 지원 및 XSS 방지 처리
- **로그인/로그아웃 기능 개선**: 이벤트 리스너 기반 처리로 안정성 향상
- **로그인 화면 개선**: 이미 로그인된 경우 자동으로 대시보드로 리다이렉트

## What changed in ver1.3.9.4 (analysis)
- **배포 환경 우편번호 검색 지원**: Docker 및 배포 환경에서 우편번호 검색 기능이 정상 작동하도록 개선
- **Dockerfile 최적화**: 프로젝트 루트를 build context로 설정하여 Git LFS 파일 자동 다운로드
- **PostalCodeService 경로 개선**: Docker 환경(`/app/search_number`) 경로 추가 및 경로 탐색 로직 개선
- **배포 문서 업데이트**: Render/EC2 배포 시 Git LFS 사용 안내 추가

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

**Note**: 우편번호 검색 기능을 사용하려면 `search_number/` 폴더의 우편번호 DB 파일이 필요합니다. 이 파일들은 Git LFS로 관리되므로:

**로컬 개발 환경:**
```bash
git lfs install
git lfs pull
```

**배포 환경:**
- Docker를 사용하는 경우: Dockerfile에 Git LFS 설치 및 pull이 포함되어 있습니다.
- 직접 배포하는 경우: 배포 전에 `git lfs pull`을 실행하여 우편번호 DB 파일을 다운로드하세요.
- 또는 `npm run setup` 명령어를 실행하세요 (자동으로 Git LFS 설치 및 파일 다운로드).

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

상세한 분석과 개선 계획은 [docs/ver1.3.9.4_analysis_and_improvements.md](docs/ver1.3.9.4_analysis_and_improvements.md)를 참고하세요.

## 📱 Android & iOS 환경 배포 계획
상세한 배포 계획과 업데이트 전략은 [android_ios_deployment_plan.md](docs/android_ios_deployment_plan.md)를 참고하세요.
