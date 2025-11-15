import 'package:flutter/material.dart';

import '../../../core/models/user_profile.dart';
import '../../../shared/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<UserProfile> _loadProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return UserProfile(
      id: 'user_patient_01',
      name: '김미영',
      age: 46,
      gender: Gender.female,
      address: '서울특별시 성동구 왕십리로 16',
      profileImageUrl:
          'https://readdy.ai/api/search-image?query=Professional%20Korean%20woman%20portrait%2C%20clean%20background%2C%20medical%20patient%20photo%2C%20friendly%20smile%2C%20natural%20lighting%2C%20high%20quality%20headshot&width=256&height=256&seq=profile001&orientation=squarish',
      phoneNumber: '010-4567-1234',
      appointmentCount: 12,
      treatmentCount: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 56, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      '프로필을 불러오는 중 오류가 발생했습니다.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: const Center(
              child: Text('프로필 정보를 찾을 수 없습니다.'),
            ),
          );
        }

        final profile = snapshot.data!;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              children: [
                _ProfileCard(profile: profile, onEdit: _handleEditProfile),
                const SizedBox(height: 12),
                _ProfileStats(profile: profile),
                const SizedBox(height: 16),
                _QuickActionGrid(onNavigate: _showSnack),
                const SizedBox(height: 16),
                _MenuSection(
                  onCustomerSupport: _showSupportSheet,
                  onSettings: () => _showSnack('설정 화면으로 이동합니다'),
                  onLegalNotice: () => _showSnack('법적 고지 화면으로 이동합니다'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        '프로필',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: AppColors.iconPrimary),
          onPressed: () => _showSnack('설정 화면으로 이동합니다'),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.divider),
      ),
    );
  }

  void _handleEditProfile() {
    _showSnack('프로필 편집 화면으로 이동합니다');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _showSupportSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SupportSheet(
        onPhoneTap: () {
          Navigator.of(ctx).pop();
          _showSnack('1588-1234로 전화 상담을 연결합니다');
        },
        onChatTap: () {
          Navigator.of(ctx).pop();
          _showSnack('채팅 상담을 시작합니다');
        },
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.onEdit,
  });

  final UserProfile profile;
  final VoidCallback onEdit;

  String get _genderLabel =>
      profile.gender == Gender.female ? '여성' : '남성';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileAvatar(imageUrl: profile.profileImageUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        profile.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: onEdit,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('수정'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${profile.age}세 / $_genderLabel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.address,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              value: profile.appointmentCount.toString(),
              label: '예약',
              valueColor: AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 64,
            color: AppColors.border,
          ),
          Expanded(
            child: _StatTile(
              value: profile.treatmentCount.toString(),
              label: '진료',
              valueColor: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        width: 72,
        height: 72,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Icon(
        Icons.person,
        size: 36,
        color: AppColors.iconSecondary,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        title: '진료 기록',
        icon: Icons.description_outlined,
        iconColor: AppColors.primary,
        backgroundColor: const Color(0xFFEFF6FF),
        onTapMessage: '진료 기록 화면으로 이동합니다',
      ),
      _QuickActionData(
        title: '건강보험',
        icon: Icons.health_and_safety_outlined,
        iconColor: AppColors.success,
        backgroundColor: const Color(0xFFE7F7EF),
        onTapMessage: '건강보험 화면으로 이동합니다',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionCard(
          data: action,
          onTap: () => onNavigate(action.onTapMessage),
        );
      },
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTapMessage,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String onTapMessage;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.data,
    required this.onTap,
  });

  final _QuickActionData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: data.iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                data.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.onCustomerSupport,
    required this.onSettings,
    required this.onLegalNotice,
  });

  final VoidCallback onCustomerSupport;
  final VoidCallback onSettings;
  final VoidCallback onLegalNotice;

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItemData(
        title: '고객지원',
        icon: Icons.support_agent_outlined,
        onTap: onCustomerSupport,
      ),
      _MenuItemData(
        title: '설정',
        icon: Icons.settings_outlined,
        onTap: onSettings,
      ),
      _MenuItemData(
        title: '법적 고지',
        icon: Icons.description_outlined,
        onTap: onLegalNotice,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _MenuButton(data: items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, thickness: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.data});

  final _MenuItemData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(data.icon, color: AppColors.iconPrimary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  data.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppColors.iconSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportSheet extends StatelessWidget {
  const _SupportSheet({
    required this.onPhoneTap,
    required this.onChatTap,
  });

  final VoidCallback onPhoneTap;
  final VoidCallback onChatTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '고객지원',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _SupportButton(
              icon: Icons.phone_in_talk_outlined,
              label: '전화 상담',
              background: AppColors.primaryLight,
              iconColor: AppColors.primary,
              onTap: onPhoneTap,
            ),
            const SizedBox(height: 12),
            _SupportButton(
              icon: Icons.chat_bubble_outline,
              label: '채팅 상담',
              background: AppColors.successLight,
              iconColor: AppColors.success,
              onTap: onChatTap,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportButton extends StatelessWidget {
  const _SupportButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
