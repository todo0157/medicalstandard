// 상세 페이지
let currentProfileId = null;

document.addEventListener('DOMContentLoaded', () => {
    console.log('[Detail] DOMContentLoaded 이벤트 발생');
    
    // 인증 확인
    auth.requireAuth();
    
    // URL에서 profileId 가져오기
    const urlParams = new URLSearchParams(window.location.search);
    currentProfileId = urlParams.get('id');
    
    if (!currentProfileId) {
        showError('인증 신청 ID가 없습니다.');
        return;
    }
    
    // 목록으로 버튼 이벤트
    const backToListBtn = document.getElementById('backToListBtn');
    if (backToListBtn) {
        backToListBtn.addEventListener('click', () => {
            console.log('[Detail] 목록으로 버튼 클릭됨');
            window.location.href = 'dashboard.html';
        });
    }
    
    // 승인 버튼 이벤트
    const approveBtn = document.getElementById('approveBtn');
    if (approveBtn) {
        approveBtn.addEventListener('click', () => {
            console.log('[Detail] 승인 버튼 클릭됨');
            showApproveModal();
        });
    }
    
    // 거부 버튼 이벤트
    const rejectBtn = document.getElementById('rejectBtn');
    if (rejectBtn) {
        rejectBtn.addEventListener('click', () => {
            console.log('[Detail] 거부 버튼 클릭됨');
            showRejectModal();
        });
    }
    
    // 승인 모달 확인 버튼
    const confirmApproveBtn = document.getElementById('confirmApproveBtn');
    if (confirmApproveBtn) {
        confirmApproveBtn.addEventListener('click', () => {
            console.log('[Detail] 승인 모달 확인 버튼 클릭됨');
            approveCertification();
        });
    }
    
    // 승인 모달 취소 버튼
    const cancelApproveBtn = document.getElementById('cancelApproveBtn');
    if (cancelApproveBtn) {
        cancelApproveBtn.addEventListener('click', () => {
            console.log('[Detail] 승인 모달 취소 버튼 클릭됨');
            closeApproveModal();
        });
    }
    
    // 거부 모달 확인 버튼
    const confirmRejectBtn = document.getElementById('confirmRejectBtn');
    if (confirmRejectBtn) {
        confirmRejectBtn.addEventListener('click', () => {
            console.log('[Detail] 거부 모달 확인 버튼 클릭됨');
            rejectCertification();
        });
    }
    
    // 거부 모달 취소 버튼
    const cancelRejectBtn = document.getElementById('cancelRejectBtn');
    if (cancelRejectBtn) {
        cancelRejectBtn.addEventListener('click', () => {
            console.log('[Detail] 거부 모달 취소 버튼 클릭됨');
            closeRejectModal();
        });
    }
    
    // 상세 정보 로드
    loadDetail();
});

