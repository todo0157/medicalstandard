# Android & iOS 환경 배포 계획

## 🎯 MVP 출시 목표

다음 4가지 핵심 기능을 MVP 수준으로 구현하여 Google Play Store와 App Store에 출시:

1. **회원가입 및 한의사 인증**
   - 현재 상태: 기본 회원가입/로그인 완료, 한의사 인증 프로세스 미구현
   - 출시 전 필요 작업: 한의사 인증 신청 UI 및 프로세스 구현

2. **한의사 찾기 및 예약 기능**
   - 현재 상태: ✅ 구현 완료
   - 기능: 위치 기반 검색, 주소 검색, 우편번호 검색, 예약 생성/취소

3. **채팅 화면**
   - 현재 상태: ✅ 구현 완료
   - 기능: WebSocket 기반 실시간 채팅, 메시지 전송/수신

4. **프로필 내 진료 기록 확인 기능**
   - 현재 상태: ✅ 구현 완료
   - 기능: 진료 기록 조회, 진료 기록 생성 (한의사만)

---

## 📋 Android 배포 준비

### 1. 앱 정보 설정

**필수 변경 사항:**
```kotlin
// android/app/build.gradle.kts
defaultConfig {
    applicationId = "com.medicalstandard.hanbang"  // 실제 패키지명으로 변경
    versionCode = 1  // 첫 출시는 1
    versionName = "1.0.0"
    minSdk = 21  // Android 5.0 이상
    targetSdk = 34  // 최신 Android 버전
}
```

**앱 아이콘 및 스플래시 화면:**
- `android/app/src/main/res/` 폴더에 아이콘 리소스 추가
- 다양한 해상도 지원 (mipmap-hdpi, mipmap-xhdpi, mipmap-xxhdpi, mipmap-xxxhdpi)

### 2. 서명 키 생성 및 설정

```bash
# 키스토어 생성
keytool -genkey -v -keystore ~/hanbang-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias hanbang

# key.properties 파일 생성 (android/key.properties)
storePassword=<키스토어 비밀번호>
keyPassword=<키 비밀번호>
keyAlias=hanbang
storeFile=<키스토어 파일 경로>
```

**build.gradle.kts 수정:**
```kotlin
// android/app/build.gradle.kts
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 3. 권한 설정

**AndroidManifest.xml 확인:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### 4. 프로덕션 빌드

```bash
# AAB (Android App Bundle) 빌드 (권장)
flutter build appbundle \
  --dart-define APP_ENV=production \
  --dart-define API_BASE_URL=https://api.medicalstandard.dev/api \
  --release

# 또는 APK 빌드
flutter build apk \
  --dart-define APP_ENV=production \
  --dart-define API_BASE_URL=https://api.medicalstandard.dev/api \
  --release \
  --split-per-abi
```

### 5. Google Play Console 등록

**필수 준비물:**
- Google Play Developer 계정 ($25 일회성 등록비)
- 앱 아이콘 (512x512px)
- 스크린샷 (최소 2개, 권장 8개)
- 앱 설명 (한국어, 영어)
- 개인정보처리방침 URL
- 연락처 정보

**등록 절차:**
1. [Google Play Console](https://play.google.com/console) 접속
2. 새 앱 생성
3. 앱 정보 입력 (이름, 설명, 카테고리 등)
4. 콘텐츠 등급 설정
5. AAB 파일 업로드
6. 스토어 등록 정보 입력
7. 검토 제출

---

## 🍎 iOS 배포 준비

### 1. 앱 정보 설정

**필수 변경 사항:**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>com.medicalstandard.hanbang</string>  <!-- 실제 번들 ID로 변경 -->
<key>CFBundleName</key>
<string>한방</string>
<key>CFBundleDisplayName</key>
<string>한방</string>
```

**Xcode 프로젝트 설정:**
- `ios/Runner.xcodeproj` 열기
- General 탭에서 Bundle Identifier 변경
- Version 및 Build 번호 설정

### 2. Apple Developer 계정 및 인증서

