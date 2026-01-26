# 프로필 탭 개선 계획 (Phase 1 - Day 9-10)

**작성일**: 2026-01-23  
**대상 파일**: `lib/features/profile/screens/profile_screen.dart`  
**참조 디자인**: APP_reference/ver_plus/방문진료 한의사용_웹 페이지.html (프로필 부분)

---

## 📋 목차

1. [현재 코드 분석](#1-현재-코드-분석)
2. [개선 목표](#2-개선-목표)
3. [상세 작업 계획](#3-상세-작업-계획)
4. [단계별 작업 순서](#4-작업-순서)

---

## 1. 현재 코드 분석

### 1.1 구조
- **ProfileScreen**: 메인 스크린
- **_ProfileCard**: 사용자 정보 표시 (단순 흰색 카드)
- **_CertificationStatusCard**: 한의사 인증 상태
- **_ProfileStats**: 예약/진료 통계 (단순 텍스트)
- **_AppointmentSection**: 예약 목록
- **_QuickActionGrid**: 빠른 실행 메뉴
- **_MenuSection**: 설정, 로그아웃 등 메뉴

### 1.2 문제점
1. **디자인 시스템 미적용**:
   - 하드코딩된 스타일 (`Theme.of(context)` 등 혼재)
   - 일관되지 않은 여백과 색상
2. **시각적 매력 부족**:
   - 프로필 헤더가 너무 단순함
   - 통계 카드가 눈에 띄지 않음
3. **컴포넌트 재사용 미흡**:
   - 직접 구현된 카드들이 많음 (`AppBaseCard` 등 사용 필요)

---

## 2. 개선 목표

### 2.1 디자인 시스템 통합
✅ **색상**: `AppColors` 사용  
✅ **타이포그래피**: `AppTypography` 사용  
✅ **컴포넌트**: `AppGradientCard`, `AppStatCard`, `AppBaseCard` 활용

### 2.2 UI 개선
✅ **프로필 헤더**:
   - `AppGradientCard` 사용 (Blue Gradient)
   - 프로필 이미지 강조
✅ **통계 섹션**:
   - `AppStatCard` 활용하여 시각적 강조
   - 아이콘 + 숫자 + 라벨 구조
✅ **예약 목록**:
   - 카드 스타일 개선 (상태 배지, 아이콘)
   - 빈 상태 개선

---

## 3. 상세 작업 계획

### Step 1: Import 추가
```dart
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/widgets/common_button.dart';
import '../../../shared/widgets/common_card.dart';
import '../../../shared/widgets/common_badge.dart';
```

### Step 2: _ProfileCard 개선 (헤더)
- `AppGradientCard` 사용
- 배경: `AppColors.blueGradient`
- 텍스트 색상: White

### Step 3: _ProfileStats 개선
- `AppStatCard` 사용
- Row 안에 2개(또는 3개)의 StatCard 배치

### Step 4: _AppointmentSection 개선
- `AppBaseCard` 사용
- `AppStatusBadge` 사용

### Step 5: _QuickActionGrid 및 _MenuSection 개선
- `AppInfoCard` 또는 커스텀 리스트 아이템 사용

---

## 4. 작업 순서

1. **Import 추가** (1분)
2. **프로필 헤더 (_ProfileCard) 교체** (10분)
3. **통계 섹션 (_ProfileStats) 교체** (10분)
4. **예약 목록 및 기타 섹션 스타일링** (15분)
5. **테스트** (5분)

**총 예상 시간**: 40분

---

**작업을 시작할까요?** 🚀

