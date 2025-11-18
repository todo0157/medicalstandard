import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/theme/app_colors.dart';

const Color kBookingPrimary = Color(0xFFEC4899);
const Color kBookingPrimaryLight = Color(0xFFFCE7F3);
const Color kBookingInfoBlue = Color(0xFF2563EB);

/// 방문 진료 예약 화면 (참고: reference_htmlcode/9쪽_예약하기.html)
class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final List<DateTime> _dates = List.generate(
    10,
    (index) => DateTime.now().add(Duration(days: index)),
  );
  final List<String> _timeSlots = const [
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  final List<String> _symptomOptions = const [
    '근골격 통증',
    '감기 / 미열',
    '피부 컨디션',
    '소화 불편',
    '마음 건강',
    '기타',
  ];

  DateTime? _selectedDate;
  String? _selectedTime;
  String _visitType = 'home';
  bool _needsMedicine = true;

  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool get _isFormValid => _selectedDate != null && _selectedTime != null;

  @override
  void dispose() {
    _symptomController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: const Text(
          '예약하기',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.iconPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_horiz, color: AppColors.iconPrimary),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookingHeroCard(
              onChangeAddress: () {
                _showSnack('주소 변경 기능은 준비 중입니다');
              },
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('언제 방문할까요?'),
            const SizedBox(height: 12),
            _buildDateSelector(),
            const SizedBox(height: 12),
            _buildTimeSelector(),
            const SizedBox(height: 24),
            _buildSectionTitle('방문 형태'),
            const SizedBox(height: 12),
            _buildVisitTypeSelector(),
            const SizedBox(height: 24),
            _buildSectionTitle('증상 선택'),
            const SizedBox(height: 12),
            _buildSymptomOptions(),
            const SizedBox(height: 16),
            _buildSectionTitle('증상 설명'),
            const SizedBox(height: 12),
            _buildMultilineField(
              controller: _symptomController,
              hint: '예) 3일 전부터 어깨가 뻐근하고 움직이기 힘들어요',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('요청사항 (선택)'),
            const SizedBox(height: 12),
            _buildMultilineField(
              controller: _noteController,
              hint: '의사에게 전달하고 싶은 내용을 입력하세요',
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _buildNeedsMedicineSwitch(),
            const SizedBox(height: 20),
            const _SummaryCard(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid ? _showConfirmationSheet : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBookingPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: kBookingPrimary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    child: const Text(
                      '예약하기',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _BottomNavIcon(
                      label: '홈',
                      icon: Icons.home,
                      selected: true,
                    ),
                    _BottomNavIcon(label: '상황', icon: Icons.pin_drop_outlined),
                    _BottomNavIcon(
                      label: '채팅',
                      icon: Icons.chat_bubble_outline,
                    ),
                    _BottomNavIcon(label: '프로필', icon: Icons.person_outline),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDateSelector() {
    final dateFormat = DateFormat('M월 d일');
    final dayFormat = DateFormat.E('ko_KR');

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected =
              _selectedDate != null && DateUtils.isSameDay(_selectedDate, date);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? kBookingPrimary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? kBookingPrimary : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayFormat.format(date),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateFormat.format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _timeSlots.map((slot) {
        final isSelected = _selectedTime == slot;
        return ChoiceChip(
          label: Text(slot),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              _selectedTime = slot;
            });
          },
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: kBookingPrimary,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? kBookingPrimary : AppColors.border,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVisitTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _VisitTypeCard(
            title: '방문 진료',
            subtitle: '의사가 집으로 방문합니다',
            icon: Icons.home_outlined,
            isSelected: _visitType == 'home',
            onTap: () {
              setState(() {
                _visitType = 'home';
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VisitTypeCard(
            title: '원격 상담',
            subtitle: '영상으로 빠르게 상담',
            icon: Icons.videocam_outlined,
            isSelected: _visitType == 'remote',
            onTap: () {
              setState(() {
                _visitType = 'remote';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomOptions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _symptomOptions.map((option) {
        final isSelected = _symptomController.text == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? kBookingPrimary : AppColors.border,
            ),
          ),
          backgroundColor: Colors.white,
          selectedColor: kBookingPrimaryLight,
          labelStyle: TextStyle(
            color: isSelected ? kBookingPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) {
            setState(() {
              _symptomController.text = option;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildMultilineField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 4,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kBookingPrimary, width: 2),
        ),
      ),
    );
  }

  Widget _buildNeedsMedicineSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_pharmacy_outlined, color: kBookingPrimary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '진료 후 한약 처방이 필요해요',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: _needsMedicine,
            onChanged: (value) {
              setState(() {
                _needsMedicine = value;
              });
            },
            activeThumbColor: kBookingPrimary,
            activeTrackColor: kBookingPrimary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  void _showConfirmationSheet() {
    final readableDate = DateFormat(
      'M월 d일 (E)',
      'ko_KR',
    ).format(_selectedDate!);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: kBookingPrimaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: kBookingPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '예약이 완료되었어요!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$readableDate $_selectedTime • ${_visitType == 'home' ? '방문 진료' : '원격 상담'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close sheet
                      Navigator.of(context).pop(); // go back
                      _showSnack('마이페이지에서 예약 내역을 확인하세요');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBookingPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }
}

class _BookingHeroCard extends StatelessWidget {
  const _BookingHeroCard({required this.onChangeAddress});

  final VoidCallback onChangeAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBookingPrimaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.home_filled,
                  color: kBookingPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  '방문 진료 예약',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onChangeAddress,
                style: TextButton.styleFrom(
                  foregroundColor: kBookingPrimary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('주소 변경'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '서울특별시 성동구 왕십리로 16\n101동 1203호',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: kBookingInfoBlue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '방문진료비는 별도 안내되며, 안전한 진료를 위해 상태를 정확히 입력해주세요.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
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

class _VisitTypeCard extends StatelessWidget {
  const _VisitTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isSelected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? kBookingPrimaryLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kBookingPrimary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? kBookingPrimary : AppColors.iconPrimary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '진료 비용',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₩45,000',
                style: TextStyle(
                  color: kBookingPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          const Text(
            '• 방문 진료 기본 비용 포함\n• 보험 청구는 진료 후 진행됩니다\n• 추가 검사가 필요한 경우 비용이 달라질 수 있어요',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  const _BottomNavIcon({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: selected ? kBookingPrimary : AppColors.textHint),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? kBookingPrimary : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
