import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// 앱 전체에서 사용하는 공통 버튼 컴포넌트
/// 
/// 디자인 시스템을 따르는 일관된 버튼 스타일을 제공합니다.
/// - PrimaryButton: 주요 액션 (파란색)
/// - SecondaryButton: 보조 액션 (초록색)
/// - BrandButton: 브랜딩 버튼 (하니비 그라디언트)
/// - OutlinedButton: 외곽선 버튼
/// - TextButton: 텍스트만 있는 버튼

// ========================================
// Primary Button (주요 액션)
// ========================================

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final padding = size == ButtonSize.large
        ? AppSpacing.buttonPaddingLarge
        : AppSpacing.buttonPaddingDefault;
    
    final textStyle = size == ButtonSize.large
        ? AppTypography.button
        : AppTypography.buttonSmall;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: size == ButtonSize.large ? 20 : 18),
                    SizedBox(width: AppSpacing.xs),
                  ],
                  Text(text, style: textStyle),
                ],
              ),
      ),
    );
  }
}

// ========================================
// Secondary Button (보조 액션)
// ========================================

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final padding = size == ButtonSize.large
        ? AppSpacing.buttonPaddingLarge
        : AppSpacing.buttonPaddingDefault;
    
    final textStyle = size == ButtonSize.large
        ? AppTypography.button
        : AppTypography.buttonSmall;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: size == ButtonSize.large ? 20 : 18),
                    SizedBox(width: AppSpacing.xs),
                  ],
                  Text(text, style: textStyle),
                ],
              ),
      ),
    );
  }
}

// ========================================
// Brand Button (하니비 브랜딩)
// ========================================

class AppBrandButton extends StatelessWidget {
  const AppBrandButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = ButtonSize.large,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final padding = size == ButtonSize.large
        ? AppSpacing.buttonPaddingLarge
        : AppSpacing.buttonPaddingDefault;
    
    final textStyle = size == ButtonSize.large
        ? AppTypography.button
        : AppTypography.buttonSmall;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: AppRadius.buttonRadius,
          boxShadow: AppShadows.brandShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: AppRadius.buttonRadius,
            child: Container(
              padding: padding,
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, 
                            size: size == ButtonSize.large ? 20 : 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: AppSpacing.xs),
                        ],
                        Text(
                          text, 
                          style: textStyle.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================
// Outlined Button (외곽선)
// ========================================

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.color = AppColors.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.size = ButtonSize.medium,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final Color color;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final padding = size == ButtonSize.large
        ? AppSpacing.buttonPaddingLarge
        : AppSpacing.buttonPaddingDefault;
    
    final textStyle = size == ButtonSize.large
        ? AppTypography.button
        : AppTypography.buttonSmall;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: padding,
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: color,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: size == ButtonSize.large ? 20 : 18),
                    SizedBox(width: AppSpacing.xs),
                  ],
                  Text(text, style: textStyle),
                ],
              ),
      ),
    );
  }
}

// ========================================
// Text Button (텍스트만)
// ========================================

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.color = AppColors.primary,
    this.size = ButtonSize.medium,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final Color color;
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final textStyle = size == ButtonSize.large
        ? AppTypography.button
        : AppTypography.buttonSmall;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: size == ButtonSize.large ? 20 : 18),
            SizedBox(width: AppSpacing.xs),
          ],
          Text(text, style: textStyle),
        ],
      ),
    );
  }
}

// ========================================
// Icon Button (아이콘만)
// ========================================

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color = AppColors.iconPrimary,
    this.backgroundColor,
    this.size = 40.0,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        iconSize: size * 0.5,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// ========================================
// Button Size Enum
// ========================================

enum ButtonSize {
  large,
  medium,
  small,
}

