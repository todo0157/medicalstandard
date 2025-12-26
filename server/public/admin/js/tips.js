// tips.js - 건강 팁 관리

document.addEventListener('DOMContentLoaded', async () => {
    await loadTips();
    
    // 버튼 이벤트 바인딩 (onclick 속성 대신 JS로 직접 연결)
    const createBtn = document.querySelector('.btn-primary');
    if (createBtn && createBtn.textContent.includes('새 팁')) {
        createBtn.addEventListener('click', openCreateModal);
    }
    
    const refreshBtn = document.querySelector('.btn-secondary');
    if (refreshBtn && refreshBtn.textContent.includes('새로고침')) {
        refreshBtn.addEventListener('click', loadTips);
    }
});

async function loadTips() {
    const token = localStorage.getItem('admin_token');
    const tipsList = document.getElementById('tipsList');
    tipsList.innerHTML = '<div class="loading">로딩 중...</div>';

    try {
        const response = await fetch('/api/contents/tips', {
            headers: { 'Authorization': `Bearer ${token}` }
        });

        const { data } = await response.json();
        
        if (!data || data.length === 0) {
            tipsList.innerHTML = '<div class="no-data">등록된 건강 팁이 없습니다.</div>';
            return;
        }

        tipsList.innerHTML = data.map(tip => `
            <div class="certification-card">
                <div class="card-header">
                    <div class="doctor-info">
                        <h3>${tip.title}</h3>
                        <p>${tip.category} | 조회수 ${tip.viewCount}</p>
                    </div>
                    <div class="status-badge status-verified">${tip.category}</div>
                </div>
                <div class="card-footer">
                    <div class="date">${new Date(tip.createdAt).toLocaleString()}</div>
                    <div class="actions">
                        <button class="btn btn-secondary btn-sm" data-edit-id="${tip.id}">수정</button>
                        <button class="btn btn-danger btn-sm" data-delete-id="${tip.id}">삭제</button>
                    </div>
                </div>
            </div>
        `).join('');

        // 동적으로 생성된 버튼에 이벤트 바인딩
        document.querySelectorAll('[data-edit-id]').forEach(btn => {
            btn.addEventListener('click', () => editTip(btn.dataset.editId));
        });
        
        document.querySelectorAll('[data-delete-id]').forEach(btn => {
            btn.addEventListener('click', () => deleteTip(btn.dataset.deleteId));
        });

    } catch (error) {
        console.error('Error loading tips:', error);
        tipsList.innerHTML = '<div class="error">목록을 불러오지 못했습니다.</div>';
    }
}

function openCreateModal() {
    console.log('Opening create modal...');
    document.getElementById('tipForm').reset();
    document.getElementById('tipId').value = '';
    document.getElementById('modalTitle').textContent = '새 건강 팁 작성';
    document.getElementById('markdownPreview').innerHTML = '';
    document.getElementById('tipModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('tipModal').style.display = 'none';
}

function updatePreview() {
    const content = document.getElementById('content').value;
    document.getElementById('markdownPreview').innerHTML = marked.parse(content);
}

// DOM 로드 완료 후 content 입력 필드에 이벤트 바인딩
window.addEventListener('DOMContentLoaded', () => {
    const contentField = document.getElementById('content');
    if (contentField) {
        contentField.addEventListener('input', updatePreview);
    }
    
    // 취소 버튼 이벤트
    const cancelBtns = document.querySelectorAll('.btn-secondary');
    cancelBtns.forEach(btn => {
        if (btn.textContent.includes('취소')) {
            btn.addEventListener('click', closeModal);
        }
    });
    
    // 저장 버튼 이벤트
    const saveBtns = document.querySelectorAll('.btn-primary');
    saveBtns.forEach(btn => {
        if (btn.textContent.includes('저장')) {
            btn.addEventListener('click', saveTip);
        }
    });
});

async function editTip(id) {
    const token = localStorage.getItem('admin_token');
    try {
        const response = await fetch(`/api/contents/tips/${id}`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const { data } = await response.json();

        document.getElementById('tipId').value = data.id;
        document.getElementById('title').value = data.title;
        document.getElementById('category').value = data.category;
        document.getElementById('imageUrl').value = data.imageUrl || '';
        document.getElementById('content').value = data.content;
        
        document.getElementById('modalTitle').textContent = '건강 팁 수정';
        updatePreview();
        document.getElementById('tipModal').style.display = 'block';
    } catch (error) {
        alert('정보를 불러오지 못했습니다.');
    }
}

async function saveTip() {
    const token = localStorage.getItem('admin_token');
    const id = document.getElementById('tipId').value;
    const isEdit = !!id;
    
    const payload = {
        title: document.getElementById('title').value,
        category: document.getElementById('category').value,
        imageUrl: document.getElementById('imageUrl').value || undefined,
        content: document.getElementById('content').value,
    };

    if (!payload.title || !payload.content) {
        alert('제목과 내용은 필수입니다.');
        return;
    }

    try {
        const url = isEdit ? `/api/contents/tips/${id}` : '/api/contents/tips';
        const method = isEdit ? 'PUT' : 'POST';

        const response = await fetch(url, {
            method,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify(payload)
        });

        if (!response.ok) throw new Error('저장 실패');

        closeModal();
        await loadTips();
        alert('저장되었습니다.');
    } catch (error) {
        alert(`저장 중 오류가 발생했습니다.`);
    }
}

async function deleteTip(id) {
    if (!confirm('정말 삭제하시겠습니까?')) return;

    const token = localStorage.getItem('admin_token');
    try {
        const response = await fetch(`/api/contents/tips/${id}`, {
            method: 'DELETE',
            headers: { 'Authorization': `Bearer ${token}` }
        });

        if (!response.ok) throw new Error('삭제 실패');
        await loadTips();
    } catch (error) {
        alert('삭제 중 오류가 발생했습니다.');
    }
}
