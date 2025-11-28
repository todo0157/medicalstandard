# 네이버 지도 API curl 테스트 가이드

## ✅ 좋은 소식

curl 테스트 결과:
- ✅ **네트워크 연결 정상**: API 서버에 도달할 수 있음
- ✅ **엔드포인트 URL 정상**: 404가 아니라 인증 오류 (URL은 올바름)
- ✅ **API 서버 정상 작동**: 응답을 받고 있음

**문제**: 인증 정보가 없어서 발생한 오류 (예상된 동작)

---

## 🧪 올바른 curl 테스트 방법

### PowerShell에서 curl 테스트 (헤더 포함)

PowerShell에서 `curl`은 `Invoke-WebRequest`의 별칭이므로, 헤더를 포함하려면 다른 방법을 사용해야 합니다:

```powershell
# 방법 1: Invoke-WebRequest 사용
$headers = @{
    'X-NCP-APIGW-API-KEY-ID' = 'vdpb7wt973'
    'X-NCP-APIGW-API-KEY' = 's69JB8NCq8KlFmdAZqwMdp8OUO06IywwKXyv5Hb1'
}
Invoke-WebRequest -Uri 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울' -Headers $headers

# 방법 2: curl.exe 사용 (Windows 10+)
curl.exe -H 'X-NCP-APIGW-API-KEY-ID: vdpb7wt973' -H 'X-NCP-APIGW-API-KEY: s69JB8NCq8KlFmdAZqwMdp8OUO06IywwKXyv5Hb1' 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울'
```

### 실제 curl (Linux/Mac/Git Bash) 사용 시

```bash
curl -H 'X-NCP-APIGW-API-KEY-ID: vdpb7wt973' \
     -H 'X-NCP-APIGW-API-KEY: s69JB8NCq8KlFmdAZqwMdp8OUO06IywwKXyv5Hb1' \
     'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=서울'
```

---

## 🔍 서버 코드에서 헤더 확인

서버 코드를 확인하여 헤더가 올바르게 전송되는지 확인하세요:

```typescript
// server/src/routes/address.routes.ts
const response = await fetch(requestUrl, {
  method: 'GET',
  headers: {
    'X-NCP-APIGW-API-KEY-ID': trimmedClientId,
    'X-NCP-APIGW-API-KEY': trimmedClientSecret,
  },
});
```

---

## 📊 curl 테스트 결과 해석

### 성공 응답 (200 OK):
```json
{
  "status": {
    "code": 0,
    "name": "ok",
    "message": "정상"
  },
  "addresses": [
    {
      "roadAddress": "서울특별시 중구 세종대로 110",
      "jibunAddress": "서울특별시 중구 태평로1가",
      ...
    }
  ]
}
```

### 인증 실패 (401):
```json
{
  "error": {
    "errorCode": "200",
    "message": "Authentication Failed",
    "details": "Authentication information are missing."
  }
}
```

### 구독 필요 (401):
```json
{
  "error": {
    "errorCode": "210",
    "message": "Permission Denied",
    "details": "A subscription to the API is required."
  }
}
```

---

## 🎯 다음 단계

1. **서버 로그 확인**:
   - 서버를 재시작한 후 주소 검색 시도
   - 서버 로그에서 헤더가 올바르게 전송되는지 확인

2. **서버에서 직접 테스트**:
   - 서버 코드에서 실제로 헤더가 전송되는지 확인
   - 네이버 API 응답 확인

3. **Application 서비스 환경 확인**:
   - 네이버 클라우드 플랫폼 콘솔에서 "서비스 환경" 탭 확인
   - Web 서비스 URL이 올바르게 설정되어 있는지 확인

---

**curl 테스트 결과, 네트워크와 엔드포인트는 정상입니다. 이제 서버 코드에서 헤더가 올바르게 전송되는지 확인하면 됩니다!** 🚀


