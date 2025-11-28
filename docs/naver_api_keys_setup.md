# 네이버 지도 API 키 설정 완료 가이드

## ✅ 받은 API 키 정보

- **Client ID**: `vdpb7wt973`
- **Client Secret**: `3g0oBg1JHqgzGlbe3G9P1T5hwBWxN3129pDmMVXh`
- **적용 API**: Geocoding, Reverse Geocoding

---

## 📝 Step 1: 서버 환경 변수 설정

### 1-1. `server/.env` 파일 열기
파일 경로: `C:\Users\thf56\Documents\medicalstandard\server\.env`

### 1-2. 다음 내용 추가 또는 수정
```env
# 네이버 지도 API
NAVER_MAP_CLIENT_ID=vdpb7wt973
NAVER_MAP_CLIENT_SECRET=3g0oBg1JHqgzGlbe3G9P1T5hwBWxN3129pDmMVXh
```

**⚠️ 중요**:
- 따옴표 없이 값만 입력
- 공백 없이 정확히 복사
- 파일 저장 확인

### 1-3. 파일이 없는 경우
`server/.env` 파일이 없다면:
1. `server` 폴더로 이동
2. 새 파일 생성: `.env`
3. 위의 내용 추가
4. 저장

---

## 🔄 Step 2: 서버 재시작

### 2-1. 서버가 실행 중이면 중지
터미널에서 `Ctrl + C`로 서버 중지

### 2-2. 서버 재시작
```bash
cd C:\Users\thf56\Documents\medicalstandard\server
npm start
```

### 2-3. 정상 시작 확인
다음 메시지가 보이면 성공:
```
🚀 API server running on port 8080 (development)
```

---

## 🧪 Step 3: 테스트

### 3-1. Flutter 앱 실행 (또는 재시작)
```bash
cd C:\Users\thf56\Documents\medicalstandard
flutter run -d chrome --web-port 5173
```

### 3-2. 주소 검색 테스트
1. 홈 화면에서 **"주소를 입력해주세요"** 버튼 클릭
2. 주소 검색 화면에서 주소 입력 (예: "서울시 강남구")
3. 검색 결과가 나타나는지 확인

---

## ✅ 완료 체크리스트

- [ ] `server/.env` 파일에 API 키 추가 완료
- [ ] 서버 재시작 완료
- [ ] 서버가 정상적으로 시작됨
- [ ] Flutter 앱에서 주소 검색 테스트 성공

---

## 🔍 문제 해결

### "네이버 지도 API가 설정되지 않았습니다" 오류
- `server/.env` 파일에 API 키가 정확히 입력되었는지 확인
- 서버를 재시작했는지 확인
- 환경 변수 이름이 정확한지 확인 (대소문자 구분)

### "네이버 지도 API 키가 유효하지 않습니다" 오류 (401)
- API 키가 정확히 복사되었는지 확인 (공백, 따옴표 제거)
- 네이버 클라우드 플랫폼에서 API 키 재확인

### 주소 검색 결과가 안 나올 때
- 서버 로그 확인
- 네트워크 연결 확인
- API 사용량 확인 (네이버 클라우드 플랫폼 콘솔)

---

## 📊 API 사용량 확인

네이버 클라우드 플랫폼 콘솔에서:
1. **"Maps"** → **"Usage"** 메뉴 클릭
2. 일일/월간 사용량 확인
3. 무료 할당량: 월 300만 건

---

설정이 완료되면 주소 검색 기능이 정상 작동합니다! 🎉


