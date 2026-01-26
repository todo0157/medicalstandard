# 예약 화면 개선 계획 (Phase 3 - Day 16-17)

**작성일**: 2026-01-26  
**대상 파일**: `lib/features/booking/appointment_booking_screen.dart`  
**참조 디자인**: 디자인 시스템 및 공통 컴포넌트

---

## 📋 목차

1. [현재 코드 분석](#1-현재-코드-분석)
2. [개선 목표](#2-개선-목표)
3. [상세 작업 계획](#3-상세-작업-계획)
4. [단계별 작업 순서](#4-작업-순서)

---

## 1. 현재 코드 분석

### 1.1 구조
- **AppointmentBookingScreen**: 예약 프로세스를 담당하는 메인 화면
- **_BookingHeroCard**: 상단 주소 정보 및 안내 카드
- **_DoctorSelector**: 한의사 선택 리스트
- **_DateSelector**: 날짜 선택 스크롤 뷰
- **_TimeSlotGrid**: 시간대 선택 그리드
- **_SymptomField**: 증상 및 요청사항 입력 필드
- **_SummaryCard**: 예상 비용 및 안내 카드
- **_BottomActionBar**: 하단 예약 버튼

### 1.2 문제점
1. **디자인 시스템 미적용**:
   - `kBookingPrimary` 등 개별 색상 상수 사용
   - `TextStyle` 하드코딩
   - 버튼, 카드, 텍스트 필드 스타일이 공통 컴포넌트와 다름
2. **UX 일관성 부족**:
   - 다른 화면과 디자인 언어가 약간 다름 (그림자, 라운딩 등)

---

## 2. 개선 목표

### 2.1 디자인 시스템 통합
✅ **타이포그래피**: `AppTypography` 전면 적용  
✅ **컴포넌트**: `AppBaseCard`, `AppListCard`, `AppPrimaryButton`, `AppOutlinedButton` 활용  
✅ **스타일**: `AppRadius`, `AppShadows`, `AppSpacing`, `AppColors` 적용

### 2.2 UI 개선
✅ **입력 폼**: 깔끔한 `InputDecoration` 스타일 적용
✅ **선택 UI**: 날짜/시간 선택 칩 스타일 개선
✅ **모달**: 예약 완료 모달 디자인 통일

---

## 3. 상세 작업 계획

### Step 1: Import 및 기본 구조
```dart
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_radius.dart';
import '../../shared/theme/app_shadows.dart';
import '../../shared/widgets/common_card.dart';
import '../../shared/widgets/common_button.dart';
import '../../shared/widgets/common_badge.dart';
```

### Step 2: _BookingHeroCard 및 _SummaryCard 개선
- `AppBaseCard` 적용
- 타이포그래피 및 아이콘 스타일링

### Step 3: _DoctorSelector 개선
- `AppListCard` 사용
- 선택 상태 시각적 피드백 강화

### Step 4: 날짜/시간 선택 UI 개선
- 둥근 칩 형태 디자인 적용
- 선택된 항목 강조 색상 (`AppColors.primary`) 사용

### Step 5: 입력 필드 및 버튼 개선
- `AppTypography` 적용
- `AppPrimaryButton` 사용

---

## 4. 작업 순서

1. **Import 추가 및 상수 제거** (5분)
2. **상단 카드(_BookingHeroCard) 개선** (10분)
3. **한의사/날짜/시간 선택 UI 개선** (20분)
4. **입력 필드 및 하단 버튼 개선** (15분)
5. **예약 완료 모달 개선** (10분)

**총 예상 시간**: 60분

---

**작업을 시작할까요?** 🚀

