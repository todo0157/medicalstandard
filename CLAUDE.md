# Hanbang Medical App (한방 의료 앱)

## Project Overview
한방(한의학) 진료 예약, 채팅 상담, 의료 기록 관리를 위한 풀스택 모바일/웹 앱.

- **Frontend**: Flutter (Dart) — Riverpod 상태관리, GoRouter 내비게이션, Freezed 모델
- **Backend**: Node.js + Express (TypeScript) — Prisma ORM (SQLite), JWT 인증, WebSocket 채팅
- **External**: Firebase Cloud Messaging, Kakao OAuth, AWS S3, SendGrid, Naver Map API

## Project Structure

```
medicalstandard/
├── lib/                          # Flutter 앱
│   ├── main.dart                 # 앱 진입점
│   ├── app_router.dart           # GoRouter 라우팅 (pageBuilder 통일)
│   ├── core/
│   │   ├── models/               # Freezed 데이터 모델
│   │   ├── services/             # API 클라이언트, 인증, 채팅 등 서비스
│   │   └── providers/            # Riverpod 프로바이더
│   ├── features/                 # 기능별 화면 (auth, booking, chat, doctor, home 등)
│   └── shared/                   # 공통 위젯, 테마, 디자인 시스템
├── server/                       # Express API 서버
│   ├── src/
│   │   ├── server.ts             # Express 앱 설정 + 서버 시작
│   │   ├── config.ts             # 환경변수 검증 (Zod)
│   │   ├── routes/               # API 라우트 핸들러
│   │   ├── services/             # 비즈니스 로직 레이어
│   │   ├── middleware/           # 인증, 유효성 검사, 관리자 미들웨어
│   │   ├── lib/                  # 유틸 (logger, AppError, S3, FCM, Prisma)
│   │   └── types/                # 타입 정의
│   ├── prisma/
│   │   └── schema.prisma         # DB 스키마
│   └── package.json
└── search_number/                # 우편번호 데이터 (Git LFS)
```

## Key Architecture Patterns

### Server Middleware
- **`asyncHandler`** — 라우트 핸들러의 try/catch 보일러플레이트 제거
- **`validateBody(schema)` / `validateQuery(schema)`** — Zod 스키마 기반 요청 유효성 검사
- **`resolvePractitionerDoctor`** — 인증된 한의사의 Doctor 레코드 자동 해석 (clinicName 기반 동명이인 구분)
- **`authenticate`** — JWT Bearer 토큰 검증
- **`requireAdmin`** — ADMIN_EMAILS 기반 관리자 권한 확인

### Server Services
- **`appointment.service`** — 예약 생성/수정/삭제 비즈니스 로직
- **`chat.service`** — 채팅 세션/메시지 CRUD
- **`notification.service`** — FCM 푸시 알림 전송 헬퍼
- **`auth.service`** — 회원가입, 로그인, 카카오 OAuth, 토큰 발급

### Error Handling
- **`AppError`** 클래스 (`lib/app-error.ts`) — HTTP 상태코드 + 에러코드 포함
- **`Errors`** 팩토리 — `Errors.invalidCredentials()`, `Errors.emailAlreadyExists()` 등
- 글로벌 에러 핸들러가 `AppError` 인스턴스를 자동으로 구조화된 JSON 응답으로 변환

### Logging
- **`logger`** (`lib/logger.ts`) — `LOG_LEVEL` 환경변수 기반 레벨 필터링 (debug/info/warn/error)
- 모든 서버 코드에서 `console.*` 대신 `logger.*` 사용

### Flutter Auth Flow
- `AuthSession` — SharedPreferences 기반 토큰 저장/복원 (싱글톤)
- `AuthState` — `ChangeNotifier`로 GoRouter의 `refreshListenable` 연동
- `app_router.dart`의 `redirect`에서 인증 가드 처리

## Commands

### Server
```bash
cd server
npm install                  # 의존성 설치
npm run build                # prisma generate + tsc 빌드
npm start                    # dist/server.js 실행
npx tsc --noEmit             # 타입 체크
npx prisma db push           # 스키마를 DB에 반영
npx prisma migrate dev       # 마이그레이션 생성/적용
```

### Flutter
```bash
flutter pub get              # 의존성 설치
flutter analyze              # 정적 분석
flutter run                  # 앱 실행
dart run build_runner build  # Freezed/json_serializable 코드 생성
```

## Conventions
- 커밋 메시지: `feat(scope): 설명` / `fix(scope): 설명` / `refactor(scope): 설명`
- 서버 라우트: `/api` 아래에만 마운트 (예: `/api/auth/login`)
- 인증 불필요 경로: `_unauthenticatedPaths` 집합에 정의 (`app_router.dart`)
- Flutter 라우트: 모두 `pageBuilder` 사용 (builder 사용 금지)
- 서버 환경변수: `.env` 파일 (`.gitignore`에 포함, `.env.example` 참고)
- 한의사 매칭: `UserProfile.name` ↔ `Doctor.name` + `clinicName` 교차 검증

## Important Notes
- DB: SQLite (로컬 개발), Prisma ORM
- `server/dist/`는 `.gitignore`에 포함 — 커밋하지 않음
- `firebase-service-account.json`은 시크릿 — 절대 커밋하지 않음
- `search_number/` 폴더는 Git LFS로 관리
- 사용자에게 한국어로 응답
