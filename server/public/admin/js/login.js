// login.js - 관리자 로그인 처리

document.addEventListener('DOMContentLoaded', () => {
    const loginBtn = document.getElementById('loginBtn');
    if (loginBtn) {
        loginBtn.addEventListener('click', handleLogin);
    }
    
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', (e) => {
            e.preventDefault();
            handleLogin();
        });
    }
});

async function handleLogin() {
    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value;
    const errorDiv = document.getElementById('errorMessage');
    const loginBtn = document.getElementById('loginBtn');
    
    if (!email || !password) {
        errorDiv.textContent = '이메일과 비밀번호를 입력해주세요.';
        errorDiv.style.display = 'block';
        return;
    }

    errorDiv.style.display = 'none';
    loginBtn.disabled = true;
    loginBtn.textContent = '로그인 중...';

    try {
        console.log('Attempting login...', email);
        const response = await fetch('/api/auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });

        const result = await response.json();
        console.log('Login response:', response.status, result);

        if (response.ok) {
            // auth.js와 일치하는 이름으로 저장 (admin_token, admin_email)
            localStorage.setItem('admin_token', result.data.token);
            localStorage.setItem('admin_email', email);
            console.log('Login successful, redirecting...');
            window.location.href = '/admin/dashboard.html';
        } else {
            errorDiv.textContent = result.message || '이메일 또는 비밀번호가 틀렸습니다.';
            errorDiv.style.display = 'block';
        }
    } catch (error) {
        console.error('Login error:', error);
        errorDiv.textContent = '서버와 통신할 수 없습니다.';
        errorDiv.style.display = 'block';
    } finally {
        loginBtn.disabled = false;
        loginBtn.textContent = '로그인';
    }
}
