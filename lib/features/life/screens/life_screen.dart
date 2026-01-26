import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/health_tip.dart';
import '../../../core/models/health_log.dart';
import '../providers/life_providers.dart';

// 디자인 시스템 import (Phase 1)
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/widgets/common_button.dart';
import '../../../shared/widgets/common_card.dart';
import '../../../shared/widgets/common_badge.dart';

class LifeScreen extends ConsumerWidget {
  const LifeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsDashboard(context, ref),
            SizedBox(height: AppSpacing.sectionSpacing),
            _buildTodayTip(context, ref),
            SizedBox(height: AppSpacing.sectionSpacing),
            _buildHealthLogSection(context, ref),
            SizedBox(height: AppSpacing.sectionSpacing),
            _buildHealthTipsFeed(context, ref),
          ],
        ),
      ),
    );
  }

  // 상단: 통계 대시보드 (NEW)
  Widget _buildStatsDashboard(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: AppStatCard(
            icon: Icons.calendar_month_rounded,
            value: "7일", // TODO: 실제 데이터 연동
            label: "연속 기록",
            color: AppColors.primary,
            trend: "+1",
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppStatCard(
            icon: Icons.sentiment_satisfied_rounded,
            value: "😊", // TODO: 실제 데이터 연동
            label: "평균 기분",
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  // 상단: 오늘의 한방 팁 카드
  Widget _buildTodayTip(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(healthTipsProvider());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "오늘의 한방 팁",
          style: AppTypography.titleSmall,
        ),
        SizedBox(height: AppSpacing.sm),
        tipsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) {
            debugPrint("HealthTips Error: $err");
            return const Text("팁을 불러올 수 없습니다.");
          },
          data: (tips) {
            if (tips.isEmpty) return const Text("등록된 팁이 없습니다.");
            final tip = tips.first;
            
            return GestureDetector(
              onTap: () {
                context.push('/health-tip/${tip.id}');
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.cardLargeRadius,
                  boxShadow: AppShadows.cardElevated,
                  image: tip.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(tip.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: tip.imageUrl == null ? AppColors.primary : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.cardLargeRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: AppSpacing.allLG,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 60), // 이미지 공간 확보
                      AppCategoryBadge(
                        label: tip.category.toUpperCase(),
                        color: Colors.white,
                        size: BadgeSize.small,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        tip.title,
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Text(
                            "자세히 보기",
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // 중단: 나의 건강 일기
  Widget _buildHealthLogSection(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(healthLogsNotifierProvider);

    return AppBaseCard(
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "나의 건강 일기",
                style: AppTypography.headingMedium,
              ),
              AppIconButton(
                onPressed: () => _showAddLogModal(context, ref),
                icon: Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          logsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) {
              debugPrint("HealthLogs Error: $err");
              return Text(
                "기록을 불러올 수 없습니다.",
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              );
            },
            data: (logs) {
              // 날짜 비교 로직 개선 (toLocal() 사용)
              final now = DateTime.now();
              final todayStr = DateFormat('yyyy-MM-dd').format(now);
              
              HealthLog? todayLog;
              try {
                todayLog = logs.firstWhere(
                  (log) => DateFormat('yyyy-MM-dd').format(log.date.toLocal()) == todayStr
                );
              } catch (_) {
                // 오늘 기록이 없으면 null
              }
              
              if (todayLog == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Text(
                          "오늘 하루는 어떠셨나요?",
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        AppPrimaryButton(
                          onPressed: () => _showAddLogModal(context, ref),
                          text: "오늘의 기분 기록하기",
                          icon: Icons.edit_note_rounded,
                          size: ButtonSize.medium,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Container(
                padding: AppSpacing.allMD,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.cardRadius,
                ),
                child: Row(
                  children: [
                    Text(
                      _getMoodEmoji(todayLog.mood),
                      style: const TextStyle(fontSize: 40),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todayLog.note != null && todayLog.note!.isNotEmpty 
                                ? todayLog.note! 
                                : "메모 없이 기록됨",
                            style: AppTypography.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            DateFormat('a h:mm', 'ko').format(todayLog.date.toLocal()),
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 하단: 건강 정보 피드
  Widget _buildHealthTipsFeed(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(healthTipsProvider());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "건강 정보",
          style: AppTypography.titleSmall,
        ),
        SizedBox(height: AppSpacing.sm),
        tipsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Text(
            "정보를 불러올 수 없습니다.",
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
          ),
          data: (tips) {
            if (tips.isEmpty) return const SizedBox();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tips.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final tip = tips[index];
                return AppBaseCard(
                  onTap: () => context.push('/health-tip/${tip.id}'),
                  padding: AppSpacing.cardPaddingAll,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppCategoryBadge(
                              label: tip.category,
                              color: AppColors.primary,
                              size: BadgeSize.small,
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              tip.title,
                              style: AppTypography.headingMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              DateFormat('MM월 dd일').format(tip.createdAt.toLocal()),
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      if (tip.imageUrl != null) ...[
                        SizedBox(width: AppSpacing.md),
                        ClipRRect(
                          borderRadius: AppRadius.thumbnailRadius,
                          child: Image.network(
                            tip.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80, 
                              height: 80, 
                              color: AppColors.surfaceVariant,
                              child: Icon(Icons.image_not_supported, color: AppColors.iconSecondary),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'GOOD': return '😊';
      case 'SOSO': return '😐';
      case 'BAD': return '😢';
      default: return '😐';
    }
  }

  void _showAddLogModal(BuildContext context, WidgetRef ref) {
    String selectedMood = 'GOOD';
    final noteController = TextEditingController();

    // 현재 오늘 기록이 있다면 초기값 세팅
    final logsAsync = ref.read(healthLogsNotifierProvider);
    logsAsync.whenData((logs) {
      try {
        final todayLog = logs.firstWhere(
          (log) => DateFormat('yyyy-MM-dd').format(log.date.toLocal()) == DateFormat('yyyy-MM-dd').format(DateTime.now())
        );
        selectedMood = todayLog.mood;
        noteController.text = todayLog.note ?? '';
      } catch (_) {}
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            Text(
              "오늘의 건강 기록",
              style: AppTypography.titleMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            Text("현재 기분은 어떠신가요?", style: AppTypography.labelMedium),
            SizedBox(height: AppSpacing.sm),
            StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMoodOption('GOOD', '😊', selectedMood, (val) => setState(() => selectedMood = val)),
                  _buildMoodOption('SOSO', '😐', selectedMood, (val) => setState(() => selectedMood = val)),
                  _buildMoodOption('BAD', '😢', selectedMood, (val) => setState(() => selectedMood = val)),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text("특이사항 (선택)", style: AppTypography.labelMedium),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: "오늘 몸 상태는 어떤가요?",
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.inputRadius,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputRadius,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.inputRadius,
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: AppSpacing.inputPaddingDefault,
              ),
              maxLines: 3,
            ),
            SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              onPressed: () async {
                await ref.read(healthLogsNotifierProvider.notifier).addLog(
                  mood: selectedMood,
                  note: noteController.text,
                );
                if (context.mounted) Navigator.pop(context);
              },
              text: "저장하기",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodOption(String mood, String emoji, String current, Function(String) onSelect) {
    final isSelected = mood == current;
    return GestureDetector(
      onTap: () => onSelect(mood),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.allMD,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            SizedBox(height: AppSpacing.xs),
            Text(
              mood, 
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
