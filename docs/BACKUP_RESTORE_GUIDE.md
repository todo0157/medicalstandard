# 백업 및 복원 가이드

**작성일**: 2026-01-23  
**목적**: UI/UX 개선 작업 전 백업 및 복원 방법

---

## 🔄 백업 전략

### 1. Git 브랜치 백업 (권장)

#### 현재 백업 상태
- **백업 브랜치**: `backup/before-ui-ux-improvement-20260123`
- **작업 브랜치**: `feature/ui-ux-improvement-phase1`
- **원본 브랜치**: `main`

#### 백업 시점
현재 작업을 시작하기 직전의 상태가 `backup/before-ui-ux-improvement-20260123` 브랜치에 저장되어 있습니다.

---

## 📂 백업 파일 구조

### 주요 백업 대상 파일
```
lib/
├── features/
│   ├── home/screens/main_app_shell_screen.dart
│   ├── life/screens/life_screen.dart
│   ├── profile/screens/profile_screen.dart
│   ├── chat/screens/chat_list_screen.dart
│   ├── booking/appointment_booking_screen.dart
│   ├── doctor/screens/find_doctor_screen.dart
│   └── medical_records/medical_records_screen.dart
├── shared/theme/
│   └── app_colors.dart
└── main.dart

docs/
└── ui_ux_improvement_plan_20260123.md (새로 작성된 계획서)
```

---

## 🔙 복원 방법

### 방법 1: 백업 브랜치로 완전 복원 (모든 변경 사항 취소)

```powershell
# 현재 작업 중인 모든 변경 사항을 버리고 백업 시점으로 복원
git checkout backup/before-ui-ux-improvement-20260123

# 또는 main 브랜치로 돌아가기 (백업 시점과 동일)
git checkout main
```

**주의**: 이 방법은 작업 브랜치의 모든 변경 사항을 잃게 됩니다!

---

### 방법 2: 특정 파일만 복원

특정 파일이 마음에 들지 않을 때, 백업 시점의 해당 파일만 복원:

```powershell
# 현재 feature/ui-ux-improvement-phase1 브랜치에 있는 상태에서
# 특정 파일을 백업 브랜치에서 가져오기

git checkout backup/before-ui-ux-improvement-20260123 -- lib/features/home/screens/main_app_shell_screen.dart

# 여러 파일을 한 번에 복원
git checkout backup/before-ui-ux-improvement-20260123 -- lib/features/profile/screens/profile_screen.dart lib/shared/theme/app_colors.dart
```

---

### 방법 3: 브랜치 비교 및 선택적 복원

변경 사항을 비교하고 원하는 부분만 복원:

```powershell
# 백업 브랜치와 현재 브랜치의 차이 확인
git diff backup/before-ui-ux-improvement-20260123 feature/ui-ux-improvement-phase1

# 특정 파일의 차이만 확인
git diff backup/before-ui-ux-improvement-20260123 feature/ui-ux-improvement-phase1 -- lib/features/home/screens/main_app_shell_screen.dart
```

---

### 방법 4: 작업 브랜치 전체 삭제 후 재시작

작업을 완전히 처음부터 다시 시작하고 싶을 때:

```powershell
# main 또는 백업 브랜치로 이동
git checkout main

# 작업 브랜치 삭제
git branch -D feature/ui-ux-improvement-phase1

# 새로운 작업 브랜치 생성
git checkout -b feature/ui-ux-improvement-phase1-v2
```

---

## 💾 추가 백업 방법 (이중 안전장치)

### 물리적 파일 백업

Git과 별도로 중요 파일을 백업 폴더에 복사:

```powershell
# 백업 폴더 생성
mkdir backup_20260123

# 주요 파일 복사
Copy-Item -Path "lib" -Destination "backup_20260123\lib" -Recurse
Copy-Item -Path "docs" -Destination "backup_20260123\docs" -Recurse
Copy-Item -Path "pubspec.yaml" -Destination "backup_20260123\"
Copy-Item -Path "README.md" -Destination "backup_20260123\"
```

