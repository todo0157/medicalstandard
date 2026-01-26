import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/doctor.dart';
import '../../../core/models/slot.dart';
import '../../../features/doctor/providers/doctor_providers.dart';

// 디자인 시스템 import (Phase 2)
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/widgets/common_card.dart';
import '../../../shared/widgets/common_button.dart';
import '../../../shared/widgets/common_badge.dart';

class FindDoctorScreen extends ConsumerStatefulWidget {
  const FindDoctorScreen({super.key, this.actionButtonLabel = '상담하기'});

  final String actionButtonLabel;

  @override
  ConsumerState<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends ConsumerState<FindDoctorScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Position? _currentPosition;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _query = '';
  }

  Future<void> _showSlots(Doctor doctor) async {
    // 한의사 선택 시 상담하기 버튼이 있는 바텀시트 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConsultationBottomSheet(
        doctor: doctor,
        actionButtonLabel: widget.actionButtonLabel,
        onConsult: () {
          Navigator.of(context).pop(); // 바텀시트 닫기
          // Doctor 정보를 반환하여 채팅 세션 생성
          if (context.canPop()) {
            context.pop(doctor);
          } else {
            Navigator.of(context).pop(doctor);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(
      doctorSearchProvider(
        DoctorSearchArgs(
          query: _query,
          lat: _currentPosition?.latitude,
          lng: _currentPosition?.longitude,
          radiusKm: 20,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.iconPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '한의사 찾기',
          style: AppTypography.titleMedium,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, 
              AppSpacing.md, 
              AppSpacing.screenPadding, 
              AppSpacing.lg
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SearchBar(
                    controller: _searchController,
                    onSearch: () {
                      setState(() {
                        _query = _searchController.text.trim();
                      });
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                AppOutlinedButton(
                  onPressed: _locating ? null : _useCurrentLocation,
                  text: _currentPosition == null ? '내 주변' : '갱신',
                  icon: _locating ? null : Icons.my_location_rounded,
                  isLoading: _locating,
                  size: ButtonSize.medium,
                  isFullWidth: false,
                ),
              ],
            ),
          ),
          Expanded(
            child: doctorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      '의사 목록을 불러오지 못했어요',
                      style: AppTypography.bodyMedium,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      error.toString(),
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              data: (doctors) => RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView.separated(
                  padding: AppSpacing.screenPaddingAll,
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return _DoctorCard(
                      doctor: doctor,
                      onTap: () => _showSlots(doctor),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
    });
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 필요합니다')),
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = pos;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('현재 위치를 가져오지 못했어요: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _locating = false;
        });
      }
    }
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSearch});
  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.buttonRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: '의사 이름 또는 전문 검색',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          IconButton(
            onPressed: onSearch,
            icon: Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.onTap});
  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBaseCard(
      onTap: onTap,
      padding: AppSpacing.cardPaddingAll,
      child: Row(
        children: [
          _DoctorAvatar(imageUrl: doctor.imageUrl),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        doctor.name,
                        style: AppTypography.headingMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (true) // 임시로 true 처리 (Doctor 모델에 isVerified 필드가 없음)
                      Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                AppCategoryBadge(
                  label: doctor.specialty,
                  color: AppColors.secondary,
                  size: BadgeSize.small,
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.local_hospital_rounded, size: 14, color: AppColors.textHint),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.clinicName,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (doctor.distanceKm != null) ...[
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        '약 ${doctor.distanceKm!.toStringAsFixed(1)} km',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.iconSecondary),
        ],
      ),
    );
  }
}

class _ConsultationBottomSheet extends StatelessWidget {
  const _ConsultationBottomSheet({
    required this.doctor,
    required this.onConsult,
    required this.actionButtonLabel,
  });

  final Doctor doctor;
  final VoidCallback onConsult;
  final String actionButtonLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.modalTopRadius,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          // 한의사 정보
          Row(
            children: [
              _DoctorAvatar(imageUrl: doctor.imageUrl, size: 64),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          doctor.name,
                          style: AppTypography.headingLarge,
                        ),
                        if (true) ...[ // 임시로 true 처리
                          SizedBox(width: 4),
                          Icon(Icons.verified_rounded, size: 18, color: AppColors.primary),
                        ],
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      doctor.specialty,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      doctor.clinicName,
                      style: AppTypography.caption.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          // 상담하기 버튼
          AppPrimaryButton(
            onPressed: onConsult,
            text: actionButtonLabel,
            icon: Icons.check_circle_outline_rounded,
          ),
          SizedBox(height: AppSpacing.md),
          // 취소 버튼
          AppOutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            text: '취소',
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({this.imageUrl, this.size = 70.0});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.cardRadius,
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _fallback();
                },
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Icon(Icons.person, color: AppColors.iconSecondary, size: size * 0.5),
    );
  }
}

class _SlotSheet extends StatefulWidget {
  const _SlotSheet({required this.doctor});
  final Doctor doctor;

  @override
  State<_SlotSheet> createState() => _SlotSheetState();
}

class _SlotSheetState extends State<_SlotSheet> {
  bool _booking = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('M/dd a h:mm');
    return Consumer(
      builder: (context, ref, _) {
        final slotsAsync = ref.watch(slotsProvider(widget.doctor.id));

        Future<void> bookSlot(Slot slot) async {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          setState(() {
            _error = null;
            _booking = true;
          });
          try {
            await ref
                .read(appointmentsNotifierProvider.notifier)
                .book(doctorId: widget.doctor.id, slotId: slot.id);
            if (!mounted) return;
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('예약이 완료되었습니다')));
            navigator.pop();
          } catch (e) {
            setState(() {
              _error = e is AppException ? e.message : '예약에 실패했습니다.';
            });
          } finally {
            if (mounted) {
              setState(() {
                _booking = false;
              });
            }
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.modalTopRadius,
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  widget.doctor.name,
                  style: AppTypography.headingLarge,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  widget.doctor.specialty,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSpacing.lg),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
                Expanded(
                  child: slotsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (_, __) => Center(
                      child: Text(
                        '슬롯을 불러오지 못했습니다', 
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.error)
                      )
                    ),
                    data: (slots) {
                      if (slots.isEmpty) {
                        return Center(
                          child: Text(
                            '예약 가능한 슬롯이 없습니다.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: slots.length,
                        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final slot = slots[index];
                          return AppBaseCard(
                            padding: AppSpacing.cardPaddingAll,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatter.format(slot.startsAt.toLocal()),
                                      style: AppTypography.titleSmall,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${formatter.format(slot.startsAt.toLocal())} - ${formatter.format(slot.endsAt.toLocal())}',
                                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                AppPrimaryButton(
                                  onPressed: _booking ? null : () => bookSlot(slot),
                                  text: "예약",
                                  size: ButtonSize.small,
                                  isLoading: _booking,
                                  isFullWidth: false,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
