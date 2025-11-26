# Hanbang App

Flutter + Node/Prisma stack for the 한방 방문 진료 MVP.

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
