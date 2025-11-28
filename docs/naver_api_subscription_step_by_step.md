# 네이버 지도 API 구독 방법 (단계별 가이드)

## 📋 구독 전 확인 사항

구독하기 전에 다음을 확인하세요:
- [ ] 네이버 클라우드 플랫폼 계정이 있음
- [ ] Maps 서비스에 접근 가능
- [ ] Application "hanbang"이 생성되어 있음

---

## ✅ Step 1: 네이버 클라우드 플랫폼 콘솔 접속

1. 웹 브라우저에서 [네이버 클라우드 플랫폼 콘솔](https://console.ncloud.com/) 접속
2. 네이버 계정으로 로그인

---

## ✅ Step 2: Maps 서비스로 이동

1. 좌측 메뉴에서 **"Services"** 클릭
2. **"Maps"** 클릭
   - 또는 상단 검색창에서 "Maps" 검색

---

## ✅ Step 3: Application 선택

1. **"Application"** 탭 클릭
2. Application 목록에서 **"hanbang"** 클릭
   - Application이 없다면 먼저 생성 필요

---

## ✅ Step 4: 구독 서비스 탭으로 이동

Application 상세 페이지에서:

1. 상단 탭 메뉴 확인:
   - **"인증 정보"** (Authentication Information)
   - **"API 설정"** 또는 **"서비스 등록"** (API Settings / Service Registration)
   - **"구독 서비스"** 또는 **"Subscribed Services"** ← **여기 클릭!**
   - **"서비스 환경"** (Service Environment)
   - **"Usage"** 또는 **"사용량"** (Usage)

2. **"구독 서비스"** 또는 **"Subscribed Services"** 탭 클릭

---

## ✅ Step 5: 서비스 구독

### 5-1. 구독 상태 확인

"구독 서비스" 탭에서 다음 서비스의 상태를 확인:

- **Geocoding** (주소 → 좌표 변환)
- **Reverse Geocoding** (좌표 → 주소 변환)

### 5-2. 구독하기

#### 경우 A: 구독되지 않은 경우

1. **"구독하기"** 또는 **"Subscribe"** 또는 **"서비스 구독"** 버튼 클릭
2. 구독할 서비스 선택:
   - ✅ **Geocoding** 체크
   - ✅ **Reverse Geocoding** 체크
3. 구독 약관 동의
4. **"구독"** 또는 **"Subscribe"** 또는 **"확인"** 버튼 클릭
5. 구독 완료 메시지 확인

#### 경우 B: 구독이 되어 있지만 작동하지 않는 경우

1. **"구독 해제"** 또는 **"Unsubscribe"** 버튼 클릭
2. 구독 해제 확인
3. **"구독하기"** 버튼 클릭
4. 구독할 서비스 선택:
   - ✅ **Geocoding** 체크
   - ✅ **Reverse Geocoding** 체크
5. 구독 약관 동의
6. **"구독"** 버튼 클릭
7. 구독 완료 메시지 확인

---

## ✅ Step 6: 구독 완료 확인

1. **"구독 서비스"** 탭으로 돌아가기
2. 다음이 표시되는지 확인:
   - ✅ **Geocoding**: "구독됨" 또는 "Subscribed" 또는 "Active"
   - ✅ **Reverse Geocoding**: "구독됨" 또는 "Subscribed" 또는 "Active"

---

## ⏰ Step 7: 구독 활성화 대기

구독을 완료한 후:
- **즉시 활성화**: 대부분의 경우 즉시 활성화됨
- **최대 10분**: 드물게 최대 10분 정도 걸릴 수 있음
- **24시간 이상**: 24시간 이상 걸리면 네이버 클라우드 플랫폼 고객 지원 문의 필요

---

## 🧪 Step 8: 테스트

구독 활성화 후:

1. **5-10분 대기** (구독 활성화 시간)

2. **서버 재시작** (선택사항):
   ```powershell
   cd C:\Users\thf56\Documents\medicalstandard\server
   npm start
   ```

3. **주소 검색 테스트**:
   - 앱에서 "서울특별시" 검색
   - 서버 로그에서 정상 응답 확인:
     ```
     [Naver Map API] Response status: { code: 0, name: 'ok', message: '정상' }
     [Naver Map API] Addresses count: 10
     ```

---

## 🔍 구독 서비스 탭을 찾을 수 없는 경우

### 대안 1: 다른 탭 이름 확인

다음 탭 이름들도 확인해보세요:
- **"서비스"** (Services)
- **"API 서비스"** (API Services)
- **"등록된 서비스"** (Registered Services)
- **"Subscriptions"**

### 대안 2: Application 편집

1. Application 상세 페이지에서 **"편집"** 또는 **"Edit"** 버튼 클릭
2. **"서비스"** 또는 **"Services"** 섹션 확인
3. Geocoding과 Reverse Geocoding 선택
4. **"저장"** 버튼 클릭

### 대안 3: Maps 메인 페이지에서 구독

1. **"Services"** → **"Maps"** 메인 페이지로 이동
2. **"Subscription"** 또는 **"구독"** 메뉴 클릭
3. Application 선택 및 서비스 구독

### 대안 4: 네이버 클라우드 플랫폼 고객 지원

위 방법으로 찾을 수 없다면:
- 네이버 클라우드 플랫폼 고객 지원에 문의
- "Maps 서비스 구독 방법" 문의

---

## 📸 화면 구성 참고

일반적인 화면 구성:
```
[Maps 서비스]
├── Application
│   └── hanbang
│       ├── 인증 정보 (Authentication Information)
│       ├── API 설정 (API Settings)
│       ├── 구독 서비스 (Subscribed Services) ← 여기!
│       ├── 서비스 환경 (Service Environment)
│       └── Usage (사용량)
```

---

## 🆘 문제 해결

### 문제 1: "구독하기" 버튼이 보이지 않음

**해결 방법**:
1. Application이 올바르게 생성되어 있는지 확인
2. Maps 서비스에 접근 권한이 있는지 확인
3. 다른 브라우저나 시크릿 모드에서 시도

### 문제 2: 구독 후에도 여전히 에러 발생

**해결 방법**:
1. 구독 완료 후 **5-10분 대기**
2. 서버 재시작
3. 네이버 클라우드 플랫폼 콘솔에서 구독 상태 재확인
4. 서버 로그에서 에러 코드 확인:
   - `errorCode: 200` → 인증 문제 (API 키 확인)
   - `errorCode: 210` → 구독 문제 (구독 재확인)

### 문제 3: 구독 약관 동의가 안 됨

**해결 방법**:
1. 모든 약관 체크박스 선택
2. 필수 약관이 모두 동의되었는지 확인
3. 페이지 새로고침 후 다시 시도

---

## 📋 체크리스트

구독 완료 후 다음을 확인하세요:

- [ ] 네이버 클라우드 플랫폼 콘솔에 로그인
- [ ] Maps → Application → "hanbang" 접속
- [ ] "구독 서비스" 탭 클릭
- [ ] "Geocoding" 서비스 구독 완료
- [ ] "Reverse Geocoding" 서비스 구독 완료
- [ ] 구독 상태가 "구독됨" 또는 "Subscribed"로 표시됨
- [ ] 구독 완료 후 5-10분 대기
- [ ] 서버 재시작 (선택사항)
- [ ] 주소 검색 테스트
- [ ] 서버 로그에서 정상 응답 확인

---

**구독을 완료한 후 5-10분 정도 대기한 다음 주소 검색을 다시 시도해보세요!** 🚀


