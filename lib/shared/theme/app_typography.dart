import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 앱 전체에서 사용하는 통합 타이포그래피 시스템
/// 
/// 텍스트 스타일을 6단계로 표준화하여 일관된 정보 계층 구조를 제공합니다.
/// - Display: 매우 큰 제목 (28-32px)
/// - Title: 제목 (18-24px)
/// - Heading: 소제목 (14-16px)
/// - Body: 본문 (13-16px)
/// - Label: 라벨 (11-14px)
/// - Caption: 설명/힌트 (12px)
class AppTypography {
  // ========================================
  // Display (매우 큰 제목)
  // ========================================
  // 사용처: 온보딩, 랜딩 페이지, 중요한 메시지
  
  /// Display Large - 32px, Bold
  /// 예: 온보딩 화면 메인 제목
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  /// Display Medium - 28px, Bold
  /// 예: 큰 섹션 제목, 강조 메시지
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  /// Display Small - 24px, Bold
  /// 예: 카드 내 큰 제목
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // ========================================
  // Title (제목)
  // ========================================
  // 사용처: 페이지 제목, AppBar 제목, 섹션 제목
  
  /// Title Large - 24px, Bold
  /// 예: 페이지 메인 제목
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  /// Title Medium - 20px, SemiBold
  /// 예: AppBar 제목, 큰 섹션 제목
  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  /// Title Small - 18px, SemiBold
  /// 예: 작은 섹션 제목, 카드 제목
  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.4,
  );

  // ========================================
  // Heading (소제목)
  // ========================================
  // 사용처: 카드 내 소제목, 리스트 항목 제목
  
  /// Heading Large - 16px, Bold
  /// 예: 카드 내 메인 소제목
  static const TextStyle headingLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  /// Heading Medium - 15px, SemiBold
  /// 예: 리스트 항목 제목
  static const TextStyle headingMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  /// Heading Small - 14px, SemiBold
  /// 예: 작은 카드 제목, 버튼 라벨
  static const TextStyle headingSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ========================================
  // Body (본문)
  // ========================================
  // 사용처: 일반 텍스트, 설명, 콘텐츠
  
  /// Body Large - 16px, Regular
  /// 예: 중요한 본문, 설명 텍스트
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Body Medium - 14px, Regular
  /// 예: 일반 본문, 카드 설명
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Body Small - 13px, Regular
  /// 예: 작은 설명 텍스트, 보조 정보
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ========================================
  // Label (라벨)
  // ========================================
  // 사용처: 입력 필드 라벨, 작은 제목, 태그
  
  /// Label Large - 14px, Medium
  /// 예: 입력 필드 라벨, 중요 태그
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  /// Label Medium - 12px, Medium
  /// 예: 작은 라벨, 배지 텍스트
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  /// Label Small - 11px, Medium
  /// 예: 매우 작은 라벨, 상태 표시
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ========================================
  // Caption (설명/힌트)
  // ========================================
  // 사용처: 힌트 텍스트, placeholder, 메타 정보
  
  /// Caption - 12px, Regular
  /// 예: 힌트 텍스트, 날짜, 시간, 작은 정보
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
    height: 1.3,
  );
  
  /// Caption Small - 11px, Regular
  /// 예: 매우 작은 메타 정보
  static const TextStyle captionSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
    height: 1.3,
  );

  // ========================================
  // Button (버튼 텍스트)
  // ========================================
  // 사용처: 버튼 라벨
  
  /// Button - 15px, SemiBold
  /// 예: 큰 버튼 (Primary, Secondary)
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
  );
  
  /// Button Small - 13px, SemiBold
  /// 예: 작은 버튼, Outlined 버튼
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
  );

  // ========================================
  // Utility Helpers
  // ========================================
  // 색상 변경, 굵기 변경 등 유틸리티 메서드
  
  /// 텍스트 색상 변경 헬퍼
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// 텍스트 굵기 변경 헬퍼
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// 텍스트 크기 변경 헬퍼
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  // ========================================
  // Semantic Text Styles
  // ========================================
  // 특정 용도에 최적화된 미리 정의된 스타일
  
  /// 성공 메시지 텍스트
  static TextStyle successText = bodyMedium.copyWith(
    color: AppColors.success,
    fontWeight: FontWeight.w600,
  );
  
  /// 오류 메시지 텍스트
  static TextStyle errorText = bodyMedium.copyWith(
    color: AppColors.error,
    fontWeight: FontWeight.w600,
  );
  
  /// 경고 메시지 텍스트
  static TextStyle warningText = bodyMedium.copyWith(
    color: AppColors.warning,
    fontWeight: FontWeight.w600,
  );
  
  /// 정보 메시지 텍스트
  static TextStyle infoText = bodyMedium.copyWith(
    color: AppColors.info,
    fontWeight: FontWeight.w600,
  );
  
  /// 링크 텍스트
  static TextStyle linkText = bodyMedium.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );
  
  /// 가격 텍스트 (굵고 크게)
  static TextStyle priceText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  /// 할인 가격 텍스트 (빨간색)
  static TextStyle discountPriceText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.error,
    height: 1.2,
  );
  
  /// 채팅 메시지 시간 텍스트
  static TextStyle chatTimeText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
    height: 1.2,
  );
  
  /// 배지 텍스트
  static TextStyle badgeText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
    height: 1.2,
  );
}

