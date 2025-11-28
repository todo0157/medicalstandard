# 네이버 지도 API 구독 대안 방법

## 🚨 구독 버튼을 찾을 수 없는 경우

네이버 클라우드 플랫폼의 Maps API는 경우에 따라 구독 버튼이 보이지 않을 수 있습니다. 다음 대안 방법들을 시도해보세요.

---

## ✅ 방법 1: 서비스 활성화 확인

일부 네이버 클라우드 플랫폼 서비스는 구독이 자동으로 활성화됩니다.

### 확인 방법:

1. 네이버 클라우드 플랫폼 콘솔 → **"Services"** → **"Maps"** 메인 페이지
2. **"상품 이용 중"** 또는 **"Product in use"** 버튼 확인
3. 상태가 **"이용 중"** 또는 **"Active"**인지 확인

---

## ✅ 방법 2: API 설정에서 활성화

구독 서비스 탭 대신 API 설정에서 활성화할 수 있습니다.

### Step 1: API 설정 탭 확인

1. Maps → Application → "hanbangapp1" 클릭
2. **"API 설정"** 또는 **"서비스 등록"** 또는 **"API 등록"** 탭 클릭

### Step 2: API 활성화

1. **"Geocoding"** API 찾기
2. **"활성화"** 또는 **"Enable"** 또는 **"사용"** 버튼 클릭
3. **"Reverse Geocoding"** API도 동일하게 활성화

---

## ✅ 방법 3: Application 편집에서 활성화

Application을 편집하여 API를 활성화할 수 있습니다.

### Step 1: Application 편집

1. Maps → Application → "hanbangapp1" 클릭
2. **"편집"** 또는 **"Edit"** 버튼 클릭

### Step 2: API 선택

1. **"API"** 또는 **"Services"** 또는 **"사용할 API"** 섹션 찾기
2. 다음 API 선택:
   - ✅ **Geocoding**
   - ✅ **Reverse Geocoding**
3. **"저장"** 또는 **"Save"** 버튼 클릭

---

## ✅ 방법 4: Maps 서비스 메인에서 구독

Maps 서비스 메인 페이지에서 구독할 수 있습니다.

### Step 1: Maps 메인 페이지

1. **"Services"** → **"Maps"** 메인 페이지로 이동
2. **"Subscription"** 또는 **"구독"** 메뉴 확인

### Step 2: 서비스 구독

1. **"서비스 구독"** 또는 **"Subscribe Service"** 버튼 클릭
2. Application 선택: "hanbangapp1"
3. 서비스 선택:
   - ✅ **Geocoding**
   - ✅ **Reverse Geocoding**
4. 구독 완료

---

## ✅ 방법 5: 무료 할당량 자동 활성화

일부 네이버 클라우드 플랫폼 서비스는 무료 할당량이 자동으로 활성화됩니다.

### 확인 방법:

1. Maps → **"Usage"** 또는 **"사용량"** 탭 확인
2. 할당량이 표시되면 자동으로 활성화된 것입니다
3. 무료 할당량: 월 3,000건

---

## ✅ 방법 6: 네이버 클라우드 플랫폼 고객 지원 문의

위 방법으로 해결되지 않는다면:

1. 네이버 클라우드 플랫폼 고객 지원에 문의
2. 다음 정보와 함께 문의:
   - Application 이름: "hanbangapp1"
   - 사용하려는 API: Geocoding, Reverse Geocoding
   - 문제: 구독 버튼을 찾을 수 없음
   - 현재 상태: API 키는 발급받았지만 구독 방법을 모르겠음

---

## 🔍 현재 상태 확인

먼저 현재 상태를 확인해보세요:

```powershell
cd C:\Users\thf56\Documents\medicalstandard
.\check_naver_api.ps1
```

### 결과 해석:

#### ✅ "SUCCESS: Subscription is active"
→ 구독이 이미 활성화되어 있습니다! 추가 작업 불필요.

#### ❌ "ERROR: Subscription required (errorCode: 210)"
→ 구독이 필요합니다. 위의 방법들을 시도해보세요.

---

## 📋 체크리스트

다음 사항을 순서대로 확인하세요:

- [ ] Maps 메인 페이지에서 "상품 이용 중" 상태 확인
- [ ] Application → "API 설정" 탭에서 API 활성화 확인
- [ ] Application → "편집"에서 API 선택 확인
- [ ] Maps 메인 페이지에서 "Subscription" 메뉴 확인
- [ ] "Usage" 탭에서 할당량 확인 (자동 활성화 여부)
- [ ] 네이버 클라우드 플랫폼 고객 지원 문의

---

## 💡 추가 팁

### 1. 브라우저 캐시 문제

브라우저 캐시를 지우고 다시 시도:
- Ctrl + Shift + Delete
- 캐시 삭제
- 페이지 새로고침

### 2. 다른 브라우저에서 시도

다른 브라우저나 시크릿 모드에서 시도해보세요.

### 3. 네이버 클라우드 플랫폼 업데이트

네이버 클라우드 플랫폼의 UI가 업데이트되었을 수 있습니다. 최신 문서를 확인하세요.

---

**먼저 현재 상태를 확인하는 스크립트를 실행해보세요. 구독이 이미 활성화되어 있을 수도 있습니다!** 🚀


