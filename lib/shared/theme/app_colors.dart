import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 통합 색상 시스템
/// 
/// 브랜딩: "하니비(Honeybee)" - 따뜻하고 친근한 건강 관리 파트너
/// 주요 색상: Yellow-Orange 그라디언트 (브랜딩), Blue (신뢰감), Green (건강/성공)
class AppColors {
  // ========================================
  // 브랜딩 색상 (Honeybee Branding)
  // ========================================
  
  /// 하니비 메인 색상 - Yellow (따뜻함, 친근함)
  static const Color brandYellow = Color(0xFFFFD700); // Gold
  
  /// 하니비 메인 색상 - Orange (활력, 건강)
  static const Color brandOrange = Color(0xFFFFA500); // Orange
  
  /// 하니비 브랜딩 그라디언트 (메인 카드, 히어로 섹션에 사용)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandYellow, brandOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ========================================
  // Primary Colors (신뢰감 - Blue)
  // ========================================
  
  /// 주요 버튼, 링크, 강조 요소에 사용
  static const Color primary = Color(0xFF3B82F6); // Blue-600
  static const Color primaryLight = Color(0xFFEFF6FF); // Blue-50
  static const Color primaryMedium = Color(0xFFDBEAFE); // Blue-100
  static const Color primaryDark = Color(0xFF1E40AF); // Blue-800
  
  /// Blue 그라디언트 (프로필 헤더 등)
  static const LinearGradient blueGradient = LinearGradient(
    colors: [primary, Color(0xFF2563EB)], // Blue-600 to Blue-700
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========================================
  // Secondary Colors (건강/성공 - Green)
  // ========================================
  
  /// 성공, 완료, 건강 상태에 사용
  static const Color secondary = Color(0xFF10B981); // Green-500
  static const Color secondaryLight = Color(0xFFD1FAE5); // Green-100
  static const Color secondaryDark = Color(0xFF047857); // Green-700
  
  /// Green 그라디언트 (건강 관련 카드 등)
  static const LinearGradient greenGradient = LinearGradient(
    colors: [secondary, Color(0xFF059669)], // Green-500 to Green-600
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========================================
  // Accent Colors (강조 - Pink)
  // ========================================
  
  /// 특별한 강조, 한의사 모드 등에 사용
  static const Color accent = Color(0xFFEC4899); // Pink-500
  static const Color accentLight = Color(0xFFFCE7F3); // Pink-100
  static const Color accentDark = Color(0xFFDB2777); // Pink-600

  // ========================================
  // Semantic Colors (상태 색상)
  // ========================================
  
  /// 성공 상태 (예약 완료, 진료 완료 등)
  static const Color success = Color(0xFF10B981); // Green-500
  static const Color successLight = Color(0xFFE7F7EF); // Custom Green-50
  static const Color successDark = Color(0xFF059669); // Green-600
  
  /// 경고 상태 (대기, 주의 필요 등)
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningLight = Color(0xFFFEF3C7); // Amber-100
  static const Color warningDark = Color(0xFFD97706); // Amber-600
  
  /// 오류 상태 (취소, 실패 등)
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color errorLight = Color(0xFFFEE2E2); // Red-100
  static const Color errorDark = Color(0xFFDC2626); // Red-600
  
  /// 정보 상태 (알림, 안내 등)
  static const Color info = Color(0xFF3B82F6); // Blue-600
  static const Color infoLight = Color(0xFFDCFCE7); // Custom Blue-50

  // ========================================
  // Neutral/Gray Scale
  // ========================================
  
  /// 배경 색상
  static const Color background = Color(0xFFF9FAFB); // Gray-50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Gray-100

  /// 텍스트 색상 (계층 구조)
  static const Color textPrimary = Color(0xFF111827); // Gray-900 - 메인 텍스트
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500 - 보조 텍스트
  static const Color textHint = Color(0xFF9CA3AF); // Gray-400 - 힌트, placeholder
  static const Color textDisabled = Color(0xFFD1D5DB); // Gray-300 - 비활성화

  /// 구분선 및 테두리
  static const Color divider = Color(0xFFE5E7EB); // Gray-200
  static const Color border = Color(0xFFE5E7EB); // Gray-200

  // ========================================
  // Icon Colors
  // ========================================
  
  /// 아이콘 색상 (계층 구조)
  static const Color iconPrimary = Color(0xFF374151); // Gray-700 - 주요 아이콘
  static const Color iconSecondary = Color(0xFF9CA3AF); // Gray-400 - 보조 아이콘

  // ========================================
  // Special Use Cases
  // ========================================
  
  /// Kakao 로그인 버튼
  static const Color kakao = Color(0xFFFEE500); // Kakao Yellow
  
  /// 채팅 메시지 배경
  static const Color chatDoctor = Color(0xFFE5E7EB); // Gray-200 (한의사 메시지)
  static const Color chatUser = Color(0xFF10B981); // Green-500 (사용자 메시지)
  
  /// 한의사 인증 배지
  static const Color certificationGreen = Color(0xFF16A34A); // Green-600
  static const Color certificationGreenBg = Color(0xFFDCFCE7); // Green-100
}
