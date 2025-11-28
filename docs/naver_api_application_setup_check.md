# 네이버 지도 API Application 설정 확인 가이드

## 🔍 문제 상황

Maps 서비스는 구독되어 있지만 여전히 401 "Permission Denied" 에러가 발생하는 경우, **Application에 API가 등록되지 않았을 수 있습니다.**

---

## ✅ 해결 방법: Application에 API 등록 확인

### Step 1: Application 상세 페이지 접속

1. [네이버 클라우드 플랫폼 콘솔](https://console.ncloud.com/)에 로그인
2. **"Services"** → **"Maps"** → **"Application"** 클릭
3. Application 목록에서 **"hanbang"** 클릭

### Step 2: API 설정 확인

Application 상세 페이지에서 다음을 확인:

#### 2-1. "API 설정" 또는 "서비스 등록" 탭 확인

1. Application 상세 페이지에서 **"API 설정"** 또는 **"서비스 등록"** 탭 클릭
2. 다음 API가 **등록되어 있는지** 확인:
   - ✅ **Geocoding** (주소 → 좌표)
   - ✅ **Reverse Geocoding** (좌표 → 주소)

#### 2-2. API가 등록되지 않았다면

1. **"API 추가"** 또는 **"서비스 등록"** 버튼 클릭
2. 다음 API를 선택:
   - ✅ **Geocoding**
   - ✅ **Reverse Geocoding**
3. **"등록"** 또는 **"추가"** 버튼 클릭
4. 등록 완료 메시지 확인

### Step 3: 구독 서비스 확인

1. **"구독 서비스"** 또는 **"Subscribed Services"** 탭 클릭
2. 다음 서비스가 **"구독됨"** 또는 **"Subscribed"** 상태인지 확인:
   - ✅ **Geocoding**
   - ✅ **Reverse Geocoding**

### Step 4: 인증 정보 확인

1. **"인증 정보"** 탭 클릭
2. 다음 정보 확인:
   - **Client ID**: `vdpb7wt973` (또는 발급받은 값)
   - **Client Secret**: `3g0oBg1JHqgzGlbe3G9P1T5hwBWxN3129pDmMVXh` (또는 발급받은 값)
3. 서버의 `.env` 파일과 일치하는지 확인:
   ```env
   NAVER_MAP_CLIENT_ID=vdpb7wt973
   NAVER_MAP_CLIENT_SECRET=3g0oBg1JHqgzGlbe3G9P1T5hwBWxN3129pDmMVXh
   ```

### Step 5: 서비스 환경 확인

1. **"서비스 환경"** 또는 **"Service Environment"** 탭 클릭
2. **"Web 서비스 URL"** 확인:
   - 현재: `http://localhost:5173`
   - 개발 환경에서는 `localhost` 사용 가능
   - 프로덕션 환경에서는 실제 도메인 설정 필요

---

## 🔧 추가 확인 사항

### 1. API 키 형식 확인

서버 로그에서 다음을 확인:
```
[Naver Map API] Client ID: vdpb...
[Naver Map API] Client ID length: 10
[Naver Map API] Client Secret length: 40
```

- Client ID는 보통 10자리
- Client Secret은 보통 40자리

### 2. 환경 변수 확인

서버의 `.env` 파일 위치: `server/.env`

```env
NAVER_MAP_CLIENT_ID=vdpb7wt973
NAVER_MAP_CLIENT_SECRET=3g0oBg1JHqgzGlbe3G9P1T5hwBWxN3129pDmMVXh
```

**주의사항:**
- 앞뒤 공백이 없어야 함
- 따옴표 없이 입력
- 줄바꿈 없이 한 줄로 입력

### 3. 서버 재시작

환경 변수를 변경했다면 서버를 재시작:

```powershell
cd C:\Users\thf56\Documents\medicalstandard\server
npm start
```

---

## 📋 체크리스트

다음 사항을 모두 확인하세요:

- [ ] 네이버 클라우드 플랫폼 콘솔에서 Application "hanbang" 확인
- [ ] Application의 "API 설정" 탭에서 **Geocoding** API 등록 확인
- [ ] Application의 "API 설정" 탭에서 **Reverse Geocoding** API 등록 확인
- [ ] Application의 "구독 서비스" 탭에서 **Geocoding** 구독 확인
- [ ] Application의 "구독 서비스" 탭에서 **Reverse Geocoding** 구독 확인
- [ ] Application의 "인증 정보" 탭에서 Client ID와 Client Secret 확인
- [ ] 서버의 `.env` 파일에 환경 변수가 올바르게 설정되어 있는지 확인
- [ ] 서버 재시작 완료
- [ ] 서버 로그에서 API 키가 올바르게 로드되는지 확인

---

## 🆘 여전히 문제가 발생한다면

### 1. 네이버 클라우드 플랫폼 고객 지원

위의 모든 사항을 확인했음에도 문제가 지속된다면:
- 네이버 클라우드 플랫폼 고객 지원에 문의
- 에러 코드 `210`과 함께 문의

### 2. 대안 API 사용

네이버 지도 API가 계속 문제가 발생한다면:
- 카카오 주소 검색 API 사용: `docs/address_api_alternatives.md` 참고
- 공공데이터포털 주소 검색 API 사용: `docs/address_api_alternatives.md` 참고

---

**Application에 API를 등록한 후 주소 검색을 다시 시도해보세요!** 🚀


