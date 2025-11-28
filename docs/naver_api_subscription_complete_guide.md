# 네이버 지도 API 구독 완료 가이드

## 🚨 현재 상황

서버 로그에서 다음 에러가 확인되었습니다:

```
[Naver Map API] Error: 401 {"error":{"errorCode":"210","message":"Permission Denied","details":"A subscription to the API is required."}}
```

**문제**: 네이버 지도 API 구독이 완료되지 않았습니다.

---

## ✅ 해결 방법: Maps 서비스 구독 완료

### Step 1: 네이버 클라우드 플랫폼 콘솔 접속

1. [네이버 클라우드 플랫폼 콘솔](https://console.ncloud.com/)에 로그인
2. **"Services"** → **"Maps"** 메뉴 클릭

### Step 2: Application 확인

1. **"Application"** 탭 클릭
2. Application 목록에서 **"hanbang"** (또는 생성한 Application 이름) 확인
3. Application이 없다면 생성 필요

### Step 3: Maps 서비스 구독 확인 및 구독

#### 3-1. 구독 상태 확인

1. **"Services"** → **"Maps"** → **"Application"** → **"hanbang"** 클릭
2. **"구독 서비스"** 또는 **"Subscribed Services"** 탭 확인
3. 다음 서비스가 **"구독됨"** 또는 **"Subscribed"** 상태인지 확인:
   - ✅ **Geocoding** (주소 → 좌표)
   - ✅ **Reverse Geocoding** (좌표 → 주소)

#### 3-2. 구독이 안 되어 있다면

1. **"Services"** → **"Maps"** → **"Application"** → **"hanbang"** 클릭
2. **"구독 서비스"** 또는 **"Subscribed Services"** 탭 클릭
3. **"서비스 구독"** 또는 **"Subscribe Service"** 버튼 클릭
4. 다음 서비스를 선택:
   - ✅ **Geocoding**
   - ✅ **Reverse Geocoding**
5. **"구독"** 또는 **"Subscribe"** 버튼 클릭
6. 구독 완료 메시지 확인

### Step 4: 구독 완료 확인

1. **"구독 서비스"** 탭에서 다음이 표시되는지 확인:
   - ✅ **Geocoding**: 구독됨
   - ✅ **Reverse Geocoding**: 구독됨

### Step 5: 서버 재시작 (선택사항)

구독이 완료되면 서버를 재시작할 필요는 없지만, 혹시 모를 캐시 문제를 방지하기 위해 재시작하는 것을 권장합니다:

```powershell
# 서버 디렉토리로 이동
cd C:\Users\thf56\Documents\medicalstandard\server

# 서버 중지 (Ctrl+C)

# 서버 재시작
npm start
```

---

## 🔍 구독 완료 여부 확인 방법

### 방법 1: 서버 로그 확인

주소 검색을 시도한 후 서버 로그에서 다음을 확인:

**✅ 구독 완료된 경우:**
```
[Naver Map API] Request URL: https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울특별시
[Naver Map API] Client ID: vdpb...
[Naver Map API] Response status: { code: 0, name: 'ok', message: '정상' }
[Naver Map API] Addresses count: 10
```

**❌ 구독 미완료인 경우 (현재 상황):**
```
[Naver Map API] Error: 401 {"error":{"errorCode":"210","message":"Permission Denied","details":"A subscription to the API is required."}}
```

### 방법 2: 네이버 클라우드 플랫폼 콘솔 확인

1. **"Services"** → **"Maps"** → **"Application"** → **"hanbang"** 클릭
2. **"구독 서비스"** 탭에서:
   - ✅ **Geocoding**: 구독됨
   - ✅ **Reverse Geocoding**: 구독됨

---

## 💡 주의사항

1. **구독 완료 후 즉시 적용**: 구독이 완료되면 즉시 API를 사용할 수 있습니다. 서버 재시작은 선택사항입니다.

2. **무료 할당량**: 네이버 클라우드 플랫폼의 Maps 서비스는 무료 할당량을 제공합니다:
   - Geocoding: 월 3,000건
   - Reverse Geocoding: 월 3,000건
   - 할당량 초과 시 유료로 전환됩니다.

3. **API 키 확인**: 구독이 완료되어도 API 키가 올바르지 않으면 여전히 에러가 발생할 수 있습니다. `.env` 파일의 `NAVER_MAP_CLIENT_ID`와 `NAVER_MAP_CLIENT_SECRET`을 확인하세요.

---

## 📋 체크리스트

구독 완료 후 다음을 확인하세요:

- [ ] 네이버 클라우드 플랫폼 콘솔에서 **Geocoding** 구독 완료
- [ ] 네이버 클라우드 플랫폼 콘솔에서 **Reverse Geocoding** 구독 완료
- [ ] 서버 로그에서 401 에러가 사라지고 정상 응답이 나타나는지 확인
- [ ] 앱에서 주소 검색이 정상적으로 작동하는지 확인

---

## 🆘 여전히 문제가 발생한다면

1. **API 키 확인**: `.env` 파일의 `NAVER_MAP_CLIENT_ID`와 `NAVER_MAP_CLIENT_SECRET`이 올바른지 확인
2. **Application 확인**: 네이버 클라우드 플랫폼에서 Application이 올바르게 생성되어 있는지 확인
3. **서버 재시작**: 서버를 재시작하여 변경 사항 적용
4. **네이버 클라우드 플랫폼 고객 지원**: 위 방법으로 해결되지 않으면 네이버 클라우드 플랫폼 고객 지원에 문의

---

**구독 완료 후 주소 검색을 다시 시도해보세요!** 🚀


