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
