# 네이버 지도 API 문제 해결 가이드

## 🔍 가능한 원인 및 해결 방법

### 원인 1: 서버 재시작 누락 ⚠️ **가장 흔한 원인**

**증상**: API 키를 변경했는데도 여전히 이전 키를 사용하는 것처럼 보임

**해결 방법**:
1. 서버를 완전히 중지 (Ctrl+C)
2. 서버 재시작:
   ```powershell
   cd C:\Users\thf56\Documents\medicalstandard\server
   npm start
   ```
3. 서버 로그에서 새로운 API 키가 로드되는지 확인:
   ```
   [Naver Map API] Client ID (first 4): vdpb
   [Naver Map API] Client ID length: 10
   ```

---

### 원인 2: API 키 불일치

**증상**: 네이버 콘솔의 인증 정보와 서버의 .env 파일이 일치하지 않음

**해결 방법**:
1. **네이버 클라우드 플랫폼 콘솔 확인**:
   - Maps → Application → "hanbang" → "인증 정보" 탭
   - Client ID와 Client Secret 복사

2. **서버의 .env 파일 확인**:
   - 파일 위치: `server/.env`
   - 다음 형식으로 입력 (공백, 따옴표 없이):
     ```env
     NAVER_MAP_CLIENT_ID=vdpb7wt973
     NAVER_MAP_CLIENT_SECRET=s69JB8NCq8KlFmdAZqwMdp8OUO06IywwKXyv5Hb1
     ```

3. **일치 여부 확인**:
   - 콘솔의 Client ID와 .env의 NAVER_MAP_CLIENT_ID가 정확히 일치하는지 확인
   - 콘솔의 Client Secret과 .env의 NAVER_MAP_CLIENT_SECRET이 정확히 일치하는지 확인
   - 앞뒤 공백이 없어야 함
   - 따옴표 없이 입력

---

### 원인 3: API 키가 다른 Application에 속함

**증상**: API 키는 올바르지만 다른 Application의 키를 사용 중

**해결 방법**:
1. 네이버 클라우드 플랫폼 콘솔에서 모든 Application 확인
2. "hanbang" Application의 인증 정보만 사용
3. 다른 Application의 키를 사용하고 있지 않은지 확인

---

### 원인 4: API 키 형식 오류

**증상**: API 키에 공백, 특수 문자, 따옴표가 포함됨

**해결 방법**:
1. .env 파일에서 API 키 확인:
   ```env
   # ❌ 잘못된 형식
   NAVER_MAP_CLIENT_ID="vdpb7wt973"  # 따옴표 제거
   NAVER_MAP_CLIENT_ID= vdpb7wt973   # 앞 공백 제거
   NAVER_MAP_CLIENT_ID=vdpb7wt973    # 뒤 공백 제거
   
   # ✅ 올바른 형식
   NAVER_MAP_CLIENT_ID=vdpb7wt973
   ```

2. 서버 코드에서 자동으로 `trim()` 처리하지만, .env 파일 자체에 공백이 있으면 문제가 될 수 있음

---

### 원인 5: API 등록은 완료했지만 구독이 안 됨

**증상**: API는 등록되어 있지만 구독 서비스에 표시되지 않음

**해결 방법**:
1. Maps → Application → "hanbang" → "구독 서비스" 탭 확인
2. "Geocoding"과 "Reverse Geocoding"이 "구독됨" 상태인지 확인
3. 구독되지 않았다면 "구독하기" 버튼 클릭

---

### 원인 6: 네트워크 또는 방화벽 문제

**증상**: API 호출 자체가 실패하거나 타임아웃 발생

**해결 방법**:
1. 서버에서 네이버 API 엔드포인트 접근 가능한지 확인:
   ```powershell
   curl https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울
   ```

2. 방화벽 설정 확인:
   - 회사 네트워크를 사용 중이라면 방화벽에서 차단될 수 있음
   - VPN을 사용 중이라면 VPN 설정 확인

---

### 원인 7: API 할당량 초과

**증상**: 초기에는 작동했지만 갑자기 401 에러 발생

**해결 방법**:
1. Maps → Usage 탭에서 사용량 확인
2. 무료 할당량(월 3,000건)을 초과했는지 확인
3. 초과했다면 유료 플랜으로 전환하거나 다음 달까지 대기

---

## 🔧 디버깅 체크리스트

다음 순서대로 확인하세요:

### 1단계: 서버 재시작
- [ ] 서버를 완전히 중지했는가?
- [ ] 서버를 재시작했는가?
- [ ] 서버 로그에서 새로운 API 키가 로드되는지 확인했는가?

### 2단계: API 키 확인
- [ ] 네이버 콘솔의 Client ID와 .env의 NAVER_MAP_CLIENT_ID가 일치하는가?
- [ ] 네이버 콘솔의 Client Secret과 .env의 NAVER_MAP_CLIENT_SECRET이 일치하는가?
- [ ] API 키에 공백이나 따옴표가 없는가?
- [ ] API 키가 올바른 Application("hanbang")에 속해 있는가?

### 3단계: API 등록 및 구독 확인
- [ ] "API 설정" 탭에서 "Geocoding" API가 등록되어 있는가?
- [ ] "구독 서비스" 탭에서 "Geocoding" 서비스가 구독되어 있는가?

### 4단계: 서버 로그 확인
- [ ] 서버 로그에서 API 키 길이가 올바른가? (Client ID: 10자리, Client Secret: 40자리)
- [ ] 서버 로그에서 어떤 에러 메시지가 나타나는가?
- [ ] 에러 코드가 무엇인가? (210 = Permission Denied)

---

## 📊 서버 로그 분석

### 정상 작동 시:
```
[Naver Map API] Request URL: https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울특별시
[Naver Map API] Client ID (first 4): vdpb
[Naver Map API] Client ID length: 10
[Naver Map API] Client Secret length: 40
[Naver Map API] Response status: { code: 0, name: 'ok', message: '정상' }
[Naver Map API] Addresses count: 10
```

### 문제 발생 시:
```
[Naver Map API] Error: 401 {"error":{"errorCode":"210","message":"Permission Denied"}}
[Naver Map API] Error details: { errorCode: '210', message: 'Permission Denied', ... }
```

---

## 🆘 여전히 문제가 발생한다면

1. **네이버 클라우드 플랫폼 고객 지원 문의**
   - 에러 코드 `210`과 함께 문의
   - Application 이름: "hanbang"
   - 사용 중인 API: Geocoding

2. **대안 API 사용 고려**
   - 카카오 주소 검색 API: `docs/address_api_alternatives.md` 참고
   - 공공데이터포털 주소 검색 API: `docs/address_api_alternatives.md` 참고

---

**가장 흔한 원인은 서버 재시작 누락입니다. API 키를 변경했다면 반드시 서버를 재시작하세요!** 🚀