// 상세 정보 로드
async function loadDetail() {
    const loadingIndicator = document.getElementById('loadingIndicator');
    const detailContent = document.getElementById('detailContent');
    
    loadingIndicator.style.display = 'block';
    detailContent.style.display = 'none';
    
    try {
        const response = await api.getCertificationDetail(currentProfileId);
        const data = response.data;
        
        // 기본 정보 표시
        document.getElementById('detailName').textContent = data.name || '-';
        document.getElementById('detailEmail').textContent = data.email || '-';
        document.getElementById('detailLicenseNumber').textContent = data.licenseNumber || '-';
        document.getElementById('detailClinicName').textContent = data.clinicName || '-';
        
        // 상태 표시
        const statusEl = document.getElementById('detailStatus');
        const statusText = {
            'pending': '대기 중',
            'verified': '승인됨',
            'none': '거부됨',
        }[data.certificationStatus] || data.certificationStatus;
        statusEl.textContent = statusText;
        statusEl.className = `status-badge status-${data.certificationStatus}`;
        
        // 신청 일시 포맷팅 함수
        function formatDateTime(dateString) {
            if (!dateString) return '-';
            
            try {
                const date = new Date(dateString);
                
                // 유효한 날짜인지 확인
                if (isNaN(date.getTime())) {
                    console.warn('[Detail] 잘못된 날짜:', dateString);
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
                console.error('[Detail] 날짜 포맷팅 오류:', error, dateString);
                return dateString;
            }
        }
        
        // 인증 신청 일시는 updatedAt을 사용 (인증 상태가 변경된 시점)
        // pending 상태인 경우, updatedAt이 인증 신청 시점을 나타냄
        const requestDate = data.updatedAt || data.createdAt;
        const formattedDate = formatDateTime(requestDate);
        document.getElementById('detailCreatedAt').textContent = formattedDate;
        
        // 이미지 표시
        // 자격증 이미지는 profileImageUrl에 저장됨
        displayImage('licenseImageContainer', data.profileImageUrl, '자격증 이미지');
        // 신분증 이미지는 현재 별도 필드가 없으므로 표시하지 않음
        // TODO: 신분증 이미지 필드 추가 필요
        
        // 액션 버튼 표시 (모든 상태에서 표시)
        const actionSection = document.getElementById('actionSection');
        const approveBtn = document.getElementById('approveBtn');
        const rejectBtn = document.getElementById('rejectBtn');
        
        if (actionSection && approveBtn && rejectBtn) {
            // 모든 상태에서 버튼 표시
            actionSection.style.display = 'block';
            
            // 상태에 따라 버튼 표시/숨김 및 텍스트 변경
            if (data.certificationStatus === 'verified') {
                // 이미 승인된 경우: 거부 버튼만 표시
                approveBtn.style.display = 'none';
                rejectBtn.style.display = 'inline-block';
                rejectBtn.textContent = '거부로 변경';
            } else if (data.certificationStatus === 'none') {
                // 이미 거부된 경우: 승인 버튼만 표시
                approveBtn.style.display = 'inline-block';
                approveBtn.textContent = '승인으로 변경';
                rejectBtn.style.display = 'none';
            } else {
                // pending 상태: 둘 다 표시
                approveBtn.style.display = 'inline-block';
                approveBtn.textContent = '승인';
                rejectBtn.style.display = 'inline-block';
                rejectBtn.textContent = '거부';
            }
        }
        
        detailContent.style.display = 'block';
        
    } catch (error) {
        showError(error.message);
    } finally {
        loadingIndicator.style.display = 'none';
    }
}

// 이미지 표시
function displayImage(containerId, imageUrl, altText) {
    const container = document.getElementById(containerId);
    
    if (!imageUrl) {
        container.innerHTML = '<p class="no-image">이미지 없음</p>';
        return;
    }
    
    // data URL인 경우 그대로 사용
    let fullImageUrl = imageUrl;
    
    // data URL이 아닌 경우 절대 경로로 변환
    if (!imageUrl.startsWith('data:')) {
        fullImageUrl = imageUrl.startsWith('http') 
            ? imageUrl 
            : `${window.location.origin}${imageUrl.startsWith('/') ? '' : '/'}${imageUrl}`;
    }
    
    // XSS 방지를 위해 이스케이프 처리
    const escapedUrl = fullImageUrl.replace(/'/g, "\\'").replace(/"/g, "&quot;");
    const escapedAlt = altText.replace(/'/g, "\\'").replace(/"/g, "&quot;");
    
    container.innerHTML = `
        <img src="${escapedUrl}" alt="${escapedAlt}" style="max-width: 100%; cursor: pointer; border-radius: 4px;" onclick="openImageModal('${escapedUrl}')">
    `;
}

// 이미지 모달 열기 (전역 함수로 노출)
window.openImageModal = function(imageUrl) {
    console.log('[Detail] 이미지 모달 열기:', imageUrl);
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.style.display = 'flex';
    
    // XSS 방지를 위해 이스케이프 처리
    const escapedUrl = imageUrl.replace(/'/g, "\\'").replace(/"/g, "&quot;");
    
    modal.innerHTML = `
        <div class="modal-content" style="max-width: 90%; max-height: 90%;">
            <button class="btn btn-secondary" onclick="this.closest('.modal').remove()" style="margin-bottom: 1rem;">닫기</button>
            <img src="${escapedUrl}" alt="확대 이미지" style="max-width: 100%; max-height: 80vh; border-radius: 4px;">
        </div>
    `;
    modal.onclick = (e) => {
        if (e.target === modal) {
            modal.remove();
        }
    };
    document.body.appendChild(modal);
};

// 승인 모달 표시
function showApproveModal() {
    console.log('[Detail] showApproveModal 함수 호출됨');
    const modal = document.getElementById('approveModal');
    const notesField = document.getElementById('approveNotes');
    
    if (!modal) {
        console.error('[Detail] 승인 모달을 찾을 수 없습니다');
        return;
    }
    
    modal.style.display = 'flex';
    if (notesField) {
        notesField.value = '';
    }
}

// 승인 모달 닫기
function closeApproveModal() {
    console.log('[Detail] closeApproveModal 함수 호출됨');
    const modal = document.getElementById('approveModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// 거부 모달 표시
function showRejectModal() {
    console.log('[Detail] showRejectModal 함수 호출됨');
    const modal = document.getElementById('rejectModal');
    const reasonField = document.getElementById('rejectReason');
    const notesField = document.getElementById('rejectNotes');
    
    if (!modal) {
        console.error('[Detail] 거부 모달을 찾을 수 없습니다');
        return;
    }
    
    modal.style.display = 'flex';
    if (reasonField) {
        reasonField.value = '';
    }
    if (notesField) {
        notesField.value = '';
    }
}

// 거부 모달 닫기
function closeRejectModal() {
    console.log('[Detail] closeRejectModal 함수 호출됨');
    const modal = document.getElementById('rejectModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// 인증 승인
async function approveCertification() {
    console.log('[Detail] approveCertification 함수 호출됨');
    const notesField = document.getElementById('approveNotes');
    const notes = notesField ? notesField.value.trim() : '';
    const btn = document.getElementById('confirmApproveBtn');
    
    if (!btn) {
        console.error('[Detail] 승인 확인 버튼을 찾을 수 없습니다');
        return;
    }
    
    const originalText = btn.textContent;
    btn.disabled = true;
    btn.textContent = '처리 중...';
    
    try {
        console.log('[Detail] API 호출 시작, profileId:', currentProfileId, 'notes:', notes);
        await api.approveCertification(currentProfileId, notes);
        console.log('[Detail] 승인 성공');
        alert('인증이 승인되었습니다.');
        closeApproveModal();
        loadDetail(); // 상세 정보 새로고침
    } catch (error) {
        console.error('[Detail] 승인 오류:', error);
        alert(`승인 실패: ${error.message}`);
    } finally {
        btn.disabled = false;
        btn.textContent = originalText;
    }
}

// 인증 거부
async function rejectCertification() {
    console.log('[Detail] rejectCertification 함수 호출됨');
    const reasonField = document.getElementById('rejectReason');
    const notesField = document.getElementById('rejectNotes');
    const reason = reasonField ? reasonField.value.trim() : '';
    const notes = notesField ? notesField.value.trim() : '';
    
    if (!reason) {
        alert('거부 사유를 입력해주세요.');
        if (reasonField) {
            reasonField.focus();
        }
        return;
    }
    
    const btn = document.getElementById('confirmRejectBtn');
    if (!btn) {
        console.error('[Detail] 거부 확인 버튼을 찾을 수 없습니다');
        return;
    }
    
    const originalText = btn.textContent;
    btn.disabled = true;
    btn.textContent = '처리 중...';
    
    try {
        console.log('[Detail] API 호출 시작, profileId:', currentProfileId, 'reason:', reason, 'notes:', notes);
        await api.rejectCertification(currentProfileId, reason, notes);
        console.log('[Detail] 거부 성공');
        alert('인증이 거부되었습니다.');
        closeRejectModal();
        loadDetail(); // 상세 정보 새로고침
    } catch (error) {
        console.error('[Detail] 거부 오류:', error);
        alert(`거부 실패: ${error.message}`);
    } finally {
        btn.disabled = false;
        btn.textContent = originalText;
    }
}

// 에러 표시
function showError(message) {
    const detailContent = document.getElementById('detailContent');
    detailContent.innerHTML = `<div class="error-message">${message}</div>`;
    detailContent.style.display = 'block';
}


