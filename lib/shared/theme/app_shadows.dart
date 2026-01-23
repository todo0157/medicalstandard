import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 통합 그림자 시스템
/// 
/// 일관된 그림자 스타일을 제공하여 고도감(Elevation)을 표현합니다.
/// Material Design의 elevation 개념을 따르되, 더 부드럽고 자연스러운 그림자를 사용합니다.
class AppShadows {
  // ========================================
  // 카드 그림자 (Card Shadows)
  // ========================================
  
  /// 카드 기본 그림자 - Elevation 1
  /// 사용: 일반 카드, 리스트 아이템
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  /// 카드 호버 그림자 - Elevation 2
  /// 사용: 카드 호버 시, 선택된 카드
  static List<BoxShadow> cardHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 15,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
  
  /// 카드 강조 그림자 - Elevation 3
  /// 사용: 중요한 카드, 프로필 카드
  static List<BoxShadow> cardElevated = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // ========================================
  // 버튼 그림자 (Button Shadows)
  // ========================================
  
  /// 버튼 기본 그림자
  /// 사용: ElevatedButton
  static List<BoxShadow> button = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  /// 버튼 호버 그림자
  /// 사용: 버튼 호버 시
  static List<BoxShadow> buttonHover = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
  
  /// 버튼 눌림 그림자
  /// 사용: 버튼 클릭 시
  static List<BoxShadow> buttonPressed = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 6,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // ========================================
  // 모달 그림자 (Modal/Dialog Shadows)
  // ========================================
  
  /// 모달 기본 그림자 - Elevation 4
  /// 사용: 바텀시트, 다이얼로그
  static List<BoxShadow> modal = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 30,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    ),
  ];
  
  /// 드롭다운 그림자 - Elevation 3
  /// 사용: 드롭다운 메뉴, 팝업
  static List<BoxShadow> dropdown = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // ========================================
  // 특수 그림자 (Special Shadows)
  // ========================================
  
  /// Floating Action Button 그림자
  /// 사용: FAB
  static List<BoxShadow> fab = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 15,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
  
  /// AppBar 그림자
  /// 사용: AppBar 하단
  static List<BoxShadow> appBar = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// 탭바 그림자
  /// 사용: TabBar, BottomNavigationBar
  static List<BoxShadow> tabBar = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, -2),
      spreadRadius: 0,
    ),
  ];
  
  /// 검색바 그림자
  /// 사용: 검색 입력 필드
  static List<BoxShadow> searchBar = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // ========================================
  // 색상별 그림자 (Colored Shadows)
  // ========================================
  // 특정 색상의 그림자로 강조 효과 제공
  
  /// Primary 색상 그림자 (Blue)
  /// 사용: Primary 버튼, 강조 카드
  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: const Color(0xFF3B82F6).withOpacity(0.2),
      blurRadius: 15,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
  
  /// Success 색상 그림자 (Green)
  /// 사용: Success 버튼, 완료 카드
  static List<BoxShadow> successShadow = [
    BoxShadow(
      color: const Color(0xFF10B981).withOpacity(0.2),
      blurRadius: 15,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
  
  /// Accent 색상 그림자 (Pink)
  /// 사용: Accent 버튼, 한의사 모드 카드
  static List<BoxShadow> accentShadow = [
    BoxShadow(
      color: const Color(0xFFEC4899).withOpacity(0.2),
      blurRadius: 15,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
  
  /// Brand 색상 그림자 (Yellow-Orange)
  /// 사용: 하니비 브랜딩 카드
  static List<BoxShadow> brandShadow = [
    BoxShadow(
      color: const Color(0xFFFFD700).withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  // ========================================
  // Elevation 기반 그림자 (Material Design)
  // ========================================
  // Material Design의 elevation 개념을 따르는 그림자
  
  /// Elevation 0 - 그림자 없음
  static List<BoxShadow> elevation0 = [];
  
  /// Elevation 1 - 매우 약한 그림자
  /// 사용: 카드, 리스트 아이템
  static List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 6,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 2 - 약한 그림자
  /// 사용: 호버 카드, AppBar
  static List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 3 - 중간 그림자
  /// 사용: 드롭다운, 팝업
  static List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 15,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 4 - 강한 그림자
  /// 사용: 모달, 다이얼로그
  static List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
  
  /// Elevation 5 - 매우 강한 그림자
  /// 사용: FAB, 최상위 모달
  static List<BoxShadow> elevation5 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 30,
      offset: const Offset(0, 12),
      spreadRadius: 0,
    ),
  ];

  // ========================================
  // 내부 그림자 (Inner Shadows)
  // ========================================
  // Note: Flutter는 기본적으로 내부 그림자를 지원하지 않습니다.
  // 필요한 경우 Stack과 Blur를 조합하여 구현해야 합니다.
  
  /// 내부 그림자 효과를 위한 오버레이 색상
  /// 사용: Container 내부에 추가 Container를 배치하여 구현
  static Color innerShadowOverlay = Colors.black.withOpacity(0.05);
}

