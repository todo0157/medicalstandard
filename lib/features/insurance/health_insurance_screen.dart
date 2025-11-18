import 'package:flutter/material.dart';
import '../../shared/theme/app_colors.dart';

class HealthInsuranceScreen extends StatelessWidget {
  const HealthInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.iconPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '건강보험',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 48,
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              '건강보험 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
