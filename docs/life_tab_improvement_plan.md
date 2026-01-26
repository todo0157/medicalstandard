# 생활 탭 개선 계획 (Phase 2 - Day 11-12)

**작성일**: 2026-01-23  
**대상 파일**: `lib/features/life/screens/life_screen.dart`  
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
- **LifeScreen**: 메인 스크린
- **_buildTodayTip**: 오늘의 팁 카드 (단순 컨테이너)
- **_buildHealthLogSection**: 건강 일기 (단순 박스)
- **_buildHealthTipsFeed**: 팁 리스트 (단순 리스트)
- **_showAddLogModal**: 기록 추가 모달

### 1.2 문제점
1. **디자인 시스템 미적용**:
   - 하드코딩된 색상 (`kPrimaryPink` 등) 사용
   - `AppTypography` 미사용
2. **시각적 매력 부족**:
   - 팁 카드가 평면적임
   - 건강 일기 섹션이 단순함
3. **사용자 경험**:
   - 기록 추가 버튼이 작음
   - 통계 정보가 없음

---

## 2. 개선 목표

### 2.1 디자인 시스템 통합
✅ **색상**: `AppColors` 사용  
✅ **타이포그래피**: `AppTypography` 사용  
✅ **컴포넌트**: `AppGradientCard`, `AppBaseCard`, `AppStatCard` 활용

### 2.2 UI 개선
✅ **상단 통계**:
   - 연속 기록일, 기분 상태 등을 보여주는 대시보드 추가
✅ **오늘의 팁**:
   - `AppGradientCard` 사용하여 강조
   - 이미지 오버레이 효과 개선
✅ **건강 일기**:
   - 이모지 선택 UI 개선
   - 최근 기록 시각화
✅ **피드**:
   - `AppListCard` 스타일 적용

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

### Step 2: 상단 통계 대시보드 추가
- `_buildStatsDashboard()` 메서드 추가
- 2열 그리드로 통계 표시 (연속 기록, 이번 달 기록 등)

### Step 3: _buildTodayTip 개선
- `AppGradientCard` 사용
- 배경 이미지와 그라디언트 오버레이 적용

### Step 4: _buildHealthLogSection 개선
- `AppBaseCard` 사용
- 오늘 기록이 없으면 큰 버튼 표시
- 기록이 있으면 요약 카드 표시

### Step 5: _buildHealthTipsFeed 개선
- 리스트 아이템을 `AppListCard` 스타일로 변경

---

## 4. 작업 순서

1. **Import 추가 및 상수 정리** (5분)
2. **통계 대시보드 구현** (10분)
3. **오늘의 팁 카드 개선** (10분)
4. **건강 일기 섹션 개선** (10분)
5. **피드 리스트 개선** (5분)
6. **테스트** (5분)

**총 예상 시간**: 45분

---

**작업을 시작할까요?** 🚀

