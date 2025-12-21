// 대시보드 페이지
let currentPage = 1;
let currentStatus = 'pending';
const limit = 20;

// 전역 함수들을 먼저 정의 (HTML의 onclick에서 사용 가능하도록 - fallback)
window.logout = function() {
    console.log('[Dashboard] 로그아웃 버튼 클릭됨 (전역 함수)');
    if (confirm('로그아웃하시겠습니까?')) {
        console.log('[Dashboard] 로그아웃 확인됨');
        try {
            if (typeof auth !== 'undefined' && auth.logout) {
                auth.logout();
            } else {
                console.error('[Dashboard] auth 객체를 찾을 수 없습니다');
                // 직접 로그아웃 처리
                localStorage.removeItem('admin_token');
                localStorage.removeItem('admin_email');
                window.location.href = 'index.html';
            }
        } catch (error) {
            console.error('[Dashboard] 로그아웃 오류:', error);
            alert('로그아웃 중 오류가 발생했습니다.');
        }
    }
};

window.viewDetail = function(profileId) {
    console.log('[Dashboard] 상세 페이지로 이동:', profileId);
    if (!profileId) {
        console.error('[Dashboard] profileId가 없습니다');
        return;
    }
    window.location.href = `detail.html?id=${profileId}`;
};

window.loadCertifications = async function() {
    console.log('[Dashboard] 인증 신청 목록 로드 시작, 상태:', currentStatus);
    const loadingIndicator = document.getElementById('loadingIndicator');
    const certificationsList = document.getElementById('certificationsList');
    
    if (!loadingIndicator || !certificationsList) {
        console.error('[Dashboard] 필수 요소를 찾을 수 없습니다');
        return;
    }
    
    loadingIndicator.style.display = 'block';
    certificationsList.innerHTML = '';
    
    try {
        const response = await api.getCertifications(currentStatus, currentPage, limit);
        const certifications = response.data || [];
        const pagination = response.pagination || {};
        
        console.log('[Dashboard] 인증 신청 목록 로드 완료:', certifications.length, '개');
        
        // 통계 업데이트
        updateStats(response);
        
        // 목록 표시
        if (certifications.length === 0) {
            certificationsList.innerHTML = '<div class="certification-card"><p style="text-align: center; color: #999;">인증 신청이 없습니다.</p></div>';
        } else {
            certificationsList.innerHTML = certifications.map(cert => createCertificationCard(cert)).join('');
            // 이벤트 위임으로 카드 클릭 처리
            setupCardClickHandlers();
        }
        
        // 페이지네이션 표시
        renderPagination(pagination);
        
    } catch (error) {
        console.error('[Dashboard] 인증 신청 목록 로드 실패:', error);
        certificationsList.innerHTML = `<div class="error-message">${error.message}</div>`;
    } finally {
        loadingIndicator.style.display = 'none';
    }
};

window.goToPage = function(page) {
    console.log('[Dashboard] 페이지 이동:', page);
    currentPage = page;
    loadCertifications();
    window.scrollTo({ top: 0, behavior: 'smooth' });
};

// 카드 클릭 이벤트 위임 설정
function setupCardClickHandlers() {
    const certificationsList = document.getElementById('certificationsList');
    if (!certificationsList) return;
    
    // 기존 이벤트 리스너 제거 (중복 방지)
    const newList = certificationsList.cloneNode(true);
    certificationsList.parentNode.replaceChild(newList, certificationsList);
    
    // 이벤트 위임으로 카드 클릭 처리
    newList.addEventListener('click', (e) => {
        const card = e.target.closest('.certification-card');
        if (card) {
            const profileId = card.dataset.profileId;
            if (profileId) {
                console.log('[Dashboard] 카드 클릭됨, profileId:', profileId);
                viewDetail(profileId);
            } else {
                console.warn('[Dashboard] 카드에 profileId가 없습니다');
            }
        }
    });
}

document.addEventListener('DOMContentLoaded', () => {
    console.log('[Dashboard] DOMContentLoaded 이벤트 발생');
    
    // 인증 확인
    auth.requireAuth();
    
    // 사용자 이메일 표시
    const userEmail = auth.getEmail();
    if (userEmail) {
        const userEmailEl = document.getElementById('userEmail');
        if (userEmailEl) {
            userEmailEl.textContent = userEmail;
        }
    }
    
    // 로그아웃 버튼 이벤트
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', () => {
            console.log('[Dashboard] 로그아웃 버튼 클릭됨 (이벤트 리스너)');
            if (confirm('로그아웃하시겠습니까?')) {
                console.log('[Dashboard] 로그아웃 확인됨');
                try {
                    auth.logout();
                } catch (error) {
                    console.error('[Dashboard] 로그아웃 오류:', error);
                    alert('로그아웃 중 오류가 발생했습니다.');
                }
            }
        });
    } else {
        console.error('[Dashboard] 로그아웃 버튼을 찾을 수 없습니다');
    }
    
    // 필터 변경 이벤트
    const statusFilter = document.getElementById('statusFilter');
    if (statusFilter) {
        statusFilter.addEventListener('change', (e) => {
            currentStatus = e.target.value;
            currentPage = 1;
            console.log('[Dashboard] 필터 변경:', currentStatus);
            loadCertifications();
        });
        
        // 초기 필터 값 설정
        statusFilter.value = currentStatus;
    }
    
    // 초기 로드
    loadCertifications();
});


