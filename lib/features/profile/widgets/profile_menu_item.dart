import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class ProfileMenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool showDivider;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconBackgroundColor,
    this.iconColor,
    required this.onTap,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: TextStyle(
                        fontSize: 20,
                        color: iconColor ?? AppColors.iconPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.divider,
            indent: 68, // Align with text, not icon
          ),
      ],
    );
  }
}
