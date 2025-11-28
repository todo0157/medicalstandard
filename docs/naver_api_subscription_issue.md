# 네이버 지도 API 구독 문제 해결 가이드

## 🔴 현재 문제

서버 로그에서 다음 에러가 발생하고 있습니다:
```
[Naver Map API] Error: 401 {"error":{"errorCode":"210","message":"Permission Denied","details":"A subscription to the API is required."}}
```

**의미**: 네이버 지도 API 구독이 필요합니다.

---

## ✅ 해결 방법

### Step 1: Subscription 메뉴로 이동

현재 화면에서:
1. **좌측 사이드바** 확인
2. **"Maps"** 섹션이 확장되어 있음
3. **"Subscription"** 메뉴 클릭
   - "Application" 아래에 있는 "Subscription" 메뉴

### Step 2: 구독 상태 확인 및 구독

1. **Subscription 화면에서 확인**
   - 구독 상태: "구독 중" 또는 "구독 필요"
   - 구독 플랜: 무료 플랜 또는 유료 플랜

2. **구독이 안 되어 있다면**
   - **"구독하기"** 또는 **"Subscribe"** 버튼 클릭
   - 구독 약관 동의
   - 구독 완료

3. **구독 완료 확인**
   - "구독 중" 또는 "Active" 상태 확인

---

### Step 2: Application 등록 확인

1. **"Maps"** → **"Application"** 메뉴 클릭
2. 등록한 Application 확인
3. **"Geocoding"** API가 활성화되어 있는지 확인

---

### Step 3: API 키 확인

1. Application 상세 페이지에서
2. **Client ID**와 **Client Secret** 확인
3. `server/.env` 파일의 값과 일치하는지 확인

---

## 🔧 임시 해결책 (코드 수정 완료)

서버 코드를 수정하여:
- 네이버 API의 401 에러를 500으로 변환
- 인증 실패로 오인되지 않도록 처리
- 사용자에게 명확한 에러 메시지 표시

**이제 주소 검색 실패 시 로그인 화면으로 튕기지 않습니다.**

---

## 📝 서버 재시작 필요

코드 수정 후 서버를 재시작해야 합니다:

```bash
cd C:\Users\thf56\Documents\medicalstandard\server
npm start
```

---

## 🎯 최종 해결

네이버 클라우드 플랫폼에서 Maps API 구독을 완료하면 정상 작동합니다.

