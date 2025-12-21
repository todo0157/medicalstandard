// 로그인 페이지
document.addEventListener('DOMContentLoaded', () => {
    // 이미 로그인되어 있으면 대시보드로 리다이렉트
    if (auth.isAuthenticated()) {
        window.location.href = 'dashboard.html';
        return;
    }
    
    const loginForm = document.getElementById('loginForm');
    const loginBtn = document.getElementById('loginBtn');
    const errorMessage = document.getElementById('errorMessage');
    
    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const email = document.getElementById('email').value.trim();
        const password = document.getElementById('password').value;
        
        if (!email || !password) {
            showError('이메일과 비밀번호를 입력해주세요.');
            return;
        }
        
        // 로딩 상태
        loginBtn.disabled = true;
        loginBtn.textContent = '로그인 중...';
        errorMessage.style.display = 'none';
        
        try {
            const response = await api.login(email, password);
            
            // 토큰 저장
            auth.setToken(response.data.token);
            auth.setEmail(email);
            
            // 대시보드로 이동
            window.location.href = 'dashboard.html';
        } catch (error) {
            showError(error.message);
            loginBtn.disabled = false;
            loginBtn.textContent = '로그인';
        }
    });
    
    function showError(message) {
        errorMessage.textContent = message;
        errorMessage.className = 'error-message';
        errorMessage.style.display = 'block';
    }
});


