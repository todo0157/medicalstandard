# 네이버 지도 API 구독 활성화 가이드

## 🚨 현재 상황

서버 로그를 보면:
- ✅ API 키는 올바르게 로드됨
- ✅ 요청 형식은 올바름
- ❌ 네이버 API가 여전히 401 "Permission Denied" 반환

**원인**: Application에 API는 등록되어 있지만, **구독이 실제로 활성화되지 않았을 가능성**이 높습니다.

---

## ✅ 해결 방법: 구독 활성화 확인 및 재구독

### Step 1: 구독 서비스 탭 확인

1. [네이버 클라우드 플랫폼 콘솔](https://console.ncloud.com/)에 로그인
2. **"Services"** → **"Maps"** → **"Application"** → **"hanbang"** 클릭
3. **"구독 서비스"** 또는 **"Subscribed Services"** 탭 클릭

### Step 2: 구독 상태 확인

다음 서비스의 상태를 확인:

#### 2-1. Geocoding 서비스
- 상태: **"구독됨"** 또는 **"Subscribed"** 또는 **"Active"** 여부 확인
- 만약 **"구독 안 됨"** 또는 **"Not Subscribed"** 또는 **"Inactive"**라면:
  - **"구독하기"** 또는 **"Subscribe"** 버튼 클릭
  - 구독 약관 동의
  - 구독 완료

#### 2-2. Reverse Geocoding 서비스
- 상태: **"구독됨"** 또는 **"Subscribed"** 또는 **"Active"** 여부 확인
- 만약 **"구독 안 됨"** 또는 **"Not Subscribed"** 또는 **"Inactive"**라면:
  - **"구독하기"** 또는 **"Subscribe"** 버튼 클릭
  - 구독 약관 동의
  - 구독 완료

### Step 3: 구독 해제 후 재구독 (필요한 경우)

구독이 되어 있는데도 작동하지 않는다면:

1. **"구독 해제"** 또는 **"Unsubscribe"** 버튼 클릭
2. 구독 해제 확인
3. **"구독하기"** 또는 **"Subscribe"** 버튼 클릭
4. 구독 약관 동의
5. 구독 완료

### Step 4: 구독 활성화 대기

구독을 완료한 후:
- **5-10분 정도 대기** (구독 활성화에 시간이 걸릴 수 있음)
- 서버 재시작 (선택사항):
  ```powershell
  cd C:\Users\thf56\Documents\medicalstandard\server
  npm start
  ```
- 주소 검색 다시 시도

---

## 🔍 추가 확인 사항

### 1. Application 일치 확인

1. **"인증 정보"** 탭에서 Client ID와 Client Secret 확인
2. 서버의 `.env` 파일과 정확히 일치하는지 확인:
   ```env
   NAVER_MAP_CLIENT_ID=vdpb7wt973
   NAVER_MAP_CLIENT_SECRET=s69JB8NCq8KlFmdAZqwMdp8OUO06IywwKXyv5Hb1
   ```
3. 이 API 키가 **"hanbang"** Application에 속해 있는지 확인
4. 다른 Application의 키를 사용하고 있지 않은지 확인

### 2. API 등록 확인

1. **"API 설정"** 또는 **"서비스 등록"** 탭 확인
2. 다음 API가 등록되어 있는지 확인:
   - ✅ **Geocoding**
   - ✅ **Reverse Geocoding**

### 3. 사용량 확인

1. **"Usage"** 또는 **"사용량"** 탭 확인
2. 무료 할당량(월 3,000건)을 초과하지 않았는지 확인
3. 초과했다면 유료 플랜으로 전환 필요

---

## ⏰ 구독 활성화 시간

구독을 완료한 후:
- **즉시 활성화**: 대부분의 경우 즉시 활성화됨
- **최대 10분**: 드물게 최대 10분 정도 걸릴 수 있음
- **24시간 이상**: 24시간 이상 걸리면 네이버 클라우드 플랫폼 고객 지원 문의 필요

---

## 🧪 테스트

구독 활성화 후:

1. **5-10분 대기**

2. **서버 재시작** (선택사항):
   ```powershell
   cd C:\Users\thf56\Documents\medicalstandard\server
   npm start
   ```

3. **주소 검색 시도**:
   - 앱에서 "서울특별시" 검색
   - 서버 로그에서 정상 응답 확인:
     ```
     [Naver Map API] Response status: { code: 0, name: 'ok', message: '정상' }
     [Naver Map API] Addresses count: 10
     ```

---

## 🆘 여전히 문제가 발생한다면

### 1. 네이버 클라우드 플랫폼 고객 지원 문의

다음 정보와 함께 문의:
- **에러 코드**: `210`
- **에러 메시지**: "Permission Denied - A subscription to the API is required"
- **Application 이름**: "hanbang"
- **사용 중인 API**: Geocoding
- **구독 상태**: 구독 완료했지만 여전히 에러 발생
- **Trace ID**: 서버 로그에서 확인한 `x-ncp-trace-id` 값

### 2. 대안 API 사용 고려

네이버 지도 API가 계속 문제가 발생한다면:
- **카카오 주소 검색 API**: `docs/address_api_alternatives.md` 참고
- **공공데이터포털 주소 검색 API**: `docs/address_api_alternatives.md` 참고

---

## 📋 체크리스트

다음 사항을 모두 확인하세요:

- [ ] 네이버 클라우드 플랫폼 콘솔에서 Application "hanbang" 접속
- [ ] "구독 서비스" 탭에서 "Geocoding" 서비스가 "구독됨" 상태인지 확인
- [ ] "구독 서비스" 탭에서 "Reverse Geocoding" 서비스가 "구독됨" 상태인지 확인
- [ ] 구독되지 않았다면 "구독하기" 버튼 클릭하여 구독 완료
- [ ] 구독 완료 후 5-10분 대기
- [ ] 서버 재시작 (선택사항)
- [ ] 주소 검색 다시 시도
- [ ] 서버 로그에서 정상 응답 확인

---

**구독을 완료한 후 5-10분 정도 대기한 다음 주소 검색을 다시 시도해보세요!** 🚀


