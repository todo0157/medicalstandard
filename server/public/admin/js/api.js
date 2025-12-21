// API 기본 설정
const API_BASE_URL = window.location.origin;

// API 클라이언트
const api = {
    // 인증
    async login(email, password) {
        const response = await fetch(`${API_BASE_URL}/api/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ email, password }),
        });
        
        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.message || '로그인에 실패했습니다.');
        }
        
        return await response.json();
    },
    
    // 인증 신청 목록 조회
    async getCertifications(status = 'pending', page = 1, limit = 20) {
        const token = auth.getToken();
        if (!token) {
            throw new Error('로그인이 필요합니다.');
        }
        
        const response = await fetch(
            `${API_BASE_URL}/api/admin/certifications?status=${status}&page=${page}&limit=${limit}`,
            {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${token}`,
                },
            }
        );
        
        if (!response.ok) {
            if (response.status === 401 || response.status === 403) {
                auth.logout();
                throw new Error('인증이 필요하거나 권한이 없습니다.');
            }
            const error = await response.json();
            throw new Error(error.message || '인증 신청 목록을 불러오는데 실패했습니다.');
        }
        
        return await response.json();
    },
    
    // 인증 상세 조회
    async getCertificationDetail(profileId) {
        const token = auth.getToken();
        if (!token) {
            throw new Error('로그인이 필요합니다.');
        }
        
        const response = await fetch(
            `${API_BASE_URL}/api/admin/certifications/${profileId}`,
            {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${token}`,
                },
            }
        );
        
        if (!response.ok) {
            if (response.status === 401 || response.status === 403) {
                auth.logout();
                throw new Error('인증이 필요하거나 권한이 없습니다.');
            }
            const error = await response.json();
            throw new Error(error.message || '인증 상세 정보를 불러오는데 실패했습니다.');
        }
        
        return await response.json();
    },
    
    // 인증 승인
    async approveCertification(profileId, notes = '') {
        const token = auth.getToken();
        if (!token) {
            throw new Error('로그인이 필요합니다.');
        }
        
        const response = await fetch(
            `${API_BASE_URL}/api/admin/certifications/${profileId}/approve`,
            {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ notes }),
            }
        );
        
        if (!response.ok) {
            if (response.status === 401 || response.status === 403) {
                auth.logout();
                throw new Error('인증이 필요하거나 권한이 없습니다.');
            }
            const error = await response.json();
            throw new Error(error.message || '인증 승인에 실패했습니다.');
        }
        
        return await response.json();
    },
    
    // 인증 거부
    async rejectCertification(profileId, reason, notes = '') {
        const token = auth.getToken();
        if (!token) {
            throw new Error('로그인이 필요합니다.');
        }
        
        const response = await fetch(
            `${API_BASE_URL}/api/admin/certifications/${profileId}/reject`,
            {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ reason, notes }),
            }
        );
        
        if (!response.ok) {
            if (response.status === 401 || response.status === 403) {
                auth.logout();
                throw new Error('인증이 필요하거나 권한이 없습니다.');
            }
            const error = await response.json();
            throw new Error(error.message || '인증 거부에 실패했습니다.');
        }
        
        return await response.json();
    },
};


