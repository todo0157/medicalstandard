# 네이버 지도 API 키 업데이트 가이드

## 🔑 새로운 API 키 정보

이미지에서 확인한 새로운 API 키:
- **Application 이름**: `hanbangapp1`
- **Client ID**: `dtet33owgu`
- **Client Secret**: `Yld6alMWcQwOVGHkEEQSnV082XvLfq96gbQTd9sf`
- **Web 서비스 URL**: `http://localhost:8080`, `http://localhost:5173` (둘 다 설정됨)

---

## ✅ 코드 수정 필요 없음

서버 코드는 이미 환경 변수를 사용하고 있으므로 **코드 수정은 필요 없습니다**.

현재 코드:
```typescript
// server/src/routes/address.routes.ts
const clientId = env.NAVER_MAP_CLIENT_ID;
const clientSecret = env.NAVER_MAP_CLIENT_SECRET;
```

---

## 📝 .env 파일 업데이트

### Step 1: .env 파일 열기

파일 위치: `C:\Users\thf56\Documents\medicalstandard\server\.env`

### Step 2: API 키 업데이트

다음 줄을 찾아서 새로운 값으로 변경:

**이전 값 (예시)**:
```env
NAVER_MAP_CLIENT_ID=vdpb7wt973
NAVER_MAP_CLIENT_SECRET=xgTqvDb1D7UzpibQNJ1hZGWlqCuobj0yfVwE4lTu
```

**새로운 값**:
```env
NAVER_MAP_CLIENT_ID=dtet33owgu
NAVER_MAP_CLIENT_SECRET=Yld6alMWcQwOVGHkEEQSnV082XvLfq96gbQTd9sf
```

### Step 3: 저장

파일을 저장합니다.

---

## ⚠️ 주의사항

### 1. 공백 없이 입력
```env
# ❌ 잘못된 형식
NAVER_MAP_CLIENT_ID= dtet33owgu   # 앞 공백
NAVER_MAP_CLIENT_ID=dtet33owgu    # 뒤 공백
NAVER_MAP_CLIENT_ID="dtet33owgu"  # 따옴표

# ✅ 올바른 형식
NAVER_MAP_CLIENT_ID=dtet33owgu
NAVER_MAP_CLIENT_SECRET=Yld6alMWcQwOVGHkEEQSnV082XvLfq96gbQTd9sf
```

### 2. 한 줄로 입력
```env
# ✅ 올바른 형식 (한 줄)
NAVER_MAP_CLIENT_SECRET=Yld6alMWcQwOVGHkEEQSnV082XvLfq96gbQTd9sf

# ❌ 잘못된 형식 (여러 줄)
NAVER_MAP_CLIENT_SECRET=Yld6alMWcQwOVGHkEEQSnV082XvLfq96gbQTd9sf
```

---

## 🔄 서버 재시작

.env 파일을 수정한 후 **반드시 서버를 재시작**해야 합니다:

```powershell
# 서버 디렉토리로 이동
cd C:\Users\thf56\Documents\medicalstandard\server

# 서버 중지 (Ctrl+C)

# 서버 재시작
npm start
```

---

## 🧪 업데이트 확인

서버 재시작 후:

1. **구독 상태 확인**:
   ```powershell
   cd C:\Users\thf56\Documents\medicalstandard
   .\check_naver_api.ps1
   ```

2. **주소 검색 테스트**:
   - 앱에서 주소 검색 시도
   - 서버 로그에서 정상 응답 확인

---

## 📋 체크리스트

- [ ] .env 파일에서 NAVER_MAP_CLIENT_ID 업데이트
- [ ] .env 파일에서 NAVER_MAP_CLIENT_SECRET 업데이트
- [ ] 공백이나 따옴표 없이 입력 확인
- [ ] 파일 저장
- [ ] 서버 재시작
- [ ] 구독 상태 확인 스크립트 실행
- [ ] 주소 검색 테스트

---

## 🆘 문제 해결

### 문제 1: 서버가 이전 API 키를 사용함

**해결**: 서버를 완전히 중지하고 재시작

### 문제 2: 여전히 인증 실패

**해결**:
1. .env 파일의 API 키가 정확한지 확인
2. 공백이나 따옴표가 없는지 확인
3. 서버 재시작

### 문제 3: 구독 필요 에러

**해결**: 새로운 Application에도 구독이 필요합니다:
1. 네이버 클라우드 플랫폼 콘솔 → Maps → Application → "hanbangapp1"
2. "구독 서비스" 탭에서 Geocoding과 Reverse Geocoding 구독

---

**새로운 API 키로 업데이트한 후 서버를 재시작하세요!** 🚀