#### 물리적 백업에서 복원
```powershell
# 특정 파일 복원
Copy-Item -Path "backup_20260123\lib\features\home\screens\main_app_shell_screen.dart" -Destination "lib\features\home\screens\" -Force

# 전체 복원
Remove-Item -Path "lib" -Recurse -Force
Copy-Item -Path "backup_20260123\lib" -Destination "lib" -Recurse
```

---

## 🎯 권장 워크플로우

### 단계별 안전한 작업 방법

#### Phase 1 시작 전 (현재)
```powershell
# ✅ 이미 완료됨
# 1. 백업 브랜치 생성: backup/before-ui-ux-improvement-20260123
# 2. 작업 브랜치 생성: feature/ui-ux-improvement-phase1
```

#### Phase 1 작업 중
```powershell
# 작은 단위로 자주 커밋
git add lib/shared/theme/app_colors.dart
git commit -m "feat: 색상 시스템 통합 - 하니비 브랜딩 색상 추가"

git add lib/shared/theme/app_typography.dart
git commit -m "feat: 타이포그래피 시스템 추가"

# 이런 식으로 작은 단위로 커밋하면 언제든지 특정 시점으로 돌아갈 수 있음
```

#### Phase 1 완료 후
```powershell
# Phase 1이 만족스러우면 main에 병합
git checkout main
git merge feature/ui-ux-improvement-phase1

# Phase 2 시작
git checkout -b feature/ui-ux-improvement-phase2
```

#### 특정 변경이 마음에 들지 않을 때
```powershell
# 마지막 커밋 취소 (변경 사항 유지)
git reset --soft HEAD~1

# 마지막 커밋 취소 (변경 사항도 취소)
git reset --hard HEAD~1

# 특정 파일만 이전 상태로 복원
git checkout HEAD~1 -- lib/features/home/screens/main_app_shell_screen.dart
```

---

## 📊 현재 브랜치 상태 확인

```powershell
# 모든 브랜치 목록
git branch -a

# 현재 브랜치와 백업 브랜치의 차이
git diff backup/before-ui-ux-improvement-20260123

# 커밋 히스토리
git log --oneline --graph --all
```

---

## ⚠️ 주의사항

### 절대 하지 말아야 할 것
❌ **main 브랜치에서 직접 작업하지 마세요**  
❌ **백업 브랜치(`backup/before-ui-ux-improvement-20260123`)를 수정하지 마세요**  
❌ **`git push -f` (force push)를 사용하지 마세요** (원격 저장소가 있는 경우)

### 항상 해야 할 것
✅ **작업 브랜치에서만 작업하세요**  
✅ **자주 커밋하세요** (작은 단위로)  
✅ **커밋 메시지를 명확하게 작성하세요**  
✅ **중요한 변경 전에는 백업 확인하세요**

---

## 🚀 지금 바로 시작하기

현재 상태:
- ✅ 파일명 변경 완료: `ui_ux_improvement_plan_20260123.md`
- ✅ 백업 브랜치 생성 완료: `backup/before-ui-ux-improvement-20260123`
- ✅ 작업 브랜치 생성 완료: `feature/ui-ux-improvement-phase1`

**다음 단계**:
1. Phase 1 작업 시작 (디자인 시스템 구축)
2. 작은 단위로 커밋하면서 진행
3. 언제든지 백업 브랜치로 복원 가능

---

## 📞 도움이 필요할 때

### 백업 브랜치 목록 확인
```powershell
git branch | Select-String "backup"
```

### 현재 브랜치 확인
```powershell
git branch --show-current
```

### 백업 시점으로 돌아가기 (안전한 방법)
```powershell
# 1. 현재 작업 중인 내용을 임시 저장
git stash

# 2. 백업 브랜치로 이동
git checkout backup/before-ui-ux-improvement-20260123

# 3. 다시 작업 브랜치로 돌아가기
git checkout feature/ui-ux-improvement-phase1

# 4. 임시 저장한 내용 복원 (필요한 경우)
git stash pop
```

---

**백업 완료! 안전하게 작업을 시작할 수 있습니다.** ✅

