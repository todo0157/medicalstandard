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

// 디자인 시스템 import (Phase 1)
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/widgets/common_button.dart';
import '../../../shared/widgets/common_card.dart';
import '../../../shared/widgets/common_badge.dart';

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

  Future<void> _editAppointment(Appointment appointment) async {
    // 예약 수정 화면으로 이동
    if (!mounted) return;
    await context.push(
      '/booking',
      extra: appointment,
    );
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
          onLogout: _logout,
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
                _CertificationStatusCard(profile: profile),
                const SizedBox(height: 12),
                _ProfileStats(profile: profile),
                const SizedBox(height: 16),
                _AppointmentSection(
                  state: appointmentsState,
                  onRetry: () =>
                      ref.read(appointmentsNotifierProvider.notifier).refresh(),
                  onCancel: _cancelAppointment,
                  onDelete: _deleteAppointment,
                  onEdit: _editAppointment,
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
    required this.onLogout,
  });

  final String message;
  final Future<void> Function() onRetry;
  final VoidCallback onSupport;
  final VoidCallback onLogout;

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
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, size: 16, color: AppColors.textSecondary),
              label: Text(
                '로그아웃',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
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
    return AppGradientCard(
      gradient: AppColors.blueGradient,
      padding: EdgeInsets.all(AppSpacing.cardPaddingLarge), // 20px
      radius: AppRadius.cardLargeRadius, // 20px
      shadow: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 프로필 이미지
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: _ProfileAvatar(
              imageUrl: profile.profileImageUrl,
              size: 72,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          
          // 정보
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
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 수정 버튼 (아이콘)
                    Material(
                      color: Colors.white.withOpacity(0.2),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: onEdit,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  '${profile.age}세 · $_genderLabel',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.location_on, 
                      size: 16, 
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        profile.address,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificationStatusCard extends ConsumerWidget {
  const _CertificationStatusCard({required this.profile});

  final UserProfile profile;

  String _getStatusText(CertificationStatus status) {
    switch (status) {
      case CertificationStatus.none:
        return '인증 없음';
      case CertificationStatus.pending:
        return '인증 대기 중';
      case CertificationStatus.verified:
        return '인증 완료';
    }
  }

  BadgeType _getBadgeType(CertificationStatus status) {
    switch (status) {
      case CertificationStatus.none:
        return BadgeType.info;
      case CertificationStatus.pending:
        return BadgeType.warning;
      case CertificationStatus.verified:
        return BadgeType.success;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeType = _getBadgeType(profile.certificationStatus);
    final statusText = _getStatusText(profile.certificationStatus);

    return AppBaseCard(
      child: Row(
        children: [
          Container(
            padding: AppSpacing.allXS,
            decoration: BoxDecoration(
              color: _getIconColor(badgeType).withOpacity(0.1),
              borderRadius: AppRadius.buttonRadius,
            ),
            child: Icon(
              Icons.verified_user_rounded, 
              color: _getIconColor(badgeType), 
              size: 24
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '한의사 인증 상태',
                  style: AppTypography.headingSmall,
                ),
                SizedBox(height: AppSpacing.xxs),
                AppStatusBadge(
                  label: statusText,
                  type: badgeType,
                ),
              ],
            ),
          ),
          if (profile.certificationStatus == CertificationStatus.none)
            AppOutlinedButton(
              onPressed: () => context.push('/profile/certification-request'),
              text: '인증 신청',
              size: ButtonSize.small,
              isFullWidth: false,
            )
          else if (profile.certificationStatus == CertificationStatus.pending)
            Text(
              '검토 중',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Color _getIconColor(BadgeType type) {
    switch (type) {
      case BadgeType.success: return AppColors.success;
      case BadgeType.warning: return AppColors.warning;
      case BadgeType.error: return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppBaseCard(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppStatCard(
              icon: Icons.calendar_today_rounded,
              value: profile.appointmentCount.toString(),
              label: '예약',
              color: AppColors.primary,
              // trend: '+2', // TODO: 실제 데이터 연동
            ),
          ),
          Container(
            width: 1, 
            height: 40, 
            color: AppColors.divider,
          ),
          Expanded(
            child: AppStatCard(
              icon: Icons.medical_services_rounded,
              value: profile.treatmentCount.toString(),
              label: '진료',
              color: AppColors.success,
              // trend: '+1', // TODO: 실제 데이터 연동
            ),
          ),
          Container(
            width: 1, 
            height: 40, 
            color: AppColors.divider,
          ),
          Expanded(
            child: AppStatCard(
              icon: Icons.star_rounded,
              value: '4.8', // TODO: 실제 데이터 연동
              label: '만족도',
              color: AppColors.warning,
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
    required this.onEdit,
  });

  final AsyncValue<List<Appointment>> state;
  final Future<void> Function() onRetry;
  final Future<void> Function(Appointment appointment) onCancel;
  final Future<void> Function(Appointment appointment) onDelete;
  final Future<void> Function(Appointment appointment) onEdit;
  static const _maxVisible = 5;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event_available, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              '내 예약',
              style: AppTypography.titleSmall,
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
              Text(
                '예약 정보를 불러오지 못했습니다.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              AppTextButton(
                onPressed: onRetry,
                icon: Icons.refresh,
                text: '다시 시도',
              ),
            ],
          ),
          data: (appointments) {
            if (appointments.isEmpty) {
              return AppInfoCard(
                title: '예약 없음',
                content: '아직 예약이 없습니다. 가까운 한의사를 찾아보세요.',
                icon: Icons.calendar_today_outlined,
                type: InfoCardType.info,
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
                    onEdit: () => onEdit(appointment),
                  ),
                  const SizedBox(height: 12),
                ],
                if (remaining > 0)
                  Text(
                    '외 $remaining건의 예약이 있습니다.',
                    style: AppTypography.caption,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.formatter,
    this.onCancel,
    this.onDelete,
    this.onEdit,
  });

  final Appointment appointment;
  final DateFormat formatter;
  final Future<void> Function()? onCancel;
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onEdit;

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

  BadgeType get _badgeType {
    switch (appointment.status) {
      case 'confirmed':
        return BadgeType.primary;
      case 'cancelled':
        return BadgeType.error;
      case 'completed':
        return BadgeType.success;
      default:
        return BadgeType.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCancel =
        appointment.status != 'cancelled' && appointment.status != 'completed';
    final canDelete = appointment.status == 'cancelled';

    return AppBaseCard(
      padding: AppSpacing.cardPaddingAll,
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
                      style: AppTypography.headingMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.doctor.specialty,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.doctor.clinicName,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              AppStatusBadge(
                label: _statusLabel,
                type: _badgeType,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppColors.iconSecondary),
              const SizedBox(width: 6),
              Text(
                formatter.format(
                  (appointment.appointmentTime ?? appointment.slot.startsAt).toLocal(),
                ),
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.push_pin_outlined,
                  size: 16, color: AppColors.iconSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  appointment.notes?.isNotEmpty == true
                      ? appointment.notes!
                      : '메모 없음',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (canCancel || canDelete || onEdit != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onEdit != null && canCancel)
                  Expanded(
                    child: AppOutlinedButton(
                      onPressed: onEdit,
                      text: '시간 변경',
                      icon: Icons.edit_outlined,
                      size: ButtonSize.small,
                    ),
                  ),
                if (canCancel) ...[
                  if (onEdit != null) const SizedBox(width: 8),
                  Expanded(
                    child: AppOutlinedButton(
                      onPressed: onCancel,
                      text: '취소',
                      icon: Icons.cancel_outlined,
                      color: AppColors.error,
                      size: ButtonSize.small,
                    ),
                  ),
                ],
                if (canDelete) ...[
                  if (canCancel || onEdit != null) const SizedBox(width: 8),
                  Expanded(
                    child: AppOutlinedButton(
                      onPressed: onDelete,
                      text: '삭제',
                      icon: Icons.delete_outline,
                      color: AppColors.error,
                      size: ButtonSize.small,
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
  const _ProfileAvatar({this.imageUrl, this.size = 72.0});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: SizedBox(
        width: size,
        height: size,
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
      child: Icon(
        Icons.person, 
        size: size * 0.5, 
        color: AppColors.iconSecondary
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
        backgroundColor: AppColors.primaryLight,
        actionKey: 'records',
      ),
      _QuickActionData(
        title: '건강보험',
        icon: Icons.health_and_safety_outlined,
        iconColor: AppColors.success,
        backgroundColor: AppColors.successLight,
        actionKey: 'insurance',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
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
    return AppBaseCard(
      onTap: onTap,
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: AppSpacing.allSM,
            decoration: BoxDecoration(
              color: data.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.iconColor, size: 24),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            data.title,
            style: AppTypography.headingMedium,
          ),
        ],
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
        isDestructive: true,
      ),
    ];

    return AppBaseCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _MenuButton(data: items[i]),
            if (i != items.length - 1)
              Divider(height: 1, thickness: 1, color: AppColors.divider),
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
    this.isDestructive = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
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
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                data.icon, 
                color: data.isDestructive ? AppColors.error : AppColors.iconPrimary,
                size: 20,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  data.title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: data.isDestructive ? AppColors.error : AppColors.textPrimary,
                    fontWeight: data.isDestructive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
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
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.modalTopRadius,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '고객지원',
              style: AppTypography.titleMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            _SupportButton(
              icon: Icons.phone_in_talk_outlined,
              label: '전화 상담',
              background: AppColors.primaryLight,
              iconColor: AppColors.primary,
              onTap: onPhoneTap,
            ),
            SizedBox(height: AppSpacing.md),
            _SupportButton(
              icon: Icons.chat_bubble_outline,
              label: '채팅 상담',
              background: AppColors.successLight,
              iconColor: AppColors.success,
              onTap: onChatTap,
            ),
            SizedBox(height: AppSpacing.lg),
            AppTextButton(
              onPressed: () => Navigator.of(context).pop(),
              text: '취소',
              color: AppColors.textSecondary,
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
          foregroundColor: iconColor,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardRadius,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.button.copyWith(color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}

