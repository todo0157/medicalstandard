import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/health_tip.dart';
import '../../../core/models/health_log.dart';
import '../providers/life_providers.dart';

const Color kPrimaryPink = Color(0xFFEC4899);
const Color kPrimaryBlue = Color(0xFF3B82F6);
const Color kGrayText = Color(0xFF6B7280);
const Color kDarkGray = Color(0xFF1F2937);

class LifeScreen extends ConsumerWidget {
  const LifeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodayTip(context, ref),
            const SizedBox(height: 24),
            _buildHealthLogSection(context, ref),
            const SizedBox(height: 24),
            _buildHealthTipsFeed(context, ref),
          ],
        ),
      ),
    );
  }

  // 상단: 오늘의 한방 팁 카드
  Widget _buildTodayTip(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(healthTipsProvider());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "오늘의 한방 팁",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kDarkGray,
          ),
        ),
        const SizedBox(height: 12),
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
                  borderRadius: BorderRadius.circular(16),
                  image: tip.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(tip.imageUrl!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.3),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                  color: tip.imageUrl == null ? kPrimaryBlue : null,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tip.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tip.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "자세히 보기 >",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryPink.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "나의 건강 일기",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kDarkGray,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: kPrimaryPink),
                onPressed: () => _showAddLogModal(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 8),
          logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) {
              debugPrint("HealthLogs Error: $err");
              return const Text("기록을 불러올 수 없습니다.");
            },
            data: (logs) {
              if (logs.isEmpty) {
                return const Text(
                  "오늘의 기분과 상태를 기록해보세요!",
                  style: TextStyle(color: kGrayText, fontSize: 14),
                );
              }
              
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
                return const Text(
                  "오늘의 기록이 없습니다. 기록을 추가해보세요!",
                  style: TextStyle(color: kGrayText, fontSize: 14),
                );
              }
              
              return Row(
                children: [
                  Text(
                    _getMoodEmoji(todayLog.mood),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayLog.note != null && todayLog.note!.isNotEmpty 
                              ? todayLog.note! 
                              : "메모 없이 기록됨",
                          style: const TextStyle(
                            fontSize: 14,
                            color: kDarkGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormat('yyyy년 MM월 dd일').format(todayLog.date.toLocal()),
                          style: const TextStyle(
                            fontSize: 12,
                            color: kGrayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
        const Text(
          "건강 정보",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kDarkGray,
          ),
        ),
        const SizedBox(height: 12),
        tipsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Text("정보를 불러올 수 없습니다."),
          data: (tips) {
            if (tips.isEmpty) return const SizedBox();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tips.length,
              separatorBuilder: (_, __) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final tip = tips[index];
                return InkWell(
                  onTap: () {
                    context.push('/health-tip/${tip.id}');
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.category,
                              style: const TextStyle(
                                color: kPrimaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kDarkGray,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MM월 dd일').format(tip.createdAt.toLocal()),
                              style: const TextStyle(
                                color: kGrayText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (tip.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tip.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80, height: 80, color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          ),
                        ),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "오늘의 건강 기록",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text("현재 기분은 어떠신가요?", style: TextStyle(color: kGrayText)),
            const SizedBox(height: 12),
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
            const SizedBox(height: 24),
            const Text("특이사항 (선택)", style: TextStyle(color: kGrayText)),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                hintText: "오늘 몸 상태는 어떤가요?",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ref.read(healthLogsNotifierProvider.notifier).addLog(
                  mood: selectedMood,
                  note: noteController.text,
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryPink,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Text("저장하기"),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodOption(String mood, String emoji, String current, Function(String) onSelect) {
    final isSelected = mood == current;
    return GestureDetector(
      onTap: () => onSelect(mood),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryPink.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? kPrimaryPink : Colors.transparent),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 4),
            Text(mood, style: TextStyle(
              color: isSelected ? kPrimaryPink : kGrayText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }
}
