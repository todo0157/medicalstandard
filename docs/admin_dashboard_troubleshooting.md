# 관리자 대시보드 접속 문제 해결 가이드

## 문제 증상

`http://localhost:8080/admin/`에 접속했을 때 HTML 대신 JSON 응답이 표시됨:
```json
{"message": "인증 토큰이 없습니다."}
```

## 원인

`/admin` 경로가 API 라우트(`router.use('/admin', adminRoutes)`)와 충돌하여 정적 파일이 아닌 API 응답이 반환되고 있습니다.

## 해결 방법

### 1. 서버 재시작

```powershell
# 현재 실행 중인 서버 종료
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# 서버 재시작
cd C:\Users\thf56\Documents\medicalstandard\server
npm start
```

### 2. 브라우저 캐시 삭제

- `Ctrl + Shift + Delete` → 캐시된 이미지 및 파일 삭제
- 또는 하드 새로고침: `Ctrl + F5`

### 3. 직접 파일 접속 테스트

브라우저에서 다음 URL들을 직접 접속해보세요:
- `http://localhost:8080/admin/index.html`
- `http://localhost:8080/admin/css/style.css`
- `http://localhost:8080/admin/js/api.js`

이 파일들이 정상적으로 로드되면 정적 파일 서빙이 작동하는 것입니다.

### 4. 서버 로그 확인

서버 터미널에서 `/admin` 경로로의 요청이 어떻게 처리되는지 확인하세요:
- 정적 파일로 처리되는지
- API 라우트로 처리되는지

## 수정된 코드

`server/src/server.ts` 파일에서 `/admin` 경로에 대한 명시적인 GET 라우트를 추가했습니다:

```typescript
// /admin 경로에 대한 명시적인 GET 라우트
app.get('/admin', (req, res, next) => {
  res.sendFile(path.join(adminPath, 'index.html'));
});

app.get('/admin/*', (req, res, next) => {
  const filePath = path.join(adminPath, req.path.replace('/admin/', ''));
  if (filePath.endsWith('.html') || filePath.endsWith('.js') || filePath.endsWith('.css')) {
    res.sendFile(filePath, (err) => {
      if (err) {
        console.error('[Server] Error serving admin file:', err);
        res.status(404).send('File not found');
      }
    });
  } else {
    next();
  }
});
```

이렇게 하면 `/admin` 경로가 API 라우트보다 먼저 처리되어 정적 파일이 서빙됩니다.

## 추가 확인 사항

1. **파일 경로 확인**
   - `server/public/admin/index.html` 파일이 존재하는지 확인
   - 파일 권한 확인

2. **서버 빌드 확인**
   - `server/dist/server.js` 파일이 최신인지 확인
   - 필요시 `npm run build` 실행

3. **포트 확인**
   - 서버가 8080 포트에서 실행 중인지 확인
   - 다른 포트를 사용하는 경우 URL 수정

## 여전히 문제가 있다면

서버 터미널의 로그를 확인하고 다음 정보를 제공해주세요:
- 서버 시작 로그
- `/admin` 경로로의 요청 로그
- 에러 메시지


