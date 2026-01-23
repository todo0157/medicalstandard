import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 통합 Border Radius 시스템
/// 
/// 일관된 모서리 둥글기를 제공하여 통일된 디자인을 만듭니다.
/// 각 컴포넌트 타입별로 최적화된 radius 값을 제공합니다.
class AppRadius {
  // ========================================
  // 기본 Radius 값
  // ========================================
  
  /// 둥글지 않음 - 0px
  /// 사용: 직각 모서리가 필요한 경우
  static const double none = 0.0;
  
  /// 매우 작게 - 4px
  /// 사용: 배지, 태그
  static const double xs = 4.0;
  
  /// 작게 - 8px
  /// 사용: 작은 버튼, 입력 필드
  static const double sm = 8.0;
  
  /// 중간 - 12px
  /// 사용: 일반 버튼, 작은 카드
  static const double md = 12.0;
  
  /// 크게 - 16px (가장 많이 사용)
  /// 사용: 카드, 컨테이너
  static const double lg = 16.0;
  
  /// 매우 크게 - 20px
  /// 사용: 큰 카드, 모달
  static const double xl = 20.0;
  
  /// 초대형 - 24px
  /// 사용: 바텀시트, 다이얼로그
  static const double xxl = 24.0;
  
  /// 완전 원형 - 9999px
  /// 사용: 원형 버튼, 원형 아바타
  static const double full = 9999.0;

  // ========================================
  // 컴포넌트별 Radius (용도별 최적화)
  // ========================================
  
  /// 버튼 - 8px
  /// 사용: 모든 버튼의 기본 radius
  static const double button = 8.0;
  
  /// 큰 버튼 - 12px
  /// 사용: Primary 버튼 등 큰 버튼
  static const double buttonLarge = 12.0;
  
  /// 카드 - 16px
  /// 사용: 일반 카드 컴포넌트
  static const double card = 16.0;
  
  /// 큰 카드 - 20px
  /// 사용: 프로필 카드, 중요 카드
  static const double cardLarge = 20.0;
  
  /// 모달 - 24px
  /// 사용: 바텀시트, 다이얼로그 (상단 모서리)
  static const double modal = 24.0;
  
  /// 배지 - 12px
  /// 사용: 상태 배지, 알림 배지
  static const double badge = 12.0;
  
  /// 작은 배지 - 8px
  /// 사용: 작은 태그, 라벨
  static const double badgeSmall = 8.0;
  
  /// 입력 필드 - 8px
  /// 사용: TextField, TextFormField
  static const double input = 8.0;
  
  /// 큰 입력 필드 - 12px
  /// 사용: 검색창, 큰 입력 필드
  static const double inputLarge = 12.0;
  
  /// 이미지 썸네일 - 8px
  /// 사용: 작은 이미지, 아바타 배경
  static const double thumbnail = 8.0;
  
  /// 큰 이미지 - 12px
  /// 사용: 상품 이미지, 건강 팁 이미지
  static const double image = 12.0;

  // ========================================
  // BorderRadius 객체 (자주 사용하는 것들)
  // ========================================
  // EdgeInsets처럼 미리 정의된 BorderRadius 객체
  
  /// 버튼 기본 radius
  static BorderRadius buttonRadius = BorderRadius.circular(button);
  
  /// 큰 버튼 radius
  static BorderRadius buttonLargeRadius = BorderRadius.circular(buttonLarge);
  
  /// 카드 기본 radius
  static BorderRadius cardRadius = BorderRadius.circular(card);
  
  /// 큰 카드 radius
  static BorderRadius cardLargeRadius = BorderRadius.circular(cardLarge);
  
  /// 모달 상단 radius (바텀시트용)
  static BorderRadius modalTopRadius = const BorderRadius.only(
    topLeft: Radius.circular(modal),
    topRight: Radius.circular(modal),
  );
  
  /// 배지 radius
  static BorderRadius badgeRadius = BorderRadius.circular(badge);
  
  /// 작은 배지 radius
  static BorderRadius badgeSmallRadius = BorderRadius.circular(badgeSmall);
  
  /// 입력 필드 radius
  static BorderRadius inputRadius = BorderRadius.circular(input);
  
  /// 큰 입력 필드 radius
  static BorderRadius inputLargeRadius = BorderRadius.circular(inputLarge);
  
  /// 이미지 썸네일 radius
  static BorderRadius thumbnailRadius = BorderRadius.circular(thumbnail);
  
  /// 큰 이미지 radius
  static BorderRadius imageRadius = BorderRadius.circular(image);
  
  /// 완전 원형
  static BorderRadius circular = BorderRadius.circular(full);
}

