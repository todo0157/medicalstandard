# Application에 Geocoding API 등록 가이드

## 🚨 현재 상황

서버 로그를 보면:
- ✅ API 키는 올바르게 로드됨 (Client ID length: 10, Client Secret length: 40)
- ✅ 요청 URL은 올바르게 구성됨
- ❌ 네이버 API가 401 "Permission Denied" 에러 반환

**원인**: Maps 서비스는 구독되어 있지만, **Application에 Geocoding API가 등록되지 않았을 가능성**이 높습니다.

---

## ✅ 해결 방법: Application에 API 등록

### Step 1: Application 상세 페이지 접속

1. [네이버 클라우드 플랫폼 콘솔](https://console.ncloud.com/)에 로그인
2. **"Services"** → **"Maps"** → **"Application"** 클릭
3. Application 목록에서 **"hanbang"** 클릭

### Step 2: API 설정 탭 확인

Application 상세 페이지에서:

#### 2-1. "API 설정" 또는 "서비스 등록" 탭 찾기

Application 상세 페이지의 탭 메뉴에서 다음 중 하나를 찾으세요:
- **"API 설정"**
- **"서비스 등록"**
- **"API 등록"**
- **"Service Registration"**

#### 2-2. 등록된 API 확인

해당 탭에서 다음 API가 **등록되어 있는지** 확인:
- ✅ **Geocoding** (주소 → 좌표 변환)
- ✅ **Reverse Geocoding** (좌표 → 주소 변환)

### Step 3: API 등록 (등록되지 않은 경우)

#### 3-1. API 추가 버튼 클릭

1. **"API 추가"** 또는 **"서비스 등록"** 또는 **"Add API"** 버튼 클릭
2. API 목록이 표시됩니다

#### 3-2. Geocoding API 선택 및 등록

1. API 목록에서 **"Geocoding"** 찾기
2. **"Geocoding"** 옆의 체크박스 선택
3. **"등록"** 또는 **"추가"** 또는 **"Register"** 버튼 클릭
4. 등록 완료 메시지 확인

#### 3-3. Reverse Geocoding API 선택 및 등록

1. API 목록에서 **"Reverse Geocoding"** 찾기
2. **"Reverse Geocoding"** 옆의 체크박스 선택
3. **"등록"** 또는 **"추가"** 또는 **"Register"** 버튼 클릭
4. 등록 완료 메시지 확인

### Step 4: 등록 확인

1. **"API 설정"** 또는 **"서비스 등록"** 탭으로 돌아가기
2. 다음이 표시되는지 확인:
   - ✅ **Geocoding**: 등록됨
   - ✅ **Reverse Geocoding**: 등록됨

---

## 🔍 탭을 찾을 수 없는 경우

### 대안 1: Application 편집

1. Application 상세 페이지에서 **"편집"** 또는 **"Edit"** 버튼 클릭
2. **"API"** 또는 **"Services"** 섹션 확인
3. Geocoding과 Reverse Geocoding 선택
4. **"저장"** 또는 **"Save"** 버튼 클릭

### 대안 2: 서비스 환경 확인

1. **"서비스 환경"** 또는 **"Service Environment"** 탭 클릭
2. **"API"** 또는 **"Services"** 섹션 확인
3. Geocoding과 Reverse Geocoding 선택
4. **"저장"** 또는 **"Save"** 버튼 클릭

### 대안 3: 네이버 클라우드 플랫폼 고객 지원

위 방법으로 찾을 수 없다면:
- 네이버 클라우드 플랫폼 고객 지원에 문의
- "Application에 Geocoding API를 등록하는 방법" 문의

---

## 📋 체크리스트

다음 사항을 모두 확인하세요:

- [ ] 네이버 클라우드 플랫폼 콘솔에서 Application "hanbang" 접속
- [ ] Application 상세 페이지에서 "API 설정" 또는 "서비스 등록" 탭 찾기
- [ ] "Geocoding" API가 등록되어 있는지 확인
- [ ] "Reverse Geocoding" API가 등록되어 있는지 확인
- [ ] 등록되지 않았다면 API 추가 버튼으로 등록
- [ ] 등록 완료 후 서버 재시작 (선택사항)
- [ ] 주소 검색 다시 시도

---

## ⚠️ 중요 사항

### Maps 서비스 구독 vs Application에 API 등록

**두 가지가 다릅니다:**

1. **Maps 서비스 구독**: Maps 서비스를 사용할 수 있도록 구독 (이미 완료됨)
2. **Application에 API 등록**: 특정 Application에서 Geocoding/Reverse Geocoding API를 사용할 수 있도록 등록 (필요)

**둘 다 완료되어야 API를 사용할 수 있습니다!**

---

## 🧪 테스트

API 등록 후:

1. 서버 재시작 (선택사항):
   ```powershell
   cd C:\Users\thf56\Documents\medicalstandard\server
   npm start
   ```

2. 주소 검색 시도:
   - 앱에서 "서울특별시" 검색
   - 서버 로그에서 정상 응답 확인:
     ```
     [Naver Map API] Response status: { code: 0, name: 'ok', message: '정상' }
     [Naver Map API] Addresses count: 10
     ```

---

**Application에 Geocoding API를 등록한 후 주소 검색을 다시 시도해보세요!** 🚀


