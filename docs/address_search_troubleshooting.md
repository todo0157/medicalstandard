# 주소 검색 500 에러 해결 가이드

## 🔍 문제 상황

주소 검색 시 500 에러가 발생하고 있습니다.

## ✅ 적용된 개선 사항

1. **네이버 API 응답 형식 확인 로직 추가**
   - `status.code`가 0이 아니면 에러로 처리
   - 더 자세한 에러 메시지 반환

2. **개발 환경 로깅 추가**
   - API 요청 URL 로깅
   - API 응답 상태 로깅
   - 주소 개수 로깅

3. **에러 처리 개선**
   - 예상치 못한 에러에 대한 더 자세한 로깅
   - 개발 환경에서 에러 상세 정보 반환

---

## 🔧 다음 단계

### 1. 서버 재시작

서버를 재시작하여 변경 사항을 적용합니다:

```powershell
# 서버 디렉토리로 이동
cd C:\Users\thf56\Documents\medicalstandard\server

# 서버 빌드 (서버가 실행 중이면 먼저 중지)
npm run build

# 서버 시작
npm start
```

### 2. 서버 로그 확인

주소 검색을 시도할 때 서버 터미널에서 다음 로그를 확인하세요:

```
[Naver Map API] Request URL: https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울특별시
[Naver Map API] Client ID: vdpb...
[Naver Map API] Response status: { code: 0, name: 'ok', message: '정상' }
[Naver Map API] Addresses count: 10
```

또는 에러가 발생하면:

```
[Naver Map API] Error: 401 { ... }
[Naver Map API] Status error: { code: 400, name: 'Bad Request', message: '...' }
[Address Search] Unexpected error: ...
```

### 3. 가능한 원인 및 해결 방법

#### 원인 1: 네이버 API 구독 미완료
- **증상**: `Permission Denied` 에러
- **해결**: 네이버 클라우드 플랫폼에서 Maps 서비스 구독 확인

#### 원인 2: API 키 오류
- **증상**: 401 에러 또는 `API 키가 유효하지 않습니다` 메시지
- **해결**: `.env` 파일의 `NAVER_MAP_CLIENT_ID`와 `NAVER_MAP_CLIENT_SECRET` 확인

#### 원인 3: 네이버 API 응답 형식 변경
- **증상**: `status.code`가 0이 아님
- **해결**: 서버 로그에서 `[Naver Map API] Status error:` 확인 후 네이버 API 문서 확인

#### 원인 4: 네트워크 오류
- **증상**: `fetch` 호출 실패
- **해결**: 서버 로그에서 `[Address Search] Unexpected error:` 확인

---

## 📋 체크리스트

- [ ] 서버가 재시작되었는가?
- [ ] `.env` 파일에 `NAVER_MAP_CLIENT_ID`와 `NAVER_MAP_CLIENT_SECRET`이 설정되어 있는가?
- [ ] 네이버 클라우드 플랫폼에서 Maps 서비스가 구독되어 있는가?
- [ ] 서버 로그에서 어떤 에러 메시지가 나타나는가?

---

## 💡 추가 디버깅

서버 로그를 확인한 후, 에러 메시지를 공유해주시면 더 정확한 해결 방법을 제시할 수 있습니다.


