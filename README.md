# Hanbang App

Flutter application for 한방 방문 진료.

## Quick Start

```bash
flutter pub get
flutter run --dart-define APP_ENV=development
```

## Build with Real Backend

| Variable | Description | Example |
| --- | --- | --- |
| `APP_ENV` | `development`, `staging`, or `production` | `production` |
| `API_BASE_URL` | Overrides the default host for the selected environment | `https://api.medicalstandard.dev` |
| `ENABLE_MOCK_SERVICES` | Forces UI to use mock data regardless of env | `false` |
| `ENABLE_HTTP_LOGGING` | Enables verbose API logging in `ApiClient` | `false` |

## Local database (Prisma + SQLite)

The Node API now reads and writes real data through Prisma. For fast local
development we default to SQLite, stored at `server/prisma/dev.db`, and we can
swap the same schema to Postgres later.

```bash
cd server
npm install
npm run db:migrate      # creates prisma/migrations + dev.db
npm run db:seed         # inserts the default user_123 profile
npm run build && npm start
```

- Configuration lives in `server/.env`. The default value
  `DATABASE_URL=file:./dev.db` points to the SQLite file next to `schema.prisma`.
- To target Postgres later, change `DATABASE_URL` to your Postgres connection
  string, run `npm run db:migrate` (or `npx prisma migrate deploy` in CI),
  then `npm run db:seed` if you want the demo data.
- Helpful scripts:
  - `npm run db:push` – sync the schema without creating a migration
  - `npm run db:migrate` – create/apply a migration
  - `npm run db:seed` – run `prisma/seed.ts` via `ts-node`

### Android Release

```bash
flutter build apk \
  --dart-define APP_ENV=production \
  --dart-define ENABLE_MOCK_SERVICES=false
```

### iOS Release

```bash
flutter build ipa \
  --dart-define APP_ENV=production \
  --dart-define ENABLE_MOCK_SERVICES=false
```

Additional deployment items can be found in `docs/deployment_checklist.md`.

## Backend plan

Firebase prototypes were removed in favor of a pure Node/Express API hosted on
Render (free tier) and later migratable to AWS EC2. Follow
`docs/node_render_backend.md` to scaffold the server, configure environment
variables, and deploy using a custom domain such as `api.medicalstandard.dev`.

## 나중에 해야 할 작업
### 1. 회원가입/카카오 인증 관련
- JWT 만료 시 `/auth/refresh` 연동: 프런트에서 401 발생 시 자동 갱신, 실패 시 로그아웃 처리
- 로그아웃 기능 추가: 액세스/리프레시 토큰 삭제, 상태 초기화
- 보호 라우트 강화: 백엔드 보호 라우트에 `authenticate` 미들웨어 적용, 프런트는 토큰 없을 때 로그인/회원가입으로 리다이렉트
- PASS 버튼 동작 연결 또는 “준비 중” 안내 처리
- Kakao 완료 후 초기 프로필/주소 보강 흐름, 약관 링크 실제 내용 연결
