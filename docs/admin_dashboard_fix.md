# 관리자 대시보드 접속 문제 해결

## 문제

`http://localhost:8080/admin/`에 접속했을 때 HTML 대신 JSON 응답이 표시되는 문제:
```json
{"message": "인증 토큰이 없습니다."}
```

## 원인

`/admin` 경로가 API 라우트와 충돌하여 정적 파일이 아닌 API 응답이 반환되고 있습니다.

## 해결 방법

서버 코드를 수정하여 `/admin` 경로의 정적 파일 서빙이 API 라우트보다 우선 처리되도록 했습니다.

### 수정 사항

`server/src/server.ts` 파일에서 정적 파일 서빙 설정을 개선했습니다.

## 적용 방법

1. **서버 재시작**
   ```powershell
   # 현재 실행 중인 서버 종료
   netstat -ano | findstr :8080
   taskkill /PID <PID> /F
   
   # 서버 재시작
   cd server
   npm run build
   npm start
   ```

2. **브라우저에서 접속**
   ```
   http://localhost:8080/admin/
   ```

## 확인 사항

- 정적 파일이 제대로 서빙되는지 확인
- HTML 페이지가 표시되는지 확인
- JavaScript 파일이 로드되는지 확인 (브라우저 개발자 도구에서)

## 추가 문제 해결

만약 여전히 문제가 발생한다면:

1. **브라우저 캐시 삭제**
   - Ctrl + Shift + Delete
   - 캐시된 이미지 및 파일 삭제

2. **서버 로그 확인**
   - 서버 터미널에서 요청 로그 확인
   - `/admin` 경로로의 요청이 정적 파일로 처리되는지 확인

3. **파일 경로 확인**
   - `server/public/admin/index.html` 파일이 존재하는지 확인
   - 파일 권한 확인


