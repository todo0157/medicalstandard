# 진료 기록 화면 개선 계획 (Phase 2 - Day 13-14)

**작성일**: 2026-01-23  
**대상 파일**: `lib/features/medical_records/medical_records_screen.dart`  
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
- **MedicalRecordsScreen**: `Scaffold` 구조, `ListView.builder` 사용
- **_RecordCard**: 커스텀 카드 위젯 (그림자, 테두리 직접 구현)
- **_EmptyView / _ErrorView**: 커스텀 상태 위젯
- **_showRecordSheet**: `showModalBottomSheet`로 상세 내용 표시

### 1.2 문제점
1. **디자인 시스템 미준수**:
   - `Theme.of(context).textTheme` 직접 사용 (AppTypography 미사용)
   - `AppColors` 일부 사용 중이나 체계적이지 않음
   - 그림자, 테두리 등 스타일을 직접 정의하고 있음 (`AppShadows`, `AppRadius` 미사용)
2. **UX 개선 필요**:
   - 단순 리스트 나열로 정보 파악이 어려울 수 있음 (월별 그룹핑 없음)
   - 요약 정보(총 진료 횟수 등) 부재

---

## 2. 개선 목표

### 2.1 디자인 시스템 통합
✅ **타이포그래피**: `AppTypography` 전면 적용  
✅ **컴포넌트**: `AppBaseCard`, `AppStatusBadge`, `AppPrimaryButton` 등 활용  
✅ **스타일**: `AppRadius`, `AppShadows`, `AppSpacing` 적용

### 2.2 UI/UX 개선
✅ **상단 요약 카드**:
   - 총 진료 횟수, 최근 방문 병원 등 요약 정보 표시
✅ **리스트 디자인**:
   - `AppBaseCard` 기반의 깔끔한 리스트 아이템
   - 날짜 표시 개선 (상대적 시간 또는 깔끔한 포맷)
✅ **상세 모달**:
   - 디자인 시스템이 적용된 바텀 시트
   - 정보 계층 구조 명확화

---

## 3. 상세 작업 계획

### Step 1: Import 및 기본 구조 설정
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

### Step 2: _buildSummarySection 추가
- 상단에 진료 기록 요약 정보를 보여주는 섹션 추가
- `AppGradientCard` 또는 `AppInfoCard` 활용 고려

### Step 3: _RecordCard 리팩토링 -> _MedicalRecordListItem
- `AppBaseCard` 사용
- 닥터 정보, 날짜, 진료 과목 등을 구조적으로 배치
- `AppStatusBadge`로 상태(예: 처방전 있음 등) 표시 가능성 검토

### Step 4: 빈 화면 및 에러 화면 개선
- `_EmptyView`: `AppPrimaryButton` 사용, 일러스트(아이콘) 크기 및 스타일 조정
- `_ErrorView`: `AppOutlinedButton` 사용

### Step 5: 상세 모달 (_showRecordSheet) 개선
- `AppTypography` 적용
- 섹션 구분 명확화 (진료 내용, 처방/가이드)

---

## 4. 작업 순서

1. **Import 추가 및 Scaffold 구조 정리** (5분)
2. **상단 요약 섹션 구현** (15분)
3. **리스트 아이템 (_RecordCard) 리팩토링** (15분)
4. **빈 화면/에러 화면 및 모달 스타일링** (10분)
5. **테스트 및 검증** (5분)

**총 예상 시간**: 50분

---

**작업을 승인해 주시면 바로 시작하도록 하겠습니다!** 🚀

