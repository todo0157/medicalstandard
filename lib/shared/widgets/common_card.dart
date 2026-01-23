import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// 앱 전체에서 사용하는 공통 카드 컴포넌트
/// 
/// 디자인 시스템을 따르는 일관된 카드 스타일을 제공합니다.
/// - BaseCard: 기본 카드
/// - StatCard: 통계 카드 (숫자 강조)
/// - ListCard: 리스트 아이템 카드
/// - GradientCard: 그라디언트 배경 카드

// ========================================
// Base Card (기본 카드)
// ========================================

class AppBaseCard extends StatelessWidget {
  const AppBaseCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color = AppColors.surface,
    this.borderColor,
    this.shadow = true,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color color;
  final Color? borderColor;
  final bool shadow;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final cardRadius = radius ?? AppRadius.cardRadius;
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: cardRadius,
        border: borderColor != null 
            ? Border.all(color: borderColor!) 
            : Border.all(color: AppColors.border),
        boxShadow: shadow ? AppShadows.card : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardRadius,
          child: Padding(
            padding: padding ?? AppSpacing.cardPaddingAll,
            child: child,
          ),
        ),
      ),
    );
  }
}

// ========================================
// Stat Card (통계 카드)
// ========================================

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
    this.trend,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? trend; // "+2", "-1" 등
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppBaseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 아이콘
          Container(
            padding: AppSpacing.allXS,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: AppSpacing.sm),
          
          // 값 + 트렌드
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.displaySmall.copyWith(color: color),
              ),
              if (trend != null) ...[
                SizedBox(width: AppSpacing.xxs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getTrendColor(trend!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trend!,
                    style: AppTypography.captionSmall.copyWith(
                      color: _getTrendColor(trend!),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          
          // 라벨
          Text(
            label,
            style: AppTypography.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    if (trend.startsWith('+')) {
      return AppColors.success;
    } else if (trend.startsWith('-')) {
      return AppColors.error;
    }
    return AppColors.textHint;
  }
}

// ========================================
// List Card (리스트 아이템)
// ========================================

class AppListCard extends StatelessWidget {
  const AppListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.margin,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return AppBaseCard(
      onTap: onTap,
      margin: margin ?? EdgeInsets.only(bottom: AppSpacing.listItemSpacing),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headingMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ========================================
// Gradient Card (그라디언트 배경)
// ========================================

class AppGradientCard extends StatelessWidget {
  const AppGradientCard({
    super.key,
    required this.child,
    this.gradient = AppColors.blueGradient,
    this.padding,
    this.margin,
    this.onTap,
    this.radius,
    this.shadow = true,
  });

  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final cardRadius = radius ?? AppRadius.cardLargeRadius;
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: cardRadius,
        boxShadow: shadow ? AppShadows.cardElevated : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardRadius,
          child: Padding(
            padding: padding ?? AppSpacing.cardPaddingAll,
            child: child,
          ),
        ),
      ),
    );
  }
}

// ========================================
// Info Card (정보 박스)
// ========================================

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.type = InfoCardType.info,
  });

  final String title;
  final String content;
  final IconData? icon;
  final InfoCardType type;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(type);
    
    return Container(
      padding: AppSpacing.cardPaddingAll,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: AppSpacing.allXS,
              decoration: BoxDecoration(
                color: colors.iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.iconColor, size: 20),
            ),
            SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headingSmall.copyWith(
                    color: colors.textColor,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  content,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _InfoCardColors _getColors(InfoCardType type) {
    switch (type) {
      case InfoCardType.success:
        return _InfoCardColors(
          backgroundColor: AppColors.successLight,
          borderColor: AppColors.success.withOpacity(0.3),
          iconColor: AppColors.success,
          iconBackgroundColor: AppColors.success.withOpacity(0.2),
          textColor: AppColors.success.withOpacity(0.8),
        );
      case InfoCardType.warning:
        return _InfoCardColors(
          backgroundColor: AppColors.warningLight,
          borderColor: AppColors.warning.withOpacity(0.3),
          iconColor: AppColors.warning,
          iconBackgroundColor: AppColors.warning.withOpacity(0.2),
          textColor: AppColors.warning.withOpacity(0.8),
        );
      case InfoCardType.error:
        return _InfoCardColors(
          backgroundColor: AppColors.errorLight,
          borderColor: AppColors.error.withOpacity(0.3),
          iconColor: AppColors.error,
          iconBackgroundColor: AppColors.error.withOpacity(0.2),
          textColor: AppColors.error.withOpacity(0.8),
        );
      case InfoCardType.info:
      default:
        return _InfoCardColors(
          backgroundColor: AppColors.infoLight,
          borderColor: AppColors.info.withOpacity(0.3),
          iconColor: AppColors.info,
          iconBackgroundColor: AppColors.info.withOpacity(0.2),
          textColor: AppColors.info.withOpacity(0.8),
        );
    }
  }
}

class _InfoCardColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color textColor;

  _InfoCardColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.textColor,
  });
}

enum InfoCardType {
  success,
  warning,
  error,
  info,
}

