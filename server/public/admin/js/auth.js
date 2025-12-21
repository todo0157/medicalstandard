// 인증 관리
const auth = {
    // 토큰 저장
    setToken(token) {
        localStorage.setItem('admin_token', token);
    },
    
    // 토큰 가져오기
    getToken() {
        return localStorage.getItem('admin_token');
    },
    
    // 이메일 저장
    setEmail(email) {
        localStorage.setItem('admin_email', email);
    },
    
    // 이메일 가져오기
    getEmail() {
        return localStorage.getItem('admin_email');
    },
    
    // 로그아웃
    logout() {
        console.log('[Auth] 로그아웃 시작');
        try {
            localStorage.removeItem('admin_token');
            localStorage.removeItem('admin_email');
            console.log('[Auth] 로컬 스토리지 정리 완료');
            console.log('[Auth] 로그인 페이지로 리다이렉트');
            window.location.href = 'index.html';
        } catch (error) {
            console.error('[Auth] 로그아웃 오류:', error);
            // 오류가 발생해도 강제로 리다이렉트
            window.location.href = 'index.html';
        }
    },
    
    // 로그인 확인
    isAuthenticated() {
        return !!this.getToken();
    },
    
    // 보호된 페이지 리다이렉트
    requireAuth() {
        if (!this.isAuthenticated()) {
            window.location.href = 'index.html';
        }
    },
};


