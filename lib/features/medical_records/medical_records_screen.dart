import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/medical_record.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_radius.dart';
import '../../shared/theme/app_shadows.dart';
import '../../shared/widgets/common_card.dart';
import '../../shared/widgets/common_button.dart';
import '../../shared/widgets/common_badge.dart';
import 'providers/medical_record_providers.dart';

class MedicalRecordsScreen extends ConsumerWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(medicalRecordsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '진료 기록',
          style: AppTypography.titleMedium,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: recordsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _ErrorView(
          message: '진료 기록을 불러오지 못했어요: $error',
          onRetry: () => ref.refresh(medicalRecordsProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return _EmptyView(
              onExplore: () => Navigator.of(context).pop(),
            );
          }
          return SingleChildScrollView(
            padding: AppSpacing.screenPaddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(records),
                SizedBox(height: AppSpacing.sectionSpacing),
                Text(
                  "최근 진료 내역",
                  style: AppTypography.headingMedium,
                ),
                SizedBox(height: AppSpacing.md),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _RecordCard(
                      record: record,
                      onTap: () => _showRecordSheet(context, record),
                    );
                  },
                ),
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(List<MedicalRecord> records) {
    final totalVisits = records.length;
    // 가장 최근 진료 병원 찾기
    final lastHospital = records.isNotEmpty ? records.first.doctor.clinicName : '-';

    return AppGradientCard(
      gradient: AppColors.brandGradient,
      padding: AppSpacing.allLG,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "총 진료 횟수",
                  style: AppTypography.labelMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  "$totalVisits회",
                  style: AppTypography.displaySmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "최근 방문",
                  style: AppTypography.labelMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  lastHospital,
                  style: AppTypography.titleMedium.copyWith(color: Colors.white),
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


  void _showRecordSheet(BuildContext context, MedicalRecord record) {
    final dateLabel = DateFormat('yyyy.MM.dd').format(record.createdAt.toLocal());
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.modalTopRadius,
          ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      record.title,
                      style: AppTypography.headingLarge,
                    ),
                  ),
                  AppStatusBadge(
                    label: "진료완료",
                    type: BadgeType.success,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                '${record.doctor.name} 원장 · ${record.doctor.specialty} · $dateLabel',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSpacing.xl),
              if (record.summary != null && record.summary!.isNotEmpty) ...[
                const _SectionTitle(label: '진료 내용'),
                Container(
                  width: double.infinity,
                  padding: AppSpacing.allMD,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadius.cardRadius,
                  ),
                  child: Text(
                    record.summary!,
                    style: AppTypography.bodyMedium.copyWith(height: 1.5),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
              ],
              if (record.prescriptions != null &&
                  record.prescriptions!.isNotEmpty) ...[
                const _SectionTitle(label: '처방/가이드'),
                Container(
                  width: double.infinity,
                  padding: AppSpacing.allMD,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: AppRadius.cardRadius,
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medication_rounded, size: 16, color: AppColors.primary),
                          SizedBox(width: AppSpacing.xs),
                          Text("처방전", style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        record.prescriptions!,
                        style: AppTypography.bodyMedium.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
              ],
              SizedBox(width: double.infinity, child: AppPrimaryButton(
                onPressed: () => Navigator.pop(context),
                text: "닫기",
              )),
            ],
          ),
        );
      },
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onTap});

  final MedicalRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('yyyy.MM.dd').format(record.createdAt.toLocal());
    return AppBaseCard(
      onTap: onTap,
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.allSM,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 20),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: AppTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${record.doctor.name} 원장 · ${record.doctor.specialty}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Text(
                dateLabel,
                style: AppTypography.caption.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
          if (record.summary != null && record.summary!.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md, left: 44), // 아이콘 너비 + 간격만큼 들여쓰기
              child: Text(
                record.summary!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppSpacing.allXL,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.description_outlined,
                  size: 48, color: AppColors.textHint),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              '아직 진료 기록이 없어요',
              style: AppTypography.titleMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '첫 방문 진료를 예약하면 진료 기록이 여기에 저장돼요.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 200,
              child: AppPrimaryButton(
                onPressed: onExplore,
                text: "한의사 찾기",
                icon: Icons.search_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 160,
              child: AppOutlinedButton(
                onPressed: onRetry,
                text: "다시 시도",
                icon: Icons.refresh_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
