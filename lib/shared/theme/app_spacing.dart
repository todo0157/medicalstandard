import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 통합 간격 시스템
/// 
/// 8px 기준의 일관된 간격 시스템을 제공합니다.
/// 모든 여백, 패딩은 이 시스템을 따라 8의 배수로 설정하여 시각적 리듬을 만듭니다.
class AppSpacing {
  // ========================================
  // 기본 간격 (8px 기준)
  // ========================================
  
  /// 2배수 - 4px
  /// 사용: 매우 작은 간격, 텍스트 라인 간격
  static const double xxs = 4.0;
  
  /// 1배수 - 8px (기본 단위)
  /// 사용: 작은 간격, 아이콘-텍스트 간격
  static const double xs = 8.0;
  
  /// 1.5배수 - 12px
  /// 사용: 중간 간격, 카드 내부 요소 간격
  static const double sm = 12.0;
  
  /// 2배수 - 16px
  /// 사용: 일반 간격, 카드 패딩 (가장 많이 사용)
  static const double md = 16.0;
  
  /// 3배수 - 24px
  /// 사용: 큰 간격, 섹션 간 간격
  static const double lg = 24.0;
  
  /// 4배수 - 32px
  /// 사용: 매우 큰 간격, 페이지 섹션 간격
  static const double xl = 32.0;
  
  /// 6배수 - 48px
  /// 사용: 초대형 간격, 주요 섹션 구분
  static const double xxl = 48.0;

  // ========================================
  // 특수 용도 간격
  // ========================================
  
  /// 리스트 아이템 간격 - 12px
  /// 사용: ListView의 아이템 사이 간격
  static const double listItemSpacing = 12.0;
  
  /// 섹션 간격 - 24px
  /// 사용: 화면 내 큰 섹션 사이 간격
  static const double sectionSpacing = 24.0;
  
  /// 카드 패딩 - 16px
  /// 사용: 카드 내부 패딩 (기본값)
  static const double cardPadding = 16.0;
  
  /// 카드 패딩 (큰 카드) - 20px
  /// 사용: 중요한 카드, 프로필 카드 등
  static const double cardPaddingLarge = 20.0;
  
  /// 화면 패딩 - 16px
  /// 사용: 화면 좌우 여백 (기본값)
  static const double screenPadding = 16.0;
  
  /// 화면 패딩 (큰 화면) - 20px
  /// 사용: 태블릿, 큰 화면 좌우 여백
  static const double screenPaddingLarge = 20.0;
  
  /// 모달 패딩 - 24px
  /// 사용: 바텀시트, 다이얼로그 내부 패딩
  static const double modalPadding = 24.0;
  
  /// 아이콘-텍스트 간격 - 8px
  /// 사용: 아이콘과 텍스트 사이 간격
  static const double iconTextGap = 8.0;
  
  /// 아이콘-텍스트 간격 (큰) - 12px
  /// 사용: 큰 아이콘과 텍스트 사이 간격
  static const double iconTextGapLarge = 12.0;
  
  /// 버튼 패딩 (수평) - 24px
  /// 사용: 버튼 좌우 패딩
  static const double buttonPaddingHorizontal = 24.0;
  
  /// 버튼 패딩 (수직) - 12px
  /// 사용: 버튼 상하 패딩
  static const double buttonPaddingVertical = 12.0;
  
  /// 버튼 패딩 (큰 버튼, 수직) - 16px
  /// 사용: Primary 버튼 등 큰 버튼의 상하 패딩
  static const double buttonPaddingVerticalLarge = 16.0;
  
  /// 입력 필드 패딩 (수평) - 16px
  /// 사용: TextField 좌우 패딩
  static const double inputPaddingHorizontal = 16.0;
  
  /// 입력 필드 패딩 (수직) - 12px
  /// 사용: TextField 상하 패딩
  static const double inputPaddingVertical = 12.0;

  // ========================================
  // EdgeInsets 헬퍼
  // ========================================
  // 자주 사용하는 EdgeInsets를 미리 정의
  
  /// 모든 방향 xxs (4px)
  static const EdgeInsets allXXS = EdgeInsets.all(xxs);
  
  /// 모든 방향 xs (8px)
  static const EdgeInsets allXS = EdgeInsets.all(xs);
  
  /// 모든 방향 sm (12px)
  static const EdgeInsets allSM = EdgeInsets.all(sm);
  
  /// 모든 방향 md (16px) - 가장 많이 사용
  static const EdgeInsets allMD = EdgeInsets.all(md);
  
  /// 모든 방향 lg (24px)
  static const EdgeInsets allLG = EdgeInsets.all(lg);
  
  /// 모든 방향 xl (32px)
  static const EdgeInsets allXL = EdgeInsets.all(xl);
  
  /// 화면 기본 패딩 (좌우 16px, 상하 16px)
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);
  
  /// 화면 기본 패딩 (좌우만 16px)
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: screenPadding,
  );
  
  /// 카드 기본 패딩
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);
  
  /// 모달 기본 패딩
  static const EdgeInsets modalPaddingAll = EdgeInsets.all(modalPadding);
  
  /// 버튼 기본 패딩
  static const EdgeInsets buttonPaddingDefault = EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical,
  );
  
  /// 버튼 큰 패딩
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVerticalLarge,
  );
  
  /// 입력 필드 기본 패딩
  static const EdgeInsets inputPaddingDefault = EdgeInsets.symmetric(
    horizontal: inputPaddingHorizontal,
    vertical: inputPaddingVertical,
  );
}