**필수 준비물:**
- Apple Developer Program 가입 ($99/년)
- App Store Connect 계정 생성
- 인증서 및 프로비저닝 프로파일 생성

**인증서 생성:**
1. [Apple Developer Portal](https://developer.apple.com) 접속
2. Certificates, Identifiers & Profiles 메뉴
3. App ID 생성 (Bundle Identifier와 일치)
4. Distribution Certificate 생성
5. App Store Connect에서 App 생성
6. Provisioning Profile 생성

### 3. 권한 설정

**Info.plist 권한 설명 추가:**
```xml
<!-- ios/Runner/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>한의사를 찾기 위해 위치 정보가 필요합니다.</string>
<key>NSCameraUsageDescription</key>
<string>프로필 사진을 업로드하기 위해 카메라 접근이 필요합니다.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>프로필 사진을 선택하기 위해 사진 라이브러리 접근이 필요합니다.</string>
```

### 4. 프로덕션 빌드

```bash
# iOS 빌드 (Xcode 필요)
flutter build ios \
  --dart-define APP_ENV=production \
  --dart-define API_BASE_URL=https://api.medicalstandard.dev/api \
  --release

# Xcode에서 아카이브 및 업로드
# 1. Xcode에서 ios/Runner.xcworkspace 열기
# 2. Product > Archive
# 3. Organizer에서 Distribute App 선택
# 4. App Store Connect 선택
# 5. 업로드 완료
```

**또는 명령줄에서:**
```bash
# IPA 파일 생성 (fastlane 사용 권장)
fastlane ios build
fastlane ios upload
```

### 5. App Store Connect 등록

**필수 준비물:**
- 앱 아이콘 (1024x1024px, 투명 배경 없음)
- 스크린샷 (iPhone 6.7", 6.5", 5.5" 등 다양한 크기)
- 앱 설명 (한국어, 영어)
- 개인정보처리방침 URL
- 연락처 정보
- 연령 등급 정보

**등록 절차:**
1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. 새 앱 생성
3. 앱 정보 입력
4. 빌드 선택 (업로드된 빌드)
5. 스토어 등록 정보 입력
6. 검토 제출

---

## ✅ MVP 출시 전 체크리스트

### 필수 기능 완성도 확인

- [ ] **회원가입 및 한의사 인증**
  - [ ] 기본 회원가입/로그인 테스트 완료
  - [ ] 한의사 인증 신청 UI 구현
  - [ ] 한의사 인증 프로세스 구현 (최소한 기본 워크플로우)
  - [ ] 인증 상태 표시 UI

- [ ] **한의사 찾기 및 예약 기능**
  - [ ] 위치 기반 검색 테스트
  - [ ] 주소 검색 테스트
  - [ ] 예약 생성/취소 테스트
  - [ ] 예약 목록 조회 테스트

- [ ] **채팅 화면**
  - [ ] 실시간 메시지 전송/수신 테스트
  - [ ] WebSocket 연결 안정성 확인
  - [ ] 오프라인 상태 처리

- [ ] **진료 기록 확인 기능**
  - [ ] 진료 기록 조회 테스트
  - [ ] 한의사 진료 기록 생성 테스트
  - [ ] 권한 검증 확인

### 기술적 준비사항

- [ ] 프로덕션 서버 배포 완료
- [ ] API 엔드포인트 프로덕션 URL 설정
- [ ] 환경 변수 설정 (`APP_ENV=production`)
- [ ] 디버그 로그 비활성화
- [ ] 에러 리포팅 설정 (Sentry, Firebase Crashlytics 등)
- [ ] 분석 도구 연동 (Firebase Analytics, Google Analytics 등)

### 보안 및 법적 준비사항

- [ ] 개인정보처리방침 작성 및 게시
- [ ] 이용약관 작성 및 게시
- [ ] 서비스 약관 작성
- [ ] API 키 보안 확인 (클라이언트에 노출되지 않도록)
- [ ] 데이터 암호화 확인

### 스토어 등록 준비사항

- [ ] 앱 아이콘 제작 (Android: 512x512px, iOS: 1024x1024px)
- [ ] 스크린샷 제작 (최소 2개, 권장 8개 이상)
- [ ] 앱 설명 작성 (한국어, 영어)
- [ ] 앱 이름 결정
- [ ] 카테고리 선택
- [ ] 연령 등급 설정
- [ ] 연락처 정보 준비

---

## 🔄 업데이트 계획

### 버전 관리 전략

**버전 번호 형식:** `MAJOR.MINOR.PATCH+BUILD`
- **MAJOR**: 큰 기능 변경 또는 API 변경
- **MINOR**: 새로운 기능 추가
- **PATCH**: 버그 수정
- **BUILD**: 빌드 번호 (자동 증가)

**예시:**
- 첫 출시: `1.0.0+1`
- 버그 수정: `1.0.1+2`
- 기능 추가: `1.1.0+3`
- 큰 변경: `2.0.0+4`

### 업데이트 주기 계획

**Phase 1: MVP 출시 (v1.0.0)**
- 목표: 4가지 핵심 기능 완성
- 예상 기간: 2-3주
- 주요 작업: 한의사 인증 프로세스 구현

**Phase 2: 안정화 (v1.0.x)**
- 목표: 버그 수정 및 사용자 피드백 반영
- 예상 기간: 2-4주
- 업데이트 주기: 1-2주마다

**Phase 3: 기능 확장 (v1.1.0+)**
- 목표: 추가 기능 구현
  - 알림 시스템
  - 리뷰 및 평점
  - 예약 관리 강화
- 예상 기간: 4-6주
- 업데이트 주기: 2-3주마다

**Phase 4: 최적화 (v1.2.0+)**
- 목표: 성능 최적화 및 UX 개선
- 예상 기간: 2-3주
- 업데이트 주기: 필요시

### 업데이트 프로세스

1. **개발 및 테스트**
   ```bash
   # 개발 환경에서 테스트
   flutter run --dart-define APP_ENV=staging
   
   # 스테이징 서버에서 테스트
   flutter run --dart-define APP_ENV=staging \
     --dart-define API_BASE_URL=https://staging.api.medicalstandard.dev/api
   ```

2. **프로덕션 빌드**
   ```bash
   # Android
   flutter build appbundle --dart-define APP_ENV=production
   
   # iOS
   flutter build ios --dart-define APP_ENV=production
   ```

3. **스토어 업로드**
   - Android: Google Play Console에서 AAB 업로드
   - iOS: App Store Connect에서 빌드 업로드

4. **검토 대기**
   - Android: 보통 1-3일
   - iOS: 보통 1-7일

5. **출시**
   - 단계적 출시 (10% → 50% → 100%) 권장
   - 문제 발견 시 즉시 롤백 가능

---

## 📝 참고 자료

- [Flutter 공식 배포 가이드](https://docs.flutter.dev/deployment)
- [Google Play Console 가이드](https://support.google.com/googleplay/android-developer)
- [App Store Connect 가이드](https://developer.apple.com/app-store-connect/)
- [Android 서명 가이드](https://docs.flutter.dev/deployment/android#signing-the-app)
- [iOS 배포 가이드](https://docs.flutter.dev/deployment/ios)

---

## ⚠️ 주의사항

1. **패키지명/번들 ID 변경**: 현재 `com.example.hanbang_app`는 예시용이므로 실제 배포 전 반드시 변경 필요
2. **API 키 보안**: 클라이언트에 노출되는 API 키는 최소화하고, 가능한 한 서버를 통해 프록시
3. **개인정보 보호**: 위치 정보, 프로필 사진 등 개인정보 처리 시 개인정보처리방침에 명시
4. **테스트**: 실제 기기에서 충분한 테스트 후 출시
5. **백업 계획**: 서버 장애 시 대응 방안 마련

---

**목표 출시일**: MVP 기능 완성 후 2-3주 내 (스토어 검토 기간 포함)

