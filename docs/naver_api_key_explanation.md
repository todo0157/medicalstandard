# 네이버 지도 API 키 설명

## 📋 API 키 구조

### 하나의 Application = 하나의 API 키 쌍

네이버 클라우드 플랫폼에서:
- **하나의 Application**에 여러 API를 등록할 수 있습니다
- **하나의 Application**에는 **하나의 Client ID**와 **하나의 Client Secret**이 있습니다
- Geocoding과 Reverse Geocoding은 **같은 Application**에 등록되므로 **같은 API 키**를 사용합니다

---

## ✅ 사용자가 받은 API 키

사용자가 받은 정보:
- **Geocoding**:
  - Client ID: `vdpb7wt973`
  - Client Secret: `3g0oBg1JHqgzGlbe3G9P1T5hwBWxN3129pDmMVXh`
- **Reverse Geocoding**:
  - Client ID: `vdpb7wt973`
  - Client Secret: `3g0oBg1JHqgzGlbe3G9P1T5hwBWxN3129pDmMVXh`

**→ 두 값이 동일합니다!** ✅

---

## 🔑 환경 변수 설정

### `server/.env` 파일에 입력할 값

```env
# 네이버 지도 API (Geocoding과 Reverse Geocoding 모두 동일한 키 사용)
NAVER_MAP_CLIENT_ID=vdpb7wt973
NAVER_MAP_CLIENT_SECRET=3g0oBg1JHqgzGlbe3G9P1T5hwBWxN3129pDmMVXh
```

**답변**: 
- ✅ **Geocoding 값으로 넣으면 됩니다** (Reverse Geocoding과 동일하므로)
- ✅ 또는 **Reverse Geocoding 값으로 넣어도 됩니다** (Geocoding과 동일하므로)
- ✅ **둘 중 아무거나 사용해도 됩니다** (같은 값이므로)

---

## 💡 왜 같은 값인가?

### Application 구조
```
Application: "hanbang"
├── Geocoding API (Client ID: vdpb7wt973, Secret: ...)
└── Reverse Geocoding API (Client ID: vdpb7wt973, Secret: ...)
```

하나의 Application에 여러 API를 등록하면:
- 모든 API가 **같은 Client ID/Secret**을 공유합니다
- 각 API는 Application 내에서 구분됩니다

---

## ✅ 결론

**현재 `.env` 파일에 입력된 값이 정확합니다:**
```env
NAVER_MAP_CLIENT_ID=vdpb7wt973
NAVER_MAP_CLIENT_SECRET=3g0oBg1JHqgzGlbe3G9P1T5hwBWxN3129pDmMVXh
```

이 값으로:
- ✅ Geocoding API 사용 가능
- ✅ Reverse Geocoding API 사용 가능

---

## 🔍 확인 방법

네이버 클라우드 플랫폼에서:
1. **"Maps"** → **"Application"** → **"hanbang"** 클릭
2. **"인증 정보"** 탭 확인
3. Geocoding과 Reverse Geocoding이 **같은 Client ID/Secret**을 사용하는지 확인

---

**결론: Geocoding 값으로 넣으면 됩니다. (Reverse Geocoding과 동일하므로)**


