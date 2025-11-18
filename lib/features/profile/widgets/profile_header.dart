import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../shared/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onProfileImageTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onProfileImageTap,
  });

  String _getGenderLabel(Gender gender) {
    return gender == Gender.male ? '남성' : '여성';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          // Profile Image
          GestureDetector(
            onTap: onProfileImageTap,
            child: CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: profile.profileImageUrl != null
                  ? NetworkImage(profile.profileImageUrl!)
                  : null,
              child: profile.profileImageUrl == null
                  ? Icon(Icons.person, size: 32, color: AppColors.textSecondary)
                  : null,
            ),
          ),
          SizedBox(width: 16),
          // User Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                // Age and Gender
                Text(
                  '${profile.age}세 • ${_getGenderLabel(profile.gender)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                // Address
                Text(
                  profile.address,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
