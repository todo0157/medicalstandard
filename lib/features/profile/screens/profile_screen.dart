import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/services/auth_state.dart';
import '../../../core/services/auth_session.dart';
import '../../doctor/providers/doctor_providers.dart';
import '../../../shared/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _handleRefresh() async {
    await Future.wait([
      ref.read(profileStateNotifierProvider.notifier).loadProfile(
            forceRefresh: true,
          ),
      ref.read(appointmentsNotifierProvider.notifier).refresh(),
    ]);
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await _confirm(
      '예약 취소',
      '선택한 예약을 취소하시겠어요?',
    );
    if (!mounted || !confirmed) return;

    try {
      await ref
          .read(appointmentsNotifierProvider.notifier)
          .cancel(appointment.id);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('예약을 취소했습니다.')));
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('취소에 실패했습니다.')));
    }
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await _confirm(
      '예약 삭제',
      '취소된 예약을 목록에서 삭제할까요?',
    );
    if (!mounted || !confirmed) return;

    try {
      await ref
          .read(appointmentsNotifierProvider.notifier)
          .remove(appointment.id);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('예약을 삭제했습니다.')));
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('삭제에 실패했습니다.')));
    }
  }

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('예'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileStateNotifierProvider);
    final appointmentsState = ref.watch(appointmentsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: profileState.when(
        loading: () => const _ProfileLoadingView(),
        error: (error, stackTrace) => _ProfileErrorView(
          message: _mapErrorMessage(error),
          onRetry: _handleRefresh,
          onSupport: _showSupportSheet,
        ),
        data: (profile) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              children: [
                _ProfileCard(profile: profile, onEdit: _handleEditProfile),
                const SizedBox(height: 12),
                _ProfileStats(profile: profile),
                const SizedBox(height: 16),
                _AppointmentSection(
                  state: appointmentsState,
                  onRetry: () =>
                      ref.read(appointmentsNotifierProvider.notifier).refresh(),
                  onCancel: _cancelAppointment,
                  onDelete: _deleteAppointment,
                ),
                const SizedBox(height: 16),
                _QuickActionGrid(onAction: _handleQuickAction),
                const SizedBox(height: 16),
                _MenuSection(
                  onCustomerSupport: _showSupportSheet,
                  onSettings: _handleEditProfile,
                  onLegalNotice: () => _showSnack('법적 고지 화면으로 이동합니다'),
                  onLogout: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mapErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return '프로필 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
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
          icon: const Icon(
            Icons.settings_outlined,
            color: AppColors.iconPrimary,
          ),
          onPressed: _handleEditProfile,
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.divider),
      ),
    );
  }

  Future<void> _handleEditProfile() async {
    final result = await context.push('/profile/edit');
    if (!mounted) return;
    if (result == true) {
      // 프로필이 저장되었으므로 강제로 새로고침
      await ref.read(profileStateNotifierProvider.notifier).loadProfile(
        forceRefresh: true,
      );
      _showSnack('프로필이 저장되었습니다.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  void _handleQuickAction(String actionKey) {
    switch (actionKey) {
      case 'records':
        context.push('/medical-records');
        break;
      case 'insurance':
        context.push('/health-insurance');
        break;
      default:
        _showSnack('곧 제공됩니다.');
    }
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

  Future<void> _logout() async {
    await AuthSession.instance.clear();
    AuthState.instance.setAuthenticated(false);
    if (!mounted) return;
    context.go('/login');
  }
}

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({
    required this.message,
    required this.onRetry,
    required this.onSupport,
  });

  final String message;
  final Future<void> Function() onRetry;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              '프로필 정보를 불러오지 못했습니다.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도하기'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onSupport,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('고객센터'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onEdit});

  final UserProfile profile;
  final Future<void> Function() onEdit;

  String get _genderLabel => profile.gender == Gender.female ? '여성' : '남성';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => onEdit(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
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
          Container(width: 1, height: 64, color: AppColors.border),
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

class _AppointmentSection extends StatelessWidget {
  const _AppointmentSection({
    required this.state,
    required this.onRetry,
    required this.onCancel,
    required this.onDelete,
  });

  final AsyncValue<List<Appointment>> state;
  final Future<void> Function() onRetry;
  final Future<void> Function(Appointment appointment) onCancel;
  final Future<void> Function(Appointment appointment) onDelete;
  static const _maxVisible = 5;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '내 예약',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          state.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (error, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '예약 정보를 불러오지 못했습니다.',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
            data: (appointments) {
              if (appointments.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '아직 예약이 없습니다. 가까운 한의사를 찾아보세요.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/find-doctor'),
                      icon: const Icon(Icons.search, color: AppColors.primary),
                      label: const Text('한의사 찾기'),
                    ),
                  ],
                );
              }

              final formatter = DateFormat('M월 d일 (E) a h:mm', 'ko');
              final visible = appointments.take(_maxVisible).toList();
              final remaining = appointments.length - visible.length;

              return Column(
                children: [
                  for (final appointment in visible) ...[
                    _AppointmentCard(
                      appointment: appointment,
                      formatter: formatter,
                      onCancel: () => onCancel(appointment),
                      onDelete: () => onDelete(appointment),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (remaining > 0)
                    Text(
                      '외 $remaining건의 예약이 있습니다.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.formatter,
    this.onCancel,
    this.onDelete,
  });

  final Appointment appointment;
  final DateFormat formatter;
  final Future<void> Function()? onCancel;
  final Future<void> Function()? onDelete;

  String get _statusLabel {
    switch (appointment.status) {
      case 'confirmed':
        return '확정';
      case 'cancelled':
        return '취소';
      case 'completed':
        return '완료';
      default:
        return '대기';
    }
  }

  Color get _statusColor {
    switch (appointment.status) {
      case 'confirmed':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCancel =
        appointment.status != 'cancelled' && appointment.status != 'completed';
    final canDelete = appointment.status == 'cancelled';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.doctor.specialty,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
              appointment.doctor.clinicName,
              style: const TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 18, color: AppColors.iconSecondary),
              const SizedBox(width: 6),
              Text(
                formatter.format(appointment.slot.startsAt.toLocal()),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.push_pin_outlined,
                  size: 18, color: AppColors.iconSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  appointment.notes?.isNotEmpty == true
                      ? appointment.notes!
                      : '메모 없음',
                  style: const TextStyle(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
          if (canCancel || canDelete) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (canCancel)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('예약 취소'),
                    ),
                  ),
                if (canDelete) ...[
                  if (canCancel) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('삭제'),
                    ),
                  ),
                ],
              ],
            ),
          ],
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
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
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
      child: const Icon(Icons.person, size: 36, color: AppColors.iconSecondary),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.onAction});

  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        title: '진료 기록',
        icon: Icons.description_outlined,
        iconColor: AppColors.primary,
        backgroundColor: const Color(0xFFEFF6FF),
        actionKey: 'records',
      ),
      _QuickActionData(
        title: '건강보험',
        icon: Icons.health_and_safety_outlined,
        iconColor: AppColors.success,
        backgroundColor: const Color(0xFFE7F7EF),
        actionKey: 'insurance',
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
          onTap: () => onAction(action.actionKey),
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
    required this.actionKey,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String actionKey;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.data, required this.onTap});

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
              color: Colors.black.withValues(alpha: 0.02),
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
    required this.onLogout,
  });

  final VoidCallback onCustomerSupport;
  final VoidCallback onSettings;
  final VoidCallback onLegalNotice;
  final VoidCallback onLogout;

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
      _MenuItemData(
        title: '로그아웃',
        icon: Icons.logout,
        onTap: onLogout,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.iconSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportSheet extends StatelessWidget {
  const _SupportSheet({required this.onPhoneTap, required this.onChatTap});

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
