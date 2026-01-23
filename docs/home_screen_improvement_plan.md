# 홈 화면 개선 작업 계획 (Phase 1 - Day 6-7)

**작성일**: 2026-01-23  
**대상 파일**: `lib/features/home/screens/main_app_shell_screen.dart`  
**참조 디자인**: APP_reference/ver_plus/하니비 홈 화면 컨셈만.html

---

## 📋 목차

1. [현재 홈 화면 분석](#1-현재-홈-화면-분석)
2. [개선 목표](#2-개선-목표)
3. [상세 작업 계획](#3-상세-작업-계획)
4. [변경되지 않는 부분](#4-변경되지-않는-부분-중요)
5. [작업 순서](#5-작업-순서)
6. [예상 결과](#6-예상-결과)

---

## 1. 현재 홈 화면 분석

### 1.1 현재 구조 (환자 모드)

```
HomeScreen (환자 모드)
├── 배경색: kPrimaryPink.withAlpha(0.05)
├── SingleChildScrollView
│   └── Column (padding: 16px)
│       ├── _buildPatientSelection()         // 환자 선택 (나, 어머니, 자녀 등)
│       ├── SizedBox(height: 24)
│       ├── _buildAddressButton()            // 주소 입력
│       ├── SizedBox(height: 24)
│       ├── Text("언제 진료를 받을까요?")
│       ├── _buildSelectionButton()          // 날짜 선택
│       ├── SizedBox(height: 24)
│       ├── Text("어떤 질환으로 진료받으시나요?")
│       ├── _buildSymptomSelection()         // 증상 선택 (드롭다운)
│       ├── SizedBox(height: 32)
│       ├── ElevatedButton("한의사 찾기")   // 한의사 찾기 버튼
│       └── if (_selectedDoctor != null)
│           └── 선택된 한의사 정보 + 예약 가능 시간
```

### 1.2 현재 UI의 문제점

❌ **브랜딩 부족**:
- 하니비 로고나 브랜드 아이덴티티가 없음
- 첫 화면인데 환영 메시지가 없음

❌ **정보 계층 불명확**:
- 모든 입력 필드가 동일한 우선순위로 보임
- 핵심 액션("한의사 찾기")이 묻힘

❌ **시각적 매력 부족**:
- 평면적인 디자인
- 그라디언트나 강조 요소가 없음

❌ **추가 서비스 노출 부족**:
- 방문 진료만 있고, 다른 서비스(의료기기, 요양 서비스)가 없음

---

## 2. 개선 목표

### 2.1 브랜딩 강화
✅ **하니비 로고 + 환영 메시지** 추가  
✅ **Yellow-Orange 그라디언트** 적용  
✅ 첫 화면에서 브랜드 아이덴티티 확립

### 2.2 정보 계층 명확화
✅ **메인 서비스 카드** (방문진료)를 크게 강조  
✅ 예약 플로우를 간소화하여 보기 쉽게  
✅ 덜 중요한 정보는 축소

### 2.3 시각적 매력 증대
✅ **그라디언트 카드** 활용  
✅ **아이콘과 일러스트** 추가  
✅ **그림자와 여백** 최적화

### 2.4 서비스 확장성
✅ **추가 서비스 그리드** 추가 (의료기기, 요양 서비스)  
✅ 향후 새로운 서비스 추가 용이

---

## 3. 상세 작업 계획

### Step 1: Import 추가

**위치**: 파일 상단 (기존 import 아래)

**추가할 코드**:
```dart
// 새로운 디자인 시스템 import
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/widgets/common_button.dart';
import '../../../shared/widgets/common_card.dart';
import '../../../shared/widgets/common_badge.dart';
```

**영향**: 없음 (import만 추가)

---

### Step 2: 브랜딩 헤더 메서드 추가

**위치**: `_HomeScreenState` 클래스 내부, `build` 메서드 위

**추가할 메서드**:
```dart
Widget _buildBrandingHeader(BuildContext context, WidgetRef ref) {
  final profileState = ref.watch(profileStateNotifierProvider);
  final userName = profileState.maybeWhen(
    data: (profile) => profile.name,
    orElse: () => '사용자',
  );

  return Container(
    padding: EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      gradient: AppColors.brandGradient,
      borderRadius: AppRadius.cardLargeRadius,
      boxShadow: AppShadows.brandShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 하니비 로고
        Row(
          children: [
            Icon(
              Icons.favorite,  // 추후 커스텀 아이콘으로 교체 가능
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              '하니비',
              style: TextStyle(
                fontFamily: 'Pacifico',  // 특수 폰트 (pubspec.yaml에 추가 필요)
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        // 환영 메시지
        Text(
          '안녕하세요, ${userName}님',
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          '오늘 어떤 도움이 필요하신가요?',
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    ),
  );
}
```

**영향**: 
- ✅ 화면 상단에 브랜딩 섹션 추가
- ✅ 기존 기능에 영향 없음
- ⚠️ Pacifico 폰트는 pubspec.yaml에 추가 필요 (선택사항, 없어도 작동)

---

### Step 3: 메인 서비스 카드 메서드 추가

**위치**: `_HomeScreenState` 클래스 내부

**추가할 메서드**:
```dart
Widget _buildMainServiceCard(BuildContext context) {
  return AppGradientCard(
    gradient: AppColors.brandGradient,
    padding: EdgeInsets.all(AppSpacing.lg),
    radius: AppRadius.cardLargeRadius,
    shadow: true,
    onTap: () async {
      // 기존 "한의사 찾기" 버튼과 동일한 로직
      final doctor = await context.push<Doctor>('/find-doctor');
      if (doctor != null && mounted) {
        setState(() {
          _selectedDoctor = doctor;
          if (doctor.clinicLat != null && doctor.clinicLng != null) {
            _selectedAddress = Address(
              roadAddress: doctor.clinicName,
              jibunAddress: doctor.clinicName,
              x: doctor.clinicLng ?? 0,
              y: doctor.clinicLat ?? 0,
              distance: doctor.distanceKm ?? 0,
              addressElements: [],
            );
          }
        });
      }
    },
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 배지
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: AppRadius.badgeSmallRadius,
                ),
                child: Text(
                  '방문 진료',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              // 제목
              Text(
                '방문 진료\n한의사',
                style: AppTypography.displaySmall.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              // 설명
              Text(
                '한의사 방문진료 예약하기',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              // 버튼
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.buttonRadius,
                ),
                child: Text(
                  '예약하기',
                  style: AppTypography.button.copyWith(
                    color: AppColors.brandOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 일러스트 이미지
        SizedBox(
          width: 80,
          height: 80,
          child: Image.network(
            'https://readdy.ai/api/search-image?query=Professional%20doctor%20character%20illustration%2C%20friendly%20male%20doctor%20with%20stethoscope%2C%20medical%20uniform%2C%20smiling%2C%20clean%20medical%20illustration%20style%2C%20isolated%20on%20transparent%20background%2C%20centered%20composition%2C%20the%20character%20should%20take%20up%2080%25%20of%20the%20frame&width=80&height=80&seq=doctor1&orientation=squarish',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.medical_services,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
```

**영향**:
- ✅ 큰 그라디언트 카드로 방문 진료 강조
- ✅ 기존 "한의사 찾기" 버튼과 동일한 기능
- ✅ 시각적으로 훨씬 매력적

---

### Step 4: 추가 서비스 그리드 메서드 추가

**위치**: `_HomeScreenState` 클래스 내부

**추가할 메서드**:
```dart
Widget _buildAdditionalServices(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '추가 서비스',
        style: AppTypography.titleSmall,
      ),
      SizedBox(height: AppSpacing.md),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.1,
        children: [
          _buildServiceCard(
            title: '의료기기\n추천',
            badge: '추천 제품',
            icon: Icons.medical_services,
            color: AppColors.brandYellow,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('의료기기 추천 화면 준비 중입니다.')),
              );
            },
          ),
          _buildServiceCard(
            title: '요양보호사\n부르기',
            badge: '요양 서비스',
            icon: Icons.elderly,
            color: AppColors.brandOrange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('요양보호사 서비스 준비 중입니다.')),
              );
            },
          ),
          _buildServiceCard(
            title: '의료기기\n대여',
            icon: Icons.wheelchair,
            color: AppColors.secondary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('의료기기 대여 서비스 준비 중입니다.')),
              );
            },
          ),
          _buildServiceCard(
            title: '장기요양등급\n신청하기',
            icon: Icons.description,
            color: AppColors.accent,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('장기요양등급 신청 화면 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
    ],
  );
}

Widget _buildServiceCard({
  required String title,
  required IconData icon,
  required Color color,
  String? badge,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: AppRadius.badgeSmallRadius,
              ),
              child: Text(
                badge,
                style: AppTypography.captionSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
          ],
          Text(
            title,
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
```

**영향**:
- ✅ 2x2 그리드로 4개 서비스 표시
- ✅ 향후 실제 서비스 추가 시 onTap만 수정하면 됨
- ✅ 기존 기능에 영향 없음

---

### Step 5: build 메서드 수정

**위치**: `_HomeScreenState`의 `build` 메서드

**현재 코드**:
```dart
@override
Widget build(BuildContext context) {
  // ...
  return Container(
    color: kPrimaryPink.withValues(alpha: 0.05),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPatientSelection(),  // 1번째
          const SizedBox(height: 24),
          // ... 주소, 날짜, 증상 선택 ...
          ElevatedButton("한의사 찾기"),  // 마지막
        ],
      ),
    ),
  );
}
```

**수정 후**:
```dart
@override
Widget build(BuildContext context) {
  final uiMode = ref.watch(uiModeProvider);
  
  if (uiMode == UIMode.practitioner) {
    return const PractitionerHomeScreen();
  }
  
  // 환자 모드 - 개선된 UI
  return Container(
    color: AppColors.background,  // 통일된 배경색
    child: SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.screenPadding),  // 통일된 패딩
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ✨ 새로 추가: 브랜딩 헤더
          _buildBrandingHeader(context, ref),
          SizedBox(height: AppSpacing.sectionSpacing),
          
          // ✨ 새로 추가: 메인 서비스 카드 (방문진료)
          _buildMainServiceCard(context),
          SizedBox(height: AppSpacing.sectionSpacing),
          
          // ✨ 새로 추가: 추가 서비스 그리드
          _buildAdditionalServices(context),
          SizedBox(height: AppSpacing.sectionSpacing),
          
          // 🔄 기존 유지: 환자 선택 (접을 수 있게 개선 - 선택사항)
          _buildPatientSelection(),
          SizedBox(height: AppSpacing.lg),
          
          // 🔄 기존 유지: 주소 입력
          GestureDetector(
            onTap: () async {
              final address = await context.push<Address>('/address/search');
              if (address != null && mounted) {
                setState(() => _selectedAddress = address);
              }
            },
            child: _buildAddressButton(_selectedAddress),
          ),
          SizedBox(height: AppSpacing.lg),
          
          // 🔄 기존 유지: 날짜 선택
          Text(
            "언제 진료를 받을까요?",
            style: AppTypography.titleSmall,  // 통일된 타이포그래피
          ),
          SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: _buildSelectionButton(
              _selectedDate == null
                  ? "날짜를 선택해주세요"
                  : DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate!),
              Icons.calendar_today,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          
          // 🔄 기존 유지: 증상 선택
          Text(
            "어떤 질환으로 진료받으시나요?",
            style: AppTypography.titleSmall,  // 통일된 타이포그래피
          ),
          SizedBox(height: AppSpacing.md),
          _buildSymptomSelection(),
          
          // ❌ 삭제: 기존 "한의사 찾기" 버튼 (메인 서비스 카드로 대체됨)
          
          // 🔄 기존 유지: 선택된 한의사 정보
          if (_selectedDoctor != null) ...[
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  // ... 기존 선택된 한의사 정보 코드 ...
                ],
              ),
            ),
          ],
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    ),
  );
}
```

**변경 사항 요약**:
1. ✨ **새로 추가**: 브랜딩 헤더 (최상단)
2. ✨ **새로 추가**: 메인 서비스 카드 (방문진료)
3. ✨ **새로 추가**: 추가 서비스 그리드 (2x2)
4. 🔄 **순서 변경**: 환자 선택을 아래로 이동
5. ❌ **삭제**: 기존 "한의사 찾기" ElevatedButton
6. 🔄 **스타일 개선**: 모든 간격, 색상을 디자인 시스템으로 교체

---

### Step 6: 기존 메서드 스타일 개선 (선택사항)

**대상 메서드**:
- `_buildSelectionButton()` - 버튼 스타일을 AppRadius, AppSpacing 사용하도록 수정
- `_buildAddressButton()` - 동일
- `_buildPatientSelection()` - 동일

**예시** (`_buildSelectionButton` 개선):
```dart
Widget _buildSelectionButton(String text, IconData icon) {
  bool isPlaceholder = text.contains("선택") || text.contains("입력");

  return Container(
    padding: EdgeInsets.symmetric(
      vertical: AppSpacing.sm,      // 14 → 12px (통일)
      horizontal: AppSpacing.md,     // 16px (동일)
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: AppRadius.inputRadius,  // 8px (통일)
      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: isPlaceholder
              ? AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHint,
                )
              : AppTypography.bodyMedium,
        ),
        Icon(icon, color: AppColors.iconSecondary),
      ],
    ),
  );
}
```

**영향**: 
- ✅ 시각적으로 더 통일됨
- ✅ 기능은 동일
- ⚠️ 세밀한 간격 변경 (14px → 12px 등)

---

## 4. 변경되지 않는 부분 (중요!)

### ✅ 유지되는 기능:
1. **환자 선택** 기능 (나, 어머니, 자녀 등)
2. **주소 검색** 기능
3. **날짜 선택** 기능
4. **증상 선택** 기능
5. **한의사 찾기** 로직 (버튼 위치만 변경, 기능 동일)
6. **선택된 한의사 정보 표시**
7. **예약 가능 시간 표시**

### ✅ 유지되는 상태:
- `_selectedPatientId`
- `_selectedAddress`
- `_selectedDate`
- `_selectedSymptom`
- `_selectedDoctor`
- 모든 기존 로직

### ⚠️ 변경되는 것:
- **UI 배치 순서** (브랜딩 헤더가 최상단으로)
- **메인 액션 버튼** (일반 버튼 → 큰 그라디언트 카드)
- **색상/간격/타이포그래피** (디자인 시스템 적용)

---

## 5. 작업 순서

### 5.1 안전한 작업 순서

```
Step 1: Import 추가
  ↓
Step 2: 새로운 메서드 3개 추가
  - _buildBrandingHeader()
  - _buildMainServiceCard()
  - _buildAdditionalServices() + _buildServiceCard()
  ↓
Step 3: build 메서드 수정
  - Column의 children 순서 변경
  - 디자인 시스템 값으로 교체
  ↓
Step 4: 기존 메서드 스타일 개선 (선택사항)
  - _buildSelectionButton()
  - _buildAddressButton()
  - _buildPatientSelection()
  ↓
Step 5: 테스트 (Flutter 앱 실행)
  ↓
Step 6: 문제 없으면 커밋
```

### 5.2 각 단계별 확인 사항

**Step 1-2 후**: 
- ✅ 린터 오류 없는지 확인
- ✅ import 경로 정확한지 확인

**Step 3 후**:
- ✅ 린터 오류 없는지 확인
- ✅ 빌드 에러 없는지 확인

**Step 5 후**:
- ✅ 앱이 정상 실행되는지 확인
- ✅ 모든 버튼이 작동하는지 확인
- ✅ 한의사 찾기 기능 정상 작동하는지 확인

---

## 6. 예상 결과

### 6.1 Before (현재)

```
┌─────────────────────────────┐
│ [메뉴] 방문 진료    [알림]  │ AppBar
├─────────────────────────────┤
│                             │
│ 누가 진료를 받을까요?        │
│ ┌───┐ ┌───┐                │
│ │ 나 │ │ + │                │
│ └───┘ └───┘                │
│                             │
│ [주소를 입력해주세요]         │
│                             │
│ 언제 진료를 받을까요?        │
│ [날짜를 선택해주세요]         │
│                             │
│ 어떤 질환으로 진료받으시나요? │
│ [증상을 선택해주세요]         │
│                             │
│ ┌───────────────────────┐  │
│ │   한의사 찾기         │  │ Pink 버튼
│ └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

### 6.2 After (개선 후)

```
┌─────────────────────────────┐
│ [메뉴] 방문 진료    [알림]  │ AppBar
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ 🍯 하니비             │ │ 브랜딩 헤더
│ │ 안녕하세요, 홍길동님    │ │ (그라디언트)
│ │ 오늘 어떤 도움이      │ │
│ │ 필요하신가요?         │ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ [방문 진료]           👨‍⚕️│ │ 메인 서비스 카드
│ │ 방문 진료              │ │ (그라디언트)
│ │ 한의사                │ │
│ │ 한의사 방문진료 예약하기 │ │
│ │ [예약하기]             │ │
│ └─────────────────────────┘ │
│                             │
│ 추가 서비스                 │
│ ┌──────┐ ┌──────┐         │
│ │의료기기│ │요양  │         │ 2x2 그리드
│ │추천   │ │보호사│         │
│ └──────┘ └──────┘         │
│ ┌──────┐ ┌──────┐         │
│ │의료기기│ │장기  │         │
│ │대여   │ │요양  │         │
│ └──────┘ └──────┘         │
│                             │
│ 누가 진료를 받을까요?        │
│ ┌───┐ ┌───┐                │
│ │ 나 │ │ + │                │
│ └───┘ └───┘                │
│                             │
│ [주소를 입력해주세요]         │
│ [날짜를 선택해주세요]         │
│ [증상을 선택해주세요]         │
│                             │
│ (선택된 한의사 정보)         │
└─────────────────────────────┘
```

### 6.3 주요 개선 사항

✅ **브랜딩 강화**: 하니비 로고 + 환영 메시지가 가장 먼저 보임  
✅ **핵심 액션 강조**: 큰 그라디언트 카드로 방문진료 예약 강조  
✅ **서비스 확장**: 4개 추가 서비스 그리드  
✅ **디자인 시스템 적용**: 모든 색상, 간격, 타이포그래피 통일  
✅ **기능 유지**: 모든 기존 기능은 그대로 작동

---

## 7. 리스크 관리

### 7.1 잠재적 문제

**문제 1**: Import 경로 오류
- **완화**: 먼저 import만 추가하고 린터 확인

**문제 2**: 기존 기능이 작동하지 않음
- **완화**: Step별로 확인, 문제 발생 시 해당 Step만 롤백

**문제 3**: UI가 예상과 다름
- **완화**: Flutter 앱 실행 후 확인, 필요 시 조정

### 7.2 롤백 방법

**전체 롤백**:
```powershell
git checkout backup/before-ui-ux-improvement-20260123 -- lib/features/home/screens/main_app_shell_screen.dart
```

**Step별 롤백**:
```powershell
git diff  # 변경 사항 확인
git checkout HEAD -- lib/features/home/screens/main_app_shell_screen.dart  # 마지막 커밋으로
```

---

## 8. 예상 소요 시간

- **Step 1**: Import 추가 (1분)
- **Step 2**: 새 메서드 3개 추가 (10분)
- **Step 3**: build 메서드 수정 (10분)
- **Step 4**: 기존 메서드 스타일 개선 (10분, 선택사항)
- **Step 5**: 테스트 (5분)

**총 예상 시간**: 약 30-40분

---

## 9. 체크리스트

작업 진행 시 확인할 사항:

- [ ] Step 1: Import 추가 완료
- [ ] Step 2-1: _buildBrandingHeader() 추가 완료
- [ ] Step 2-2: _buildMainServiceCard() 추가 완료
- [ ] Step 2-3: _buildAdditionalServices() + _buildServiceCard() 추가 완료
- [ ] Lint 검사 통과
- [ ] Step 3: build() 메서드 수정 완료
- [ ] Lint 검사 통과
- [ ] Step 4: 기존 메서드 스타일 개선 (선택사항)
- [ ] Step 5: Flutter 앱 실행 및 테스트
- [ ] 모든 기능 정상 작동 확인
- [ ] Step 6: 커밋

---

## 10. 결론

### 핵심 원칙:
1. **기능은 유지**, UI만 개선
2. **단계별 확인**, 문제 발생 시 즉시 롤백
3. **디자인 시스템 활용**, 일관된 스타일

### 기대 효과:
- 🎨 **브랜딩 강화**: 하니비 아이덴티티 확립
- 📱 **사용성 향상**: 핵심 기능이 더 명확하게 보임
- 🚀 **확장성**: 새로운 서비스 추가 용이

---

**이 계획이 명확한가요? 작업을 시작할까요?** 🚀

