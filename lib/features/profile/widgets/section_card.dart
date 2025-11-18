import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          // Section content
          ...children,
        ],
      ),
    );
  }
}
