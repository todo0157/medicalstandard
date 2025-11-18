# End-to-End API Validation Guide

Use this checklist before each release to prove that the Flutter client can
communicate with a live backend without falling back to local mocks.

## 1. Configure the build

```bash
flutter run \
  --dart-define APP_ENV=staging \
  --dart-define API_BASE_URL=https://api.staging.medicalstandard.dev \
  --dart-define ENABLE_MOCK_SERVICES=false \
  --dart-define ENABLE_HTTP_LOGGING=true
```

Notes:
- Replace `staging` with `production` for the final smoke test.
- `API_BASE_URL` must always be a domain (CNAME to Render/EC2), never a raw IP.
- `ENABLE_HTTP_LOGGING=true` prints every request/response in debug mode so you
  can match client actions with server logs.

## 2. Verify profile endpoints

1. Launch the app and sign in.
2. Navigate to **Profile**. In the console:
   - Expect a `GET /profiles/me` entry with a `2xx` status.
   - Confirm that the screen shows data from the backend (not the mock values).
3. Pull-to-refresh and ensure a second `GET /profiles/me` hit occurs.
4. Observe the logs for `Primary profile service failed…`. If it appears, the
   fallback mock is being used and the backend must be investigated.

Optional API sanity check via cURL (requires valid auth token):

```bash
curl -H "Authorization: Bearer <token>" \
  https://staging.api.medicalstandard.dev/profiles/me
```

## 3. Booking and chat smoke tests

Follow the same pattern for other feature areas:
- Create / update a booking and verify `POST /bookings`, `GET /bookings`.
- Open chat screens and confirm the presence of `/chat/sessions` requests.

## 4. Report the results

Record the date, environment, app version (`ver1.2.4+`), and whether each
endpoint succeeded. Attach console logs when failures occur so we can pinpoint
whether the issue is client, network, or backend related.
