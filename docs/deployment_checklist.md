# Deployment Readiness Checklist

This checklist tracks the configuration items and verifications that must be
completed before shipping the **Hanbang App** to production stores.

## 1. Backend & Environment
- [ ] Confirm the production API base URL matches the current release target.
- [ ] Issue real client credentials (Kakao, payment providers, push, etc.) per environment.
- [ ] Configure build-time values:
  - `APP_ENV` (`development`, `staging`, `production`)
  - `API_BASE_URL` overrides (only when pointing to a custom host)
  - `ENABLE_MOCK_SERVICES=false`
  - `ENABLE_HTTP_LOGGING=false`
- [ ] Run the end-to-end validation script in `docs/api_validation.md` using the
      target environment (staging, then production).

## 2. Authentication & Secrets
- [ ] Register the release SHA fingerprints with Kakao.
- [ ] Store all OAuth tokens/refresh tokens using a secure storage solution.
- [ ] Disable verbose logging (`debugPrint`) in release profile.

## 3. Quality Gates
- [ ] `flutter analyze` and `flutter test` succeed with zero warnings.
- [ ] Add widget/integration tests for core user journeys (login → booking → chat).
- [ ] Conduct manual QA for both Korean and English locales.

## 4. Client Distribution
- [ ] Prepare store assets (icons, screenshots, descriptions).
- [ ] Configure fastlane or CI pipeline to build signed APK/AAB and IPA.
- [ ] Verify crash reporting/analytics (Sentry, Firebase) captures a smoke session.

## 5. Documentation
- [ ] Keep `README.md` updated with build commands and environment variable list.
- [ ] Update this checklist on every release tag (e.g., `ver1.2.4`).

> Tip: run `flutter build apk --dart-define APP_ENV=production` (Android) and
`flutter build ipa --dart-define APP_ENV=production` (iOS) to ensure the release
flavor is identical to production at runtime.
