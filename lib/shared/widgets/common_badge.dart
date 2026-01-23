import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';

/// 앱 전체에서 사용하는 공통 배지 컴포넌트
/// 
/// 디자인 시스템을 따르는 일관된 배지 스타일을 제공합니다.
/// - StatusBadge: 상태 배지 (성공/경고/오류/정보)
/// - CategoryBadge: 카테고리 배지
/// - CountBadge: 숫자 배지 (읽지 않은 메시지 등)

// ========================================
// Status Badge (상태 배지)
// ========================================

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.info,
    this.icon,
  });

  final String label;
  final BadgeType type;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(type);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: AppRadius.badgeRadius,
        border: Border.all(
          color: colors.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.badgeText.copyWith(
              color: colors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _getColors(BadgeType type) {
    switch (type) {
      case BadgeType.success:
        return _BadgeColors(
          backgroundColor: AppColors.successLight,
          borderColor: AppColors.success.withOpacity(0.3),
          textColor: AppColors.success,
        );
      case BadgeType.warning:
        return _BadgeColors(
          backgroundColor: AppColors.warningLight,
          borderColor: AppColors.warning.withOpacity(0.3),
          textColor: AppColors.warning,
        );
      case BadgeType.error:
        return _BadgeColors(
          backgroundColor: AppColors.errorLight,
          borderColor: AppColors.error.withOpacity(0.3),
          textColor: AppColors.error,
        );
      case BadgeType.primary:
        return _BadgeColors(
          backgroundColor: AppColors.primaryLight,
          borderColor: AppColors.primary.withOpacity(0.3),
          textColor: AppColors.primary,
        );
      case BadgeType.secondary:
        return _BadgeColors(
          backgroundColor: AppColors.secondaryLight,
          borderColor: AppColors.secondary.withOpacity(0.3),
          textColor: AppColors.secondary,
        );
      case BadgeType.info:
      default:
        return _BadgeColors(
          backgroundColor: AppColors.infoLight,
          borderColor: AppColors.info.withOpacity(0.3),
          textColor: AppColors.info,
        );
    }
  }
}

class _BadgeColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  _BadgeColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}

enum BadgeType {
  success,
  warning,
  error,
  info,
  primary,
  secondary,
}

// ========================================
// Category Badge (카테고리 배지)
// ========================================

class AppCategoryBadge extends StatelessWidget {
  const AppCategoryBadge({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.icon,
    this.size = BadgeSize.medium,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final BadgeSize size;

  @override
  Widget build(BuildContext context) {
    final isSmall = size == BadgeSize.small;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: isSmall 
            ? AppRadius.badgeSmallRadius 
            : AppRadius.badgeRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon, 
              size: isSmall ? 12 : 14, 
              color: color,
            ),
            SizedBox(width: isSmall ? 2 : 4),
          ],
          Text(
            label,
            style: (isSmall 
                ? AppTypography.captionSmall 
                : AppTypography.labelMedium
            ).copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

enum BadgeSize {
  small,
  medium,
  large,
}

// ========================================
// Count Badge (숫자 배지)
// ========================================

class AppCountBadge extends StatelessWidget {
  const AppCountBadge({
    super.key,
    required this.count,
    this.color = AppColors.error,
    this.maxCount = 99,
  });

  final int count;
  final Color color;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    
    final displayCount = count > maxCount ? '$maxCount+' : count.toString();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Center(
        child: Text(
          displayCount,
          style: AppTypography.captionSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ========================================
// Notification Dot (알림 점)
// ========================================

class AppNotificationDot extends StatelessWidget {
  const AppNotificationDot({
    super.key,
    this.color = AppColors.error,
    this.size = 8.0,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
}

