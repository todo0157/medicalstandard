# UI/UX 개선 계획서 (ver_plus 기반)

**작성일**: 2026-01-23  
**프로젝트**: MEDICALSTANDARD (한방 방문 진료 앱)  
**참조**: APP_reference/ver_plus 폴더의 최신 디자인

---

## 📋 목차

1. [현재 어플 분석](#1-현재-어플-분석)
2. [참조 디자인 분석 (ver_plus)](#2-참조-디자인-분석-ver_plus)
3. [전체적인 개선 방향](#3-전체적인-개선-방향)
4. [화면별 상세 개선 계획](#4-화면별-상세-개선-계획)
5. [디자인 시스템 개선](#5-디자인-시스템-개선)
6. [구현 우선순위 및 로드맵](#6-구현-우선순위-및-로드맵)
7. [예상 작업 기간](#7-예상-작업-기간)

---

## 1. 현재 어플 분석

### 1.1 전체 구조
현재 앱은 Flutter로 구현되어 있으며 다음과 같은 구조를 가집니다:

**메인 탭 구조** (MainAppShellScreen):
- **홈 탭**: 방문 진료 예약 (환자 모드) / 한의사 대시보드 (한의사 모드)
- **생활 탭**: 건강 팁 + 건강 일기 기능 (LifeScreen)
- **채팅 탭**: 채팅 목록 및 실시간 채팅 (ChatListScreen)
- **프로필 탭**: 사용자 정보, 예약 목록, 빠른 액션, 메뉴 (ProfileScreen)

### 1.2 현재 UI의 강점
✅ **기능적 완성도**: 모든 핵심 기능이 구현되어 있음  
✅ **모드 전환**: 환자/한의사 모드 전환 기능  
✅ **실시간 채팅**: WebSocket 기반 실시간 채팅 구현  
✅ **건강 관리**: 건강 팁 + 건강 일기 시스템  
✅ **예약 관리**: 완전한 예약 생성/수정/취소 플로우  

### 1.3 개선이 필요한 부분

#### 1.3.1 디자인 일관성
❌ **색상 체계 혼재**:
- 홈 화면: Pink (#EC4899)
- 채팅 화면: Green (#10B981)
- 일부 화면: Blue (#3B82F6)
- 통일된 브랜드 색상 필요

❌ **타이포그래피 일관성 부족**:
- 화면마다 폰트 크기와 굵기가 다름
- 계층 구조가 명확하지 않음

#### 1.3.2 사용자 경험(UX)
❌ **정보 계층 구조**:
- 중요 정보와 부수적 정보의 구분이 불명확
- 시각적 우선순위가 약함

❌ **인터랙션 피드백**:
- 버튼 클릭 시 명확한 피드백 부족
- 로딩 상태 표시가 일관적이지 않음

❌ **빈 상태(Empty State)**:
- 일부 화면에서 빈 상태 디자인이 단조로움
- 행동 유도(CTA)가 약함

#### 1.3.3 화면별 문제점

**홈 화면 (환자 모드)**:
- 환자 선택 UI가 기능적이지만 시각적으로 매력이 부족
- 증상 선택 드롭다운이 UX적으로 개선 필요
- 한의사 선택 후 예약 가능 시간 표시가 복잡함

**생활 탭**:
- 건강 일기 입력 UI가 단조로움
- 건강 팁 카드 디자인이 평면적

**채팅 탭**:
- 채팅 목록 카드가 정보 밀도가 높음
- 한의사 찾기 버튼이 항상 하단에 고정되어 있어 공간 낭비

**프로필 탭**:
- 예약 목록 카드가 정보가 많아 복잡함
- 빠른 액션 그리드가 시각적으로 매력이 부족

---

## 2. 참조 디자인 분석 (ver_plus)

### 2.1 참조 파일 목록

1. **하니비 홈 화면 컨셈만.html**
   - 브랜딩: "하니비(Honeybee)" 로고 + 노란색/주황색 그라디언트
   - 주요 기능: 방문진료 카드, 의료기기 추천, 요양 서비스, 추가 서비스
   - 디자인 특징: 카드 기반 레이아웃, 풍부한 아이콘, 그라디언트 활용

2. **의료용품 추천 및 쇼핑 페이지.html**
   - 상품 그리드 레이아웃 (2열)
   - 카테고리 탭 (의료물품 / 의료기기)
   - 상품 카드: 이미지, 태그, 평점, 가격, 할인율, 버튼
   - 장바구니 기능 및 고정된 하단 버튼

3. **진료 기록 페이지만 있는거.html**
   - 상단 통계 카드 (총 진료 횟수, 이번 달 진료)
   - 월별 그룹핑된 진료 기록 리스트
   - 진료 기록 카드: 날짜, 한의원, 금액, 상태 배지, 증상 및 치료
   - 필터 기능 (날짜순, 한의원별, 진료비순)
   - 상세 모달: 진료 정보, 증상 및 진단, 치료 내용, 진료비 및 예약

4. **고객지원 페이지만 있는거.html**
   - FAQ 아코디언
   - 실시간 지원 (채팅, 전화)
   - 문의 내역 카드 (카테고리 배지, 상태 배지)
   - 지원 정보 (운영시간, 응답시간, 지원 언어)

5. **방문진료 한의사용_웹 페이지.html**
   - 사이드바 네비게이션
   - 방문진료 요청 카드 (타이머, 환자 정보, 거리, 액션 버튼)
   - 대시보드 통계 카드 (예정 진료, 완료 진료, 대기 요청)
   - 일정 관리 캘린더 (달력 + 일정 목록)
   - 프로필 관리 (자격증, 경력, 통계, 알림 설정, 근무 시간)
   - 채팅 인터페이스

### 2.2 ver_plus의 주요 디자인 특징

#### 2.2.1 색상 시스템
- **Primary**: Blue (#3B82F6) - 주요 버튼, 링크
- **Secondary**: Green (#10B981) - 성공, 완료 상태
- **Warning**: Orange (#FFA500) - 대기, 주의
- **Error**: Red (#EF4444) - 오류, 취소
- **Background**: Gray-50 (#F9FAFB) - 배경
- **하니비 브랜딩**: Yellow (#FFD700) + Orange (#FFA500) 그라디언트

#### 2.2.2 타이포그래피
- **Title Large**: 20-24px, Bold (페이지 제목)
- **Title Medium**: 16-18px, SemiBold (섹션 제목)
- **Body Large**: 14-16px, Medium (본문)
- **Body Small**: 12-13px, Regular (보조 텍스트)
- **Caption**: 10-12px, Regular (라벨, 힌트)

#### 2.2.3 간격(Spacing) 시스템
- **XXS**: 4px
- **XS**: 8px
- **SM**: 12px
- **MD**: 16px
- **LG**: 24px
- **XL**: 32px
- **XXL**: 48px

#### 2.2.4 Border Radius
- **Button**: 8px
- **Card**: 12-16px
- **Large Card**: 20-24px
- **Full**: 9999px (원형)

#### 2.2.5 카드 디자인 패턴
1. **정보 카드**: 흰 배경, 그림자, 둥근 모서리, 아이콘 + 텍스트
2. **통계 카드**: 숫자 강조, 색상 배지, 아이콘
3. **리스트 카드**: 좌측 아이콘, 중앙 정보, 우측 액션/배지
4. **액션 카드**: 대형 아이콘, 제목, 설명, 버튼

#### 2.2.6 아이콘 활용
- **Remix Icon** 라이브러리 사용
- 아이콘 + 색상 배경 원형 컨테이너
- 상태별 아이콘 색상 통일

---

## 3. 전체적인 개선 방향

### 3.1 브랜딩 통합
**"하니비(Honeybee)" 브랜드 아이덴티티 도입**:
- 메인 색상: Yellow-Orange 그라디언트
- 서브 색상: Blue (신뢰감), Green (건강/성공)
- 로고: 꿀벌 아이콘 + "하니비" 텍스트
- 컨셉: 따뜻하고 친근한 건강 관리 파트너

### 3.2 디자인 시스템 표준화
- **색상 팔레트** 정의 (Primary, Secondary, Success, Warning, Error, Gray scale)
- **타이포그래피 스케일** 정의 (6단계)
- **간격 시스템** 정의 (8px 기준)
- **컴포넌트 라이브러리** 구축 (버튼, 카드, 입력 필드 등)

### 3.3 UX 패턴 통일
- **빈 상태**: 일러스트레이션 + 설명 + CTA 버튼
- **로딩 상태**: 통일된 Spinner + 로딩 텍스트
- **에러 상태**: 아이콘 + 에러 메시지 + 재시도 버튼
- **성공 상태**: 체크 아이콘 + 확인 메시지

### 3.4 정보 계층 구조 개선
- **H1 (페이지 제목)** → 24px, Bold
- **H2 (섹션 제목)** → 18px, SemiBold
- **H3 (카드 제목)** → 16px, Medium
- **Body** → 14px, Regular
- **Caption** → 12px, Regular

---

## 4. 화면별 상세 개선 계획

### 4.1 홈 화면 (환자 모드)

#### 현재 상태
- 환자 선택 UI (나, 어머니, 자녀 등)
- 주소 입력
- 날짜 선택
- 증상 선택 (드롭다운)
- 한의사 찾기 버튼
- 선택된 한의사 정보 + 예약 가능 시간

#### 개선 계획
**참조**: 하니비 홈 화면 컨셈만.html

##### A. 상단 브랜딩 섹션 추가
```dart
// 새로운 섹션
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFF A500)],
    ),
  ),
  child: Column(
    children: [
      // 하니비 로고
      Row(
        children: [
          Icon(Icons.favorite, color: Colors.white), // 꿀벌 아이콘으로 교체
          Text("하니비", style: PacificoFont), // Pacifico 폰트
        ],
      ),
      // 환영 메시지
      Text("안녕하세요, [사용자명]님"),
      Text("오늘 어떤 도움이 필요하신가요?"),
    ],
  ),
)
```

##### B. 메인 서비스 카드 (방문진료)
```dart
// 큰 카드로 강조
GestureDetector(
  onTap: () => _showAppointmentFlow(),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Badge(label: "방문 진료"),
        Text("방문 진료\n한의사", style: TextStyle(fontSize: 24, bold)),
        Text("한의사 방문진료 예약하기"),
        ElevatedButton(child: Text("예약하기")),
        Image.network("doctor_illustration.png"), // 일러스트
      ],
    ),
  ),
)
```

##### C. 추가 서비스 그리드
```dart
// 2x2 그리드
GridView.count(
  crossAxisCount: 2,
  children: [
    ServiceCard(
      icon: Icons.medical_services,
      title: "의료기기 추천",
      badge: "추천 제품",
      color: Colors.yellow,
      onTap: () => context.push('/medical-devices'),
    ),
    ServiceCard(
      icon: Icons.elderly,
      title: "요양보호사\n부르기",
      badge: "요양 서비스",
      color: Colors.orange,
    ),
    ServiceCard(
      icon: Icons.wheelchair,
      title: "의료기기 대여",
      onTap: () {},
    ),
    ServiceCard(
      icon: Icons.file_present,
      title: "장기요양등급\n신청하기",
      onTap: () {},
    ),
  ],
)
```

##### D. 환자 선택 → 모달로 이동
- 현재: 홈 화면 상단에 항상 표시
- 개선: "누구를 위한 진료인가요?" 버튼 → 모달에서 선택

##### E. 예약 플로우 간소화
```
1. "예약하기" 버튼 클릭
2. 환자 선택 모달
3. 주소 입력 (주소 검색)
4. 증상 선택 (그리드 방식, 아이콘 포함)
5. 한의사 찾기 (지도 또는 목록)
6. 예약 가능 시간 선택
7. 예약 확인 및 제출
```

---

### 4.2 생활 탭 (LifeScreen)

#### 현재 상태
- 오늘의 한방 팁 (큰 카드)
- 나의 건강 일기 (입력 + 조회)
- 건강 정보 피드 (리스트)

#### 개선 계획
**참조**: 의료용품 추천 및 쇼핑 페이지.html (카드 디자인), 진료 기록 페이지 (통계 카드)

##### A. 상단 통계 대시보드 추가
```dart
// 건강 상태 요약
Row(
  children: [
    Expanded(
      child: StatCard(
        icon: Icons.favorite,
        value: "7일",
        label: "연속 기록",
        color: Colors.pink,
      ),
    ),
    Expanded(
      child: StatCard(
        icon: Icons.trending_up,
        value: "😊",
        label: "평균 기분",
        color: Colors.green,
      ),
    ),
  ],
)
```

##### B. 건강 팁 카드 개선
```dart
// 현재: 단순 이미지 + 텍스트
// 개선: 그라디언트 오버레이, 카테고리 배지, 애니메이션

GestureDetector(
  onTap: () => context.push('/health-tip/${tip.id}'),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: kPrimaryBlue.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Stack(
      children: [
        // 배경 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            tip.imageUrl,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        // 그라디언트 오버레이
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        // 콘텐츠
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tip.category.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                tip.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "자세히 보기",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
)
```

##### C. 건강 일기 입력 UI 개선
```dart
// 현재: 단순 모달 + 텍스트 필드
// 개선: 이모지 선택 애니메이션, 메모 입력 강화

// 이모지 선택 (3개 큰 버튼)
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    _MoodButton(emoji: '😊', label: 'GOOD', selected: selectedMood == 'GOOD'),
    _MoodButton(emoji: '😐', label: 'SOSO', selected: selectedMood == 'SOSO'),
    _MoodButton(emoji: '😢', label: 'BAD', selected: selectedMood == 'BAD'),
  ],
)

// 메모 입력 (확장된 텍스트 필드)
TextField(
  controller: noteController,
  decoration: InputDecoration(
    hintText: "오늘 몸 상태는 어떤가요?\n특별한 증상이나 기분을 기록해보세요.",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.grey[100],
  ),
  maxLines: 5,
)
```

##### D. 건강 정보 피드 개선
```dart
// 현재: 단순 리스트
// 개선: 카드 기반, 이미지 썸네일, 읽기 시간 표시

ListView.separated(
  itemBuilder: (context, index) {
    final tip = tips[index];
    return InkWell(
      onTap: () => context.push('/health-tip/${tip.id}'),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                tip.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tip.category,
                      style: TextStyle(
                        color: kPrimaryBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    tip.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kDarkGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: kGrayText),
                      SizedBox(width: 4),
                      Text(
                        DateFormat('MM월 dd일').format(tip.createdAt),
                        style: TextStyle(
                          color: kGrayText,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.menu_book, size: 14, color: kGrayText),
                      SizedBox(width: 4),
                      Text(
                        "3분 읽기", // 예상 읽기 시간
                        style: TextStyle(
                          color: kGrayText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },
  separatorBuilder: (_, __) => SizedBox(height: 12),
)
```

---

### 4.3 채팅 탭 (ChatListScreen)

#### 현재 상태
- 채팅 세션 리스트 (의료진 정보, 마지막 메시지 시간, 읽지 않은 메시지 수)
- 한의사 찾기 버튼 (하단 고정)
- 빈 상태: 아이콘 + 텍스트 + 버튼

#### 개선 계획
**참조**: 진료 기록 페이지 (카드 디자인), 고객지원 페이지 (실시간 지원)

##### A. 채팅 목록 카드 개선
```dart
// 현재: 원형 아이콘 + 정보 + 화살표
// 개선: 프로필 이미지 (있을 경우), 상태 배지, 읽지 않은 메시지 강조

Container(
  margin: EdgeInsets.only(bottom: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: session.unreadCount > 0
        ? Border.all(color: kPrimaryGreen, width: 2)
        : null,
    boxShadow: [
      BoxShadow(
        color: session.unreadCount > 0
            ? kPrimaryGreen.withOpacity(0.1)
            : Colors.black.withOpacity(0.04),
        blurRadius: session.unreadCount > 0 ? 12 : 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // 프로필 이미지 또는 아이콘
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: iconBackgroundColor,
                  backgroundImage: doctor.imageUrl != null
                      ? NetworkImage(doctor.imageUrl!)
                      : null,
                  child: doctor.imageUrl == null
                      ? Icon(iconData, color: iconColor, size: 28)
                      : null,
                ),
                // 온라인 상태 표시 (선택 사항)
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: kChatListDarkGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        timeFormat.format(displayTime),
                        style: TextStyle(
                          color: session.unreadCount > 0
                              ? kPrimaryGreen
                              : kChatListGray,
                          fontSize: 12,
                          fontWeight: session.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle ?? '',
                          style: TextStyle(
                            color: kChatListGray,
                            fontSize: 13,
                            fontWeight: session.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 읽지 않은 메시지 배지
                      if (session.unreadCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kPrimaryGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            session.unreadCount > 99
                                ? '99+'
                                : session.unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)
```

##### B. 빈 상태 개선
```dart
// 현재: 아이콘 + 텍스트 + 버튼
// 개선: 일러스트레이션 + 설명 + CTA

Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // 일러스트레이션 (Lottie 또는 PNG)
      Image.asset(
        'assets/illustrations/empty_chat.png',
        width: 200,
        height: 200,
      ),
      SizedBox(height: 24),
      Text(
        uiMode == UIMode.practitioner
            ? '진행 중인 상담이 없습니다'
            : '채팅 내역이 없습니다',
        style: TextStyle(
          color: kChatListDarkGray,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          uiMode == UIMode.practitioner
              ? '환자와의 상담을 시작하면\n여기에 채팅 목록이 표시됩니다'
              : '한의사를 찾아 상담을 시작해보세요\n24시간 언제든지 문의할 수 있습니다',
          style: TextStyle(
            color: kChatListGray,
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: 32),
      ElevatedButton.icon(
        onPressed: () => _startConsultation(context, ref),
        icon: Icon(Icons.search_rounded),
        label: Text('한의사 찾기'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kChatListPrimaryGreen,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    ],
  ),
)
```

##### C. 플로팅 액션 버튼으로 변경
```dart
// 현재: 하단 고정 버튼
// 개선: FloatingActionButton (채팅 목록이 있을 때만)

if (sessions.isNotEmpty)
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => _startConsultation(context, ref),
    icon: Icon(Icons.add),
    label: Text('새 상담'),
    backgroundColor: kChatListPrimaryGreen,
    elevation: 4,
  )
```

---

### 4.4 프로필 탭 (ProfileScreen)

#### 현재 상태
- 프로필 카드 (아바타, 이름, 나이, 성별, 주소)
- 한의사 인증 상태 카드
- 통계 (예약, 진료)
- 예약 목록
- 빠른 액션 (진료 기록, 건강보험)
- 메뉴 (고객지원, 설정, 법적 고지, 로그아웃)

#### 개선 계획
**참조**: 방문진료 한의사용_웹 페이지.html (프로필 관리), 진료 기록 페이지 (통계 카드)

##### A. 프로필 헤더 개선
```dart
// 현재: 단순 카드
// 개선: 그라디언트 배경 + 프로필 이미지 강조

Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [kPrimaryBlue, kPrimaryBlue.withOpacity(0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: kPrimaryBlue.withOpacity(0.3),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
  child: Row(
    children: [
      // 프로필 이미지
      Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          backgroundImage: profile.profileImageUrl != null
              ? NetworkImage(profile.profileImageUrl!)
              : null,
          child: profile.profileImageUrl == null
              ? Icon(Icons.person, size: 40, color: kPrimaryBlue)
              : null,
        ),
      ),
      SizedBox(width: 16),
      // 정보
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${profile.age}세 · ${_genderLabel}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.white70),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    profile.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // 수정 버튼
      IconButton(
        onPressed: onEdit,
        icon: Icon(Icons.edit, color: Colors.white),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
      ),
    ],
  ),
)
```

##### B. 통계 카드 개선
```dart
// 현재: 2열 (예약, 진료)
// 개선: 3열 (예약, 진료, 만족도) + 아이콘 + 그래프

Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 15,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: Row(
    children: [
      Expanded(
        child: _StatTile(
          icon: Icons.calendar_today,
          value: profile.appointmentCount.toString(),
          label: '예약',
          valueColor: kPrimaryBlue,
          trend: '+2', // 이번 달 증가량 (선택 사항)
        ),
      ),
      VerticalDivider(width: 1, color: AppColors.border),
      Expanded(
        child: _StatTile(
          icon: Icons.medical_services,
          value: profile.treatmentCount.toString(),
          label: '진료',
          valueColor: AppColors.success,
          trend: '+1',
        ),
      ),
      VerticalDivider(width: 1, color: AppColors.border),
      Expanded(
        child: _StatTile(
          icon: Icons.star,
          value: '4.8', // 평균 만족도 (서버에서 추가 필요)
          label: '만족도',
          valueColor: Colors.amber,
        ),
      ),
    ],
  ),
)

Widget _StatTile({
  required IconData icon,
  required String value,
  required String label,
  required Color valueColor,
  String? trend,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: valueColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: valueColor, size: 20),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            if (trend != null) ...[
              SizedBox(width: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
```

##### C. 예약 목록 개선
```dart
// 현재: 간단한 카드
// 개선: 상태 배지, 타임라인 표시, 액션 버튼 그룹화

Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _getStatusBorderColor(appointment.status)),
    boxShadow: [
      BoxShadow(
        color: _getStatusColor(appointment.status).withOpacity(0.1),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // 타임라인 아이콘
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(appointment.status),
              color: _getStatusColor(appointment.status),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.doctor.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  appointment.doctor.specialty,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // 상태 배지
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                color: _getStatusColor(appointment.status),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 12),
      Divider(height: 1, color: AppColors.divider),
      SizedBox(height: 12),
      // 날짜 및 시간
      Row(
        children: [
          Icon(Icons.schedule, size: 18, color: AppColors.iconSecondary),
          SizedBox(width: 6),
          Text(
            formatter.format(appointmentTime),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      SizedBox(height: 8),
      // 장소
      Row(
        children: [
          Icon(Icons.location_on, size: 18, color: AppColors.iconSecondary),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              appointment.doctor.clinicName,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      // 액션 버튼
      if (canCancel || canDelete || onEdit != null) ...[
        SizedBox(height: 12),
        Divider(height: 1, color: AppColors.divider),
        SizedBox(height: 12),
        Row(
          children: [
            if (onEdit != null && canCancel)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_calendar, size: 18),
                  label: Text('변경', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            if (canCancel && onEdit != null)
              SizedBox(width: 8),
            if (canCancel)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: Icon(Icons.cancel, size: 18),
                  label: Text('취소', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            if (canDelete)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, size: 18),
                  label: Text('삭제', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
          ],
        ),
      ],
    ],
  ),
)

Color _getStatusColor(String status) {
  switch (status) {
    case 'confirmed':
      return AppColors.primary;
    case 'cancelled':
      return AppColors.error;
    case 'completed':
      return AppColors.success;
    default:
      return AppColors.warning;
  }
}

Color _getStatusBorderColor(String status) {
  return _getStatusColor(status).withOpacity(0.3);
}

IconData _getStatusIcon(String status) {
  switch (status) {
    case 'confirmed':
      return Icons.check_circle;
    case 'cancelled':
      return Icons.cancel;
    case 'completed':
      return Icons.check_circle_outline;
    default:
      return Icons.pending;
  }
}
```

##### D. 빠른 액션 개선
```dart
// 현재: 2열 그리드 (진료 기록, 건강보험)
// 개선: 아이콘 크기 확대, 설명 추가, 호버 효과

GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 1.2,
  ),
  itemCount: actions.length,
  itemBuilder: (context, index) {
    final action = actions[index];
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onAction(action.actionKey),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              action.backgroundColor,
              action.backgroundColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: action.iconColor.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: action.iconColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  action.icon,
                  color: action.iconColor,
                  size: 28,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    action.description, // 새로 추가
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
)

// QuickActionData에 description 추가
class _QuickActionData {
  final String title;
  final String description; // 새로 추가
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String actionKey;
}

final actions = [
  _QuickActionData(
    title: '진료 기록',
    description: '지난 진료 내역 확인', // 새로 추가
    icon: Icons.description_outlined,
    iconColor: AppColors.primary,
    backgroundColor: Color(0xFFEFF6FF),
    actionKey: 'records',
  ),
  _QuickActionData(
    title: '건강보험',
    description: '보험 청구 및 관리', // 새로 추가
    icon: Icons.health_and_safety_outlined,
    iconColor: AppColors.success,
    backgroundColor: Color(0xFFE7F7EF),
    actionKey: 'insurance',
  ),
];
```

---

### 4.5 진료 기록 화면 (MedicalRecordsScreen)

#### 현재 상태
- 진료 기록 리스트 (카드)
- 빈 상태: 아이콘 + 텍스트 + 버튼
- 상세 모달: 진료 내용, 처방/가이드

#### 개선 계획
**참조**: 진료 기록 페이지만 있는거.html

##### A. 상단 통계 섹션 추가
```dart
// 새로운 섹션 추가
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 15,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: Row(
    children: [
      Expanded(
        child: _StatCard(
          icon: Icons.medical_services,
          value: '12',
          label: '총 진료 횟수',
          color: AppColors.primary,
        ),
      ),
      SizedBox(width: 16),
      Expanded(
        child: _StatCard(
          icon: Icons.calendar_today,
          value: '3',
          label: '이번 달 진료',
          color: AppColors.success,
        ),
      ),
    ],
  ),
)

Widget _StatCard({
  required IconData icon,
  required String value,
  required String label,
  required Color color,
}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
```

##### B. 월별 그룹핑 추가
```dart
// 현재: 단순 리스트
// 개선: 월별로 그룹핑하여 표시

ListView.builder(
  itemCount: groupedRecords.length,
  itemBuilder: (context, index) {
    final group = groupedRecords[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 월별 헤더
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            group.month, // "2024년 1월"
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // 진료 기록 카드들
        ...group.records.map((record) => _RecordCard(record: record)),
      ],
    );
  },
)

// 그룹핑 로직
Map<String, List<MedicalRecord>> _groupByMonth(List<MedicalRecord> records) {
  final grouped = <String, List<MedicalRecord>>{};
  for (final record in records) {
    final month = DateFormat('yyyy년 MM월', 'ko_KR').format(record.createdAt);
    grouped.putIfAbsent(month, () => []).add(record);
  }
  return grouped;
}
```

##### C. 필터 기능 추가
```dart
// AppBar에 필터 버튼 추가
AppBar(
  actions: [
    IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: _showFilterModal,
    ),
  ],
)

void _showFilterModal() {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '정렬 기준',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          RadioListTile(
            title: Text('날짜순'),
            value: 'date',
            groupValue: _sortBy,
            onChanged: (value) => setState(() => _sortBy = value),
          ),
          RadioListTile(
            title: Text('한의원별'),
            value: 'clinic',
            groupValue: _sortBy,
            onChanged: (value) => setState(() => _sortBy = value),
          ),
          RadioListTile(
            title: Text('진료비순'),
            value: 'cost',
            groupValue: _sortBy,
            onChanged: (value) => setState(() => _sortBy = value),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _applySorting();
              Navigator.pop(ctx);
            },
            child: Text('적용하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    ),
  );
}
```

##### D. 상세 모달 개선
```dart
// 현재: 단순 텍스트
// 개선: 색상 구분, 아이콘, 구조화된 레이아웃

showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (ctx) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          // 제목
          Text(
            record.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          // 메타 정보
          Row(
            children: [
              Icon(Icons.person, size: 16, color: AppColors.iconSecondary),
              SizedBox(width: 4),
              Text(
                '${record.doctor.name} · ${record.doctor.specialty}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.calendar_today, size: 16, color: AppColors.iconSecondary),
              SizedBox(width: 4),
              Text(
                dateLabel,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          // 진료 정보 섹션
          _DetailSection(
            icon: Icons.description,
            title: '진료 정보',
            backgroundColor: Color(0xFFF3F4F6),
            iconColor: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: '진료 일시', value: dateLabel),
                _InfoRow(label: '한의원', value: record.doctor.clinicName),
                _InfoRow(label: '위치', value: record.doctor.address ?? '정보 없음'),
                _InfoRow(label: '담당 한의사', value: record.doctor.name),
                _InfoRow(label: '진료과', value: record.doctor.specialty),
              ],
            ),
          ),
          SizedBox(height: 16),
          // 증상 및 진단 섹션
          if (record.summary != null && record.summary!.isNotEmpty)
            _DetailSection(
              icon: Icons.healing,
              title: '증상 및 진단',
              backgroundColor: Color(0xFFDCFCE7),
              iconColor: AppColors.success,
              child: Text(
                record.summary!,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          SizedBox(height: 16),
          // 치료 내용 섹션
          if (record.prescriptions != null && record.prescriptions!.isNotEmpty)
            _DetailSection(
              icon: Icons.local_hospital,
              title: '치료 내용',
              backgroundColor: Color(0xFFFEF3C7),
              iconColor: Colors.amber,
              child: Text(
                record.prescriptions!,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
        ],
      ),
    ),
  ),
)

Widget _DetailSection({
  required IconData icon,
  required String title,
  required Color backgroundColor,
  required Color iconColor,
  required Widget child,
}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        child,
      ],
    ),
  );
}

Widget _InfoRow({required String label, required String value}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

### 4.6 고객지원 화면 (신규 추가)

#### 개선 계획
**참조**: 고객지원 페이지만 있는거.html

##### A. 화면 구조
```dart
class CustomerSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('고객지원'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FAQSection(),
            SizedBox(height: 24),
            _LiveSupportSection(),
            SizedBox(height: 24),
            _InquiryHistorySection(),
            SizedBox(height: 24),
            _SupportInfoSection(),
          ],
        ),
      ),
    );
  }
}
```

##### B. FAQ 섹션
```dart
Widget _FAQSection() {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '자주 묻는 질문',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('전체보기'),
            ),
          ],
        ),
        SizedBox(height: 12),
        // FAQ 아이템들
        _FAQItem(
          question: '진료 예약은 어떻게 하나요?',
          answer: '홈 화면에서 "예약하기" 버튼을 클릭하신 후...',
        ),
        _FAQItem(
          question: '진료 받을 가족을 어떻게 추가하나요?',
          answer: '홈 화면에서 "+" 버튼을 누르면...',
        ),
        _FAQItem(
          question: '앱 로그인이 안 돼요',
          answer: '비밀번호를 3회 이상 잘못 입력하시면...',
        ),
      ],
    ),
  );
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  
  _FAQItem({required this.question, required this.answer});
  
  @override
  __FAQItemState createState() => __FAQItemState();
}

class __FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.iconSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

##### C. 실시간 지원 섹션
```dart
Widget _LiveSupportSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '실시간 지원',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _SupportButton(
              icon: Icons.chat_bubble,
              title: '실시간 채팅',
              subtitle: '온라인',
              color: AppColors.primary,
              backgroundColor: AppColors.primaryLight,
              onTap: () {},
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _SupportButton(
              icon: Icons.phone,
              title: '전화 연결',
              subtitle: '1588-1234',
              color: AppColors.success,
              backgroundColor: AppColors.successLight,
              onTap: () {},
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _SupportButton({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required Color backgroundColor,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
```

##### D. 문의 내역 섹션
```dart
Widget _InquiryHistorySection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '문의 내역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('전체 내역 보기'),
          ),
        ],
      ),
      SizedBox(height: 12),
      _InquiryCard(
        category: '의료 문의',
        categoryColor: AppColors.primary,
        title: '진료 예약 변경 문의',
        content: '예약된 진료 일정을 변경하고 싶습니다.',
        date: '2024.11.12',
        status: '답변 완료',
        statusColor: AppColors.success,
      ),
      _InquiryCard(
        category: '기술 지원',
        categoryColor: AppColors.warning,
        title: '앱 로그인 오류',
        content: '로그인 시 오류 메시지가 계속 나타납니다.',
        date: '2024.11.10',
        status: '처리 중',
        statusColor: AppColors.warning,
      ),
    ],
  );
}

Widget _InquiryCard({
  required String category,
  required Color categoryColor,
  required String title,
  required String content,
  required String date,
  required String status,
  required Color statusColor,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: categoryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              date,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          content,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
```

##### E. 지원 정보 섹션
```dart
Widget _SupportInfoSection() {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '지원 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        _InfoItem(
          icon: Icons.access_time,
          title: '운영시간',
          content: '평일 09:00 - 18:00\n(점심시간 12:00 - 13:00)',
        ),
        _InfoItem(
          icon: Icons.timer,
          title: '평균 응답시간',
          content: '채팅: 즉시 · 전화: 2분 이내\n문의: 24시간 이내',
        ),
        _InfoItem(
          icon: Icons.language,
          title: '지원 언어',
          content: '한국어, English',
        ),
      ],
    ),
  );
}

Widget _InfoItem({
  required IconData icon,
  required String title,
  required String content,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

---

### 4.7 의료용품 추천/쇼핑 화면 (신규 추가)

#### 개선 계획
**참조**: 의료용품 추천 및 쇼핑 페이지.html

##### A. 화면 구조
```dart
class MedicalSuppliesScreen extends StatefulWidget {
  @override
  _MedicalSuppliesScreenState createState() => _MedicalSuppliesScreenState();
}

class _MedicalSuppliesScreenState extends State<MedicalSuppliesScreen> {
  String _selectedCategory = 'supplies'; // 'supplies' or 'devices'
  List<Product> _cartItems = [];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('추천 의료용품'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _cartItems.length.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showCart,
          ),
        ],
      ),
      body: Column(
        children: [
          _CategoryTabs(),
          Expanded(
            child: _ProductGrid(),
          ),
        ],
      ),
      bottomNavigationBar: _CartSummary(),
    );
  }
}
```

##### B. 카테고리 탭
```dart
Widget _CategoryTabs() {
  return Container(
    padding: EdgeInsets.all(16),
    color: Colors.white,
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CategoryTab(
              title: '이러한 의료물품은 어떤가요?',
              isSelected: _selectedCategory == 'supplies',
              onTap: () => setState(() => _selectedCategory = 'supplies'),
            ),
          ),
          Expanded(
            child: _CategoryTab(
              title: '이런 의료기기는 어떤가요?',
              isSelected: _selectedCategory == 'devices',
              onTap: () => setState(() => _selectedCategory = 'devices'),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _CategoryTab({
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
```

##### C. 상품 그리드
```dart
Widget _ProductGrid() {
  final products = _selectedCategory == 'supplies'
      ? _medicalSupplies
      : _medicalDevices;
  
  return GridView.builder(
    padding: EdgeInsets.all(16),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.7,
    ),
    itemCount: products.length,
    itemBuilder: (context, index) {
      return _ProductCard(
        product: products[index],
        onAddToCart: () => _addToCart(products[index]),
      );
    },
  );
}

Widget _ProductCard({
  required Product product,
  required VoidCallback onAddToCart,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상품 이미지
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            // 태그
            if (product.tag != null)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTagColor(product.tag!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    product.tag!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // 상품 정보
        Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.brand,
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
              SizedBox(height: 4),
              Text(
                product.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              // 평점
              Row(
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    product.rating.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '(${product.reviewCount})',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // 가격
              Row(
                children: [
                  if (product.discountRate != null && product.discountRate! > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${product.discountRate}%',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (product.discountRate != null && product.discountRate! > 0)
                    SizedBox(width: 4),
                  Text(
                    '${NumberFormat('#,###').format(product.price)}원',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // 장바구니 담기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAddToCart,
                  child: Text('장바구니 담기', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Color _getTagColor(String tag) {
  switch (tag) {
    case '추천':
      return AppColors.primary;
    case '필수':
      return AppColors.success;
    case '베스트':
      return Colors.red;
    case '인증':
      return AppColors.primary;
    default:
      return AppColors.textSecondary;
  }
}
```

##### D. 장바구니 요약 (하단 고정)
```dart
Widget _CartSummary() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, -4),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: _showCart,
      child: Text(
        '총 ${_cartItems.length}개 상품 장바구니 보기',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

void _addToCart(Product product) {
  setState(() {
    _cartItems.add(product);
  });
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('장바구니에 추가되었습니다'),
      backgroundColor: AppColors.success,
      duration: Duration(seconds: 1),
    ),
  );
}

void _showCart() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CartSheet(
      cartItems: _cartItems,
      onRemove: (index) {
        setState(() {
          _cartItems.removeAt(index);
        });
      },
    ),
  );
}
```

---

## 5. 디자인 시스템 개선

### 5.1 색상 시스템 (app_colors.dart 수정)

```dart
// lib/shared/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (하니비 브랜딩)
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color primaryOrange = Color(0xFFFFA500);
  static const Color primary = Color(0xFF3B82F6); // Blue (신뢰감)
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryDark = Color(0xFF1E40AF);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Green (건강/성공)
  static const Color secondaryLight = Color(0xFFD1FAE5);
  static const Color secondaryDark = Color(0xFF047857);
  
  // Accent Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFE7F7EF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDCFCE7);
  
  // Grayscale
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  
  // Icon Colors
  static const Color iconPrimary = Color(0xFF374151);
  static const Color iconSecondary = Color(0xFF9CA3AF);
  
  // Surface Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  
  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryYellow, primaryOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [primary, Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient greenGradient = LinearGradient(
    colors: [secondary, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### 5.2 타이포그래피 시스템 (app_typography.dart 신규)

```dart
// lib/shared/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  // Display (매우 큰 제목)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  // Title (제목)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Heading (소제목)
  static const TextStyle headingLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Body (본문)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  // Label (라벨)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  // Caption (설명)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );
  
  // Button
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}
```

### 5.3 간격 시스템 (app_spacing.dart 신규)

```dart
// lib/shared/theme/app_spacing.dart

class AppSpacing {
  // 기본 간격 (8px 기준)
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // 특수 간격
  static const double listItemSpacing = 12.0;
  static const double sectionSpacing = 24.0;
  static const double cardPadding = 16.0;
  static const double screenPadding = 16.0;
}
```

### 5.4 Border Radius 시스템 (app_radius.dart 신규)

```dart
// lib/shared/theme/app_radius.dart

import 'package:flutter/material.dart';

class AppRadius {
  // Border Radius
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;
  
  // Specific Use Cases
  static const double button = 8.0;
  static const double card = 16.0;
  static const double modal = 24.0;
  static const double badge = 12.0;
  
  // BorderRadius Objects
  static BorderRadius buttonRadius = BorderRadius.circular(button);
  static BorderRadius cardRadius = BorderRadius.circular(card);
  static BorderRadius modalRadius = BorderRadius.circular(modal);
  static BorderRadius badgeRadius = BorderRadius.circular(badge);
}
```

### 5.5 Shadow 시스템 (app_shadows.dart 신규)

```dart
// lib/shared/theme/app_shadows.dart

import 'package:flutter/material.dart';

class AppShadows {
  // Card Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Button Shadows
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Modal Shadows
  static List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
  ];
  
  // Floating Action Button Shadows
  static List<BoxShadow> fabShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];
}
```

---

## 6. 구현 우선순위 및 로드맵

### 6.1 우선순위 분류

#### 🔴 높음 (High Priority) - Phase 1 (1-2주)
1. **디자인 시스템 구축**
   - 색상 시스템 통합 (`app_colors.dart`)
   - 타이포그래피 시스템 (`app_typography.dart`)
   - 간격/Radius/Shadow 시스템 구축

2. **홈 화면 (환자 모드) 개선**
   - 브랜딩 섹션 추가 (하니비 로고 + 그라디언트)
   - 메인 서비스 카드 개선
   - 예약 플로우 간소화

3. **채팅 탭 개선**
   - 채팅 목록 카드 UI 개선
   - 읽지 않은 메시지 강조
   - 빈 상태 개선

4. **프로필 탭 개선**
   - 프로필 헤더 그라디언트 배경
   - 통계 카드 개선 (3열 + 아이콘)
   - 예약 목록 카드 개선

#### 🟡 중간 (Medium Priority) - Phase 2 (2-3주)
5. **생활 탭 개선**
   - 상단 통계 대시보드
   - 건강 팁 카드 그라디언트 오버레이
   - 건강 일기 입력 UI 개선
   - 건강 정보 피드 카드 개선

6. **진료 기록 화면 개선**
   - 상단 통계 섹션
   - 월별 그룹핑
   - 필터 기능
   - 상세 모달 개선

7. **한의사 찾기 화면 개선**
   - 카드 디자인 개선
   - 지도/목록 토글
   - 필터 및 정렬 기능

#### 🟢 낮음 (Low Priority) - Phase 3 (3-4주)
8. **고객지원 화면 추가**
   - FAQ 섹션
   - 실시간 지원 섹션
   - 문의 내역 섹션
   - 지원 정보 섹션

9. **의료용품 추천/쇼핑 화면 추가**
   - 카테고리 탭
   - 상품 그리드
   - 장바구니 기능
   - 주문/결제 플로우 (선택 사항)

10. **한의사 모드 대시보드 개선**
    - 방문진료 요청 카드 (타이머)
    - 일정 관리 캘린더
    - 환자 관리 기능

---

### 6.2 Phase별 상세 일정

#### Phase 1: 기본 디자인 시스템 및 핵심 화면 개선 (1-2주)

**Week 1: 디자인 시스템 구축**
- [ ] Day 1-2: 색상 시스템 통합
  - `app_colors.dart` 수정
  - 하니비 브랜딩 색상 추가 (Yellow-Orange 그라디언트)
  - 모든 화면에 새 색상 적용

- [ ] Day 3: 타이포그래피 시스템
  - `app_typography.dart` 생성
  - 6단계 타이포그래피 정의 (Display, Title, Heading, Body, Label, Caption)

- [ ] Day 4: 간격/Radius/Shadow 시스템
  - `app_spacing.dart` 생성
  - `app_radius.dart` 생성
  - `app_shadows.dart` 생성

- [ ] Day 5: 공통 컴포넌트 라이브러리
  - `common_button.dart` (Primary, Secondary, Outlined, Text 버튼)
  - `common_card.dart` (기본 카드, 통계 카드, 리스트 카드)
  - `common_badge.dart` (상태 배지, 카테고리 배지)

**Week 2: 핵심 화면 개선**
- [ ] Day 6-7: 홈 화면 (환자 모드) 개선
  - 브랜딩 섹션 추가
  - 메인 서비스 카드 (방문진료)
  - 추가 서비스 그리드 (의료기기 추천, 요양 서비스 등)

- [ ] Day 8: 채팅 탭 개선
  - 채팅 목록 카드 UI 개선
  - 빈 상태 개선

- [ ] Day 9-10: 프로필 탭 개선
  - 프로필 헤더 그라디언트
  - 통계 카드 개선
  - 예약 목록 카드 개선

---

#### Phase 2: 생활 탭 및 진료 기록 개선 (2-3주)

**Week 3-4: 생활 탭 및 진료 기록**
- [ ] Day 11-12: 생활 탭 개선
  - 상단 통계 대시보드
  - 건강 팁 카드 그라디언트 오버레이
  - 건강 일기 입력 UI 개선
  - 건강 정보 피드 카드 개선

- [ ] Day 13-14: 진료 기록 화면 개선
  - 상단 통계 섹션
  - 월별 그룹핑
  - 필터 기능
  - 상세 모달 개선

- [ ] Day 15: 한의사 찾기 화면 개선
  - 카드 디자인 개선
  - 지도/목록 토글
  - 필터 및 정렬 기능

---

#### Phase 3: 추가 화면 및 기능 (3-4주)

**Week 5-6: 고객지원 및 쇼핑 기능**
- [ ] Day 16-17: 고객지원 화면 추가
  - FAQ 섹션 (아코디언)
  - 실시간 지원 섹션 (채팅, 전화)
  - 문의 내역 섹션
  - 지원 정보 섹션

- [ ] Day 18-20: 의료용품 추천/쇼핑 화면 추가
  - 카테고리 탭
  - 상품 그리드
  - 장바구니 기능
  - 주문/결제 플로우 (선택 사항)

- [ ] Day 21: 한의사 모드 대시보드 개선
  - 방문진료 요청 카드 (타이머)
  - 일정 관리 캘린더
  - 환자 관리 기능

---

## 7. 예상 작업 기간

### 7.1 총 작업 기간
- **Phase 1**: 1-2주 (디자인 시스템 + 핵심 화면)
- **Phase 2**: 2-3주 (생활 탭 + 진료 기록)
- **Phase 3**: 3-4주 (추가 화면 + 기능)

**총 예상 기간**: **6-9주** (약 1.5-2개월)

### 7.2 작업 인력
- **UI/UX 디자이너**: 1명 (Phase 1-3 전체 참여)
- **Flutter 개발자**: 1-2명 (전체 기간)
- **백엔드 개발자**: 1명 (Phase 3에서 쇼핑 기능 API 구현 시 필요)

### 7.3 리스크 및 완화 방안

#### 리스크 1: 디자인 시스템 적용 시 기존 코드 충돌
**완화 방안**:
- 점진적 적용: 화면별로 순차적으로 적용하여 충돌 최소화
- 테스트: 각 화면 개선 후 충분한 테스트 수행

#### 리스크 2: ver_plus HTML 디자인을 Flutter로 변환 시 제약
**완화 방안**:
- Flutter의 강점 활용: 애니메이션, 제스처 등 Flutter에서 더 나은 UX 제공
- 디자이너와 협업: 필요 시 Flutter에 맞게 디자인 조정

#### 리스크 3: 추가 기능(쇼핑, 고객지원) 구현 시 백엔드 작업 필요
**완화 방안**:
- 우선순위 조정: Phase 3는 선택 사항으로 두고 Phase 1-2에 집중
- Mock 데이터: 초기에는 Mock 데이터로 UI만 구현하고 백엔드는 추후 연동

---

## 8. 결론

### 8.1 개선의 핵심 방향
1. **브랜딩 통합**: "하니비" 브랜드 아이덴티티 강화 (Yellow-Orange 그라디언트)
2. **디자인 시스템 표준화**: 색상, 타이포그래피, 간격, Radius, Shadow 통일
3. **사용자 경험 개선**: 정보 계층 구조 명확화, 인터랙션 피드백 강화, 빈 상태 개선
4. **시각적 매력 증대**: 그라디언트, 그림자, 애니메이션 활용

### 8.2 기대 효과
- **사용자 만족도 향상**: 더 직관적이고 아름다운 UI
- **브랜드 인지도 상승**: 일관된 브랜딩으로 앱의 정체성 강화
- **유지보수성 향상**: 디자인 시스템 표준화로 코드 일관성 증가
- **개발 속도 증가**: 공통 컴포넌트 라이브러리로 재사용성 향상

### 8.3 다음 단계
1. **디자인 시스템 구축** (Phase 1 시작)
2. **핵심 화면 개선** (홈, 채팅, 프로필)
3. **사용자 피드백 수집** (Phase 1-2 완료 후)
4. **추가 기능 구현** (Phase 3, 선택 사항)

---

**문서 끝**

