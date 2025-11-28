# WebSocket 실시간 채팅 테스트 가이드

## 📋 현재 구현 상태

### 서버 측
- **WebSocket 엔드포인트**: `ws://localhost:8080/ws/chat`
- **인증**: JWT 토큰과 세션 ID 필요
- **경로**: `/ws/chat?sessionId={sessionId}&token={token}`

### 클라이언트 측
- **자동 연결**: 채팅 화면 진입 시 자동으로 WebSocket 연결
- **실시간 수신**: 서버에서 메시지 브로드캐스트 시 자동 수신
- **메시지 전송**: REST API로 전송 후 WebSocket으로 브로드캐스트

---

## 🧪 테스트 방법

### 방법 1: 두 개의 브라우저/탭에서 테스트 (권장)

#### 준비 사항
1. 서버가 실행 중인지 확인
   ```bash
   cd server
   npm start
   # 서버가 http://localhost:8080 에서 실행되어야 함
   ```

2. Flutter 앱이 실행 중인지 확인
   ```bash
   flutter run -d chrome --web-port 5173
   ```

#### 테스트 단계

**Step 1: 첫 번째 계정으로 로그인**
1. 브라우저 1에서 `http://localhost:5173` 접속
2. 회원가입 또는 로그인
3. 채팅 탭으로 이동 (하단 네비게이션의 "채팅" 아이콘)
4. 채팅 세션이 자동으로 생성됨

**Step 2: 두 번째 계정으로 로그인**
1. 브라우저 2 (또는 시크릿 모드)에서 `http://localhost:5173` 접속
2. **다른 이메일**로 회원가입 또는 로그인
3. 채팅 탭으로 이동

**Step 3: 메시지 전송 테스트**
1. 브라우저 1에서 메시지 입력 후 전송
2. 브라우저 2에서 **즉시** 메시지가 나타나는지 확인
3. 브라우저 2에서 메시지 입력 후 전송
4. 브라우저 1에서 **즉시** 메시지가 나타나는지 확인

**참고**: 현재 구현은 같은 세션에 연결된 모든 클라이언트에게 메시지를 브로드캐스트합니다. 두 개의 다른 계정이 같은 채팅 세션을 공유하려면, 서버에서 채팅 세션을 공유하는 로직이 필요합니다.

---

### 방법 2: WebSocket 클라이언트 도구 사용

#### Postman 사용 (WebSocket 지원)

1. **Postman 열기** → New → WebSocket Request
2. **URL 입력**:
   ```
   ws://localhost:8080/ws/chat?sessionId={YOUR_SESSION_ID}&token={YOUR_JWT_TOKEN}
   ```
3. **토큰 및 세션 ID 얻기**:
   - 브라우저 개발자 도구 (F12) → Application → Local Storage
   - `auth_token` 키에서 JWT 토큰 복사
   - 채팅 세션 ID는 서버 로그나 DB에서 확인

4. **연결 후 메시지 전송**:
   ```json
   {
     "type": "message",
     "content": "테스트 메시지"
   }
   ```

#### 웹소켓 킹 (WebSocket King) 사용

1. **웹소켓 킹 다운로드**: https://websocketking.com/
2. **연결 설정**:
   - URL: `ws://localhost:8080/ws/chat`
   - Query Parameters:
     - `sessionId`: 채팅 세션 ID
     - `token`: JWT 토큰
3. **연결 후 메시지 전송**

---

### 방법 3: 브라우저 개발자 도구로 확인

#### Chrome DevTools 사용

1. **앱 실행 후 채팅 화면 접근**
2. **F12**로 개발자 도구 열기
3. **Network 탭** → **WS (WebSocket)** 필터 선택
4. **WebSocket 연결 확인**:
   - `ws://localhost:8080/ws/chat?...` 연결이 보여야 함
   - Status가 "101 Switching Protocols"여야 함

5. **메시지 모니터링**:
   - WebSocket 연결 클릭
   - **Messages** 탭에서 송수신 메시지 확인
   - 서버에서 브로드캐스트된 메시지가 표시됨

---

## 🔍 문제 해결

### WebSocket 연결이 안 될 때

1. **서버가 실행 중인지 확인**
   ```bash
   # 서버 로그 확인
   # "Chat gateway attached" 메시지가 있어야 함
   ```

2. **토큰이 유효한지 확인**
   - 브라우저 콘솔에서 확인:
     ```javascript
     localStorage.getItem('auth_token')
     ```

3. **세션 ID가 올바른지 확인**
   - 서버 로그에서 확인
   - 또는 DB에서 `ChatSession` 테이블 확인

4. **CORS 설정 확인**
   - 서버의 `server.ts`에서 CORS 설정 확인
   - WebSocket은 CORS 정책의 영향을 받지 않지만, 연결 시 인증이 필요함

### 메시지가 실시간으로 안 올 때

1. **WebSocket 연결 상태 확인**
   - 브라우저 개발자 도구 → Network → WS
   - 연결이 "Open" 상태인지 확인

2. **서버 로그 확인**
   - 메시지가 서버에 도착했는지 확인
   - `broadcastMessage`가 호출되었는지 확인