// 통계 업데이트
async function updateStats(currentResponse) {
    try {
        // 전체 통계 가져오기
        const [pendingRes, verifiedRes, allRes] = await Promise.all([
            api.getCertifications('pending', 1, 1),
            api.getCertifications('verified', 1, 1),
            api.getCertifications('all', 1, 1),
        ]);
        
        document.getElementById('pendingCount').textContent = pendingRes.pagination?.total || 0;
        document.getElementById('verifiedCount').textContent = verifiedRes.pagination?.total || 0;
        document.getElementById('totalCount').textContent = allRes.pagination?.total || 0;
    } catch (error) {
        console.error('통계 업데이트 실패:', error);
    }
}

// 날짜 포맷팅 함수
function formatDateTime(dateString) {
    if (!dateString) return '-';
    
    try {
        const date = new Date(dateString);
        
        // 유효한 날짜인지 확인
        if (isNaN(date.getTime())) {
            console.warn('[Dashboard] 잘못된 날짜:', dateString);
            return dateString;
        }
        
        // 한국 시간대로 포맷팅 (옵션 명시)
        return date.toLocaleString('ko-KR', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false, // 24시간 형식
            timeZone: 'Asia/Seoul', // 한국 시간대 명시
        });
    } catch (error) {
        console.error('[Dashboard] 날짜 포맷팅 오류:', error, dateString);
        return dateString;
    }
}

// 인증 신청 카드 생성
function createCertificationCard(cert) {
    const statusClass = `status-${cert.certificationStatus}`;
    const statusText = {
        'pending': '대기 중',
        'verified': '승인됨',
        'none': '거부됨',
    }[cert.certificationStatus] || cert.certificationStatus;
    
    // 인증 신청 일시는 updatedAt을 사용 (인증 상태가 변경된 시점)
    // pending 상태인 경우, updatedAt이 인증 신청 시점을 나타냄
    const requestDate = cert.updatedAt || cert.createdAt;
    const formattedDate = formatDateTime(requestDate);
    
    // data-profile-id 속성을 사용하여 이벤트 위임으로 처리
    return `
        <div class="certification-card" data-profile-id="${escapeHtml(cert.id)}" style="cursor: pointer;">
            <div class="certification-header">
                <div class="certification-title">${escapeHtml(cert.name || '이름 없음')}</div>
                <span class="status-badge ${statusClass}">${statusText}</span>
            </div>
            <div class="certification-info">
                <div class="certification-info-item">
                    <span class="certification-info-label">이메일</span>
                    ${escapeHtml(cert.email || '-')}
                </div>
                <div class="certification-info-item">
                    <span class="certification-info-label">자격증 번호</span>
                    ${escapeHtml(cert.licenseNumber || '-')}
                </div>
                <div class="certification-info-item">
                    <span class="certification-info-label">클리닉</span>
                    ${escapeHtml(cert.clinicName || '-')}
                </div>
                <div class="certification-info-item">
                    <span class="certification-info-label">신청 일시</span>
                    ${formattedDate}
                </div>
            </div>
        </div>
    `;
}


// 페이지네이션 렌더링
function renderPagination(pagination) {
    const paginationEl = document.getElementById('pagination');
    
    if (!pagination || pagination.totalPages <= 1) {
        paginationEl.innerHTML = '';
        return;
    }
    
    const { page, totalPages } = pagination;
    let html = '';
    
    // 이전 페이지
    html += `<button ${page <= 1 ? 'disabled' : ''} onclick="goToPage(${page - 1})">이전</button>`;
    
    // 페이지 번호
    for (let i = 1; i <= totalPages; i++) {
        if (i === 1 || i === totalPages || (i >= page - 2 && i <= page + 2)) {
            html += `<button class="${i === page ? 'active' : ''}" onclick="goToPage(${i})">${i}</button>`;
        } else if (i === page - 3 || i === page + 3) {
            html += `<span>...</span>`;
        }
    }
    
    // 다음 페이지
    html += `<button ${page >= totalPages ? 'disabled' : ''} onclick="goToPage(${page + 1})">다음</button>`;
    
    paginationEl.innerHTML = html;
}


// HTML 이스케이프
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}