3. **채팅 세션이 같은지 확인**
   - 두 클라이언트가 같은 `sessionId`를 사용하는지 확인

---

## 📝 테스트 시나리오

### 시나리오 1: 기본 실시간 채팅

1. ✅ 사용자 A가 채팅 화면 접근
2. ✅ WebSocket 자동 연결 확인
3. ✅ 사용자 A가 메시지 전송
4. ✅ 사용자 B가 같은 세션에 연결
5. ✅ 사용자 B가 메시지 즉시 수신 확인

### 시나리오 2: 연결 끊김 및 재연결

1. ✅ 사용자 A가 채팅 중
2. ✅ 네트워크 끊김 시뮬레이션 (개발자 도구 → Network → Offline)
3. ✅ WebSocket 연결 끊김 확인
4. ✅ 네트워크 복구
5. ✅ 자동 재연결 확인 (현재는 수동 새로고침 필요할 수 있음)

### 시나리오 3: 다중 클라이언트

1. ✅ 같은 세션에 3개 이상의 클라이언트 연결
2. ✅ 한 클라이언트가 메시지 전송
3. ✅ 모든 클라이언트가 메시지 수신 확인

---

## 🛠️ 개발 모드에서 디버깅

### 서버 측 로깅 추가

`server/src/services/chat.gateway.ts`에 로깅 추가:

```typescript
private async handleConnection(socket: WebSocket, rawUrl: string) {
  console.log('[ChatGateway] New connection attempt:', rawUrl);
  // ... 기존 코드
  console.log('[ChatGateway] Client registered:', accountId, sessionId);
}

broadcastMessage(sessionId: string, payload: ChatMessageLike) {
  console.log('[ChatGateway] Broadcasting message to session:', sessionId);
  // ... 기존 코드
}
```

### 클라이언트 측 로깅 추가

`lib/core/services/chat_realtime_service.dart`에 로깅 추가:

```dart
void connect() {
  print('[ChatRealtime] Connecting to: ${AppConfig.wsBaseUrl}/ws/chat?...');
  // ... 기존 코드
}

void _handleEvent(dynamic event) {
  print('[ChatRealtime] Received event: $event');
  // ... 기존 코드
}
```

---

## 🧪 자동화된 테스트

### WebSocket 연결 테스트 스크립트

`test/websocket_chat_test.js` 파일 생성:

```javascript
const WebSocket = require('ws');

// JWT 토큰과 세션 ID를 얻어야 함
const token = 'YOUR_JWT_TOKEN';
const sessionId = 'YOUR_SESSION_ID';

const ws = new WebSocket(`ws://localhost:8080/ws/chat?sessionId=${sessionId}&token=${token}`);

ws.on('open', () => {
  console.log('✅ WebSocket connected');
  
  // 메시지 전송
  ws.send(JSON.stringify({
    type: 'message',
    content: '테스트 메시지'
  }));
});

ws.on('message', (data) => {
  console.log('📨 Received:', data.toString());
});

ws.on('error', (error) => {
  console.error('❌ WebSocket error:', error);
});

ws.on('close', () => {
  console.log('🔌 WebSocket closed');
});
```

실행:
```bash
node test/websocket_chat_test.js
```

---

## 📊 성능 테스트

### 동시 연결 테스트

여러 WebSocket 클라이언트를 동시에 연결하여 서버 성능 확인:

```javascript
// test/load_test.js
const WebSocket = require('ws');

const clients = [];
const count = 100; // 동시 연결 수

for (let i = 0; i < count; i++) {
  const ws = new WebSocket('ws://localhost:8080/ws/chat?sessionId=test&token=test');
  clients.push(ws);
  
  ws.on('open', () => {
    console.log(`Client ${i} connected`);
  });
  
  ws.on('error', (error) => {
    console.error(`Client ${i} error:`, error.message);
  });
}
```

---

## ✅ 체크리스트

테스트 전 확인 사항:

- [ ] 서버가 `http://localhost:8080`에서 실행 중
- [ ] WebSocket 게이트웨이가 `/ws/chat` 경로에 연결됨
- [ ] Flutter 앱이 실행 중
- [ ] 유효한 JWT 토큰이 있음
- [ ] 채팅 세션이 생성되어 있음
- [ ] 브라우저 개발자 도구에서 WebSocket 연결 확인 가능

---

## 🎯 예상 결과

정상 작동 시:

1. ✅ 채팅 화면 접근 시 WebSocket 자동 연결
2. ✅ 메시지 전송 시 즉시 화면에 표시 (Optimistic UI)
3. ✅ 서버에서 브로드캐스트된 메시지가 다른 클라이언트에 즉시 표시
4. ✅ 네트워크 탭에서 WebSocket 메시지 송수신 확인 가능
5. ✅ 서버 로그에서 연결 및 메시지 브로드캐스트 로그 확인 가능

---

## 📚 추가 리소스

- [WebSocket API 문서](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
- [ws 라이브러리 문서](https://github.com/websockets/ws)
- [Flutter WebSocket 문서](https://pub.dev/packages/web_socket_channel)


