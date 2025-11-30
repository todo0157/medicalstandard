import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/errors/app_exception.dart';
import '../../core/models/address.dart';
import '../../core/models/doctor.dart';
import '../../core/models/slot.dart';
import '../../core/services/doctor_service.dart';
import '../../shared/theme/app_colors.dart';
import '../address/screens/address_search_screen.dart';
import '../doctor/providers/doctor_providers.dart';
import 'package:go_router/go_router.dart';

const Color kBookingPrimary = Color(0xFFEC4899);
const Color kBookingPrimaryLight = Color(0xFFFCE7F3);
const Color kBookingInfoBlue = Color(0xFF2563EB);

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  ConsumerState<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState
    extends ConsumerState<AppointmentBookingScreen> {
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final DoctorService _doctorService = DoctorService();

  bool _needsMedicine = true;
  bool _loadingDoctors = true;
  bool _loadingSlots = false;
  bool _booking = false;
  String? _error;

  List<Doctor> _doctors = [];
  Doctor? _selectedDoctor;
  List<Slot> _slots = [];
  Slot? _selectedSlot;
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isReady => _selectedDoctor != null && _selectedSlot != null;

  Future<void> _loadDoctors() async {
    setState(() {
      _loadingDoctors = true;
      _error = null;
    });
    try {
      final doctors = await _doctorService.searchDoctors();
      setState(() {
        _doctors = doctors;
        _selectedDoctor = doctors.isEmpty ? null : doctors.first;
      });
      if (doctors.isNotEmpty) {
        await _loadSlots(doctors.first.id);
      } else {
        setState(() => _slots = []);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = '의사 목록을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingDoctors = false;
        });
      }
    }
  }

  Future<void> _loadSlots(String doctorId) async {
    setState(() {
      _loadingSlots = true;
      _selectedSlot = null;
      _error = null;
    });
    try {
      final slots = await _doctorService.getSlots(doctorId);
      if (!mounted) return;
      setState(() {
        _slots = slots;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '예약 가능한 시간을 불러오지 못했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingSlots = false;
        });
      }
    }
  }

  Future<void> _bookAppointment() async {
    if (!_isReady || _selectedDoctor == null || _selectedSlot == null) return;
    setState(() {
      _booking = true;
      _error = null;
    });

    final notes = _composeNotes();
    final notifier = ref.read(appointmentsNotifierProvider.notifier);

    try {
      await notifier.book(
        doctorId: _selectedDoctor!.id,
        slotId: _selectedSlot!.id,
        notes: notes.isEmpty ? null : notes,
      );
      if (!mounted) return;
      _showConfirmationSheet();
    } catch (error) {
      final message = error is AppException
          ? error.message
          : '예약에 실패했습니다. 네트워크 상태를 확인해 주세요.';
      setState(() {
        _error = message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _booking = false;
        });
      }
    }
  }

  String _composeNotes() {
    final buffer = <String>[];
    if (_symptomController.text.trim().isNotEmpty) {
      buffer.add('증상: ${_symptomController.text.trim()}');
    }
    if (_noteController.text.trim().isNotEmpty) {
      buffer.add('요청사항: ${_noteController.text.trim()}');
    }
    if (_needsMedicine) {
      buffer.add('한약 처방 요청');
    }
    return buffer.join('\n');
  }

  void _onDoctorSelected(Doctor doctor) {
    setState(() {
      _selectedDoctor = doctor;
      _selectedSlot = null;
    });
    _loadSlots(doctor.id);
  }

  void _onSlotSelected(Slot slot) {
    setState(() {
      _selectedSlot = slot;
    });
  }

  Future<void> _selectAddress() async {
    final address = await context.push<Address>('/address/search');
    if (address != null && mounted) {
      setState(() {
        _selectedAddress = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('M월 d일 (E) a h:mm', 'ko');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadDoctors,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookingHeroCard(
                address: _selectedAddress,
                onChangeAddress: _selectAddress,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('담당 한의사를 선택해 주세요'),
              const SizedBox(height: 12),
              if (_loadingDoctors)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: kBookingPrimary),
                  ),
                )
              else if (_doctors.isEmpty)
                _EmptyPlaceholder(
                  message: '예약 가능한 한의사가 없습니다.',
                  actionLabel: '새로고침',
                  onAction: _loadDoctors,
                )
              else
                _DoctorSelector(
                  doctors: _doctors,
                  selectedDoctor: _selectedDoctor,
                  onSelected: _onDoctorSelected,
                ),
              const SizedBox(height: 24),
              _buildSectionTitle('예약 가능한 시간'),
              const SizedBox(height: 12),
              if (_loadingSlots)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: kBookingPrimary),
                  ),
                )
              else if (_slots.isEmpty)
                const _EmptyPlaceholder(
                  message: '예약 가능한 시간이 없습니다. 다른 한의사를 선택해 주세요.',
                )
              else
                _SlotSelector(
                  slots: _slots,
                  formatter: formatter,
                  selectedSlot: _selectedSlot,
                  onSelected: _onSlotSelected,
                ),
              const SizedBox(height: 24),
              _buildSectionTitle('증상 및 요청사항'),
              const SizedBox(height: 12),
              _SymptomField(
                controller: _symptomController,
                hint: '예) 3일 전부터 어깨가 뻐근하고 움직이기 힘들어요',
              ),
              const SizedBox(height: 12),
              _SymptomField(
                controller: _noteController,
                hint: '의사에게 전달하고 싶은 내용을 입력하세요',
                label: '추가 요청 (선택)',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _MedicineSwitch(
                needsMedicine: _needsMedicine,
                onChanged: (value) {
                  setState(() {
                    _needsMedicine = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              const _SummaryCard(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomActionBar(
        isEnabled: _isReady && !_booking,
        isLoading: _booking,
        onPressed: _bookAppointment,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.iconPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.divider),
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

  void _showConfirmationSheet() {
    final doctor = _selectedDoctor!;
    final slot = _selectedSlot!;
    final dateLabel = DateFormat('M월 d일 (E) a h:mm', 'ko')
        .format(slot.startsAt.toLocal());

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                child: const Icon(Icons.check, color: kBookingPrimary, size: 32),
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
                '$dateLabel\n${doctor.name} · ${doctor.specialty}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
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
      ),
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

class _DoctorSelector extends StatelessWidget {
  const _DoctorSelector({
    required this.doctors,
    required this.selectedDoctor,
    required this.onSelected,
  });

  final List<Doctor> doctors;
  final Doctor? selectedDoctor;
  final ValueChanged<Doctor> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: doctors
          .map(
            (doctor) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onSelected(doctor),
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: doctor.id == selectedDoctor?.id
                          ? kBookingPrimary
                          : AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.surfaceVariant,
                        child: Text(
                          doctor.name.isNotEmpty ? doctor.name[0] : '?',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.specialty,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              doctor.clinicName,
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: doctor.id == selectedDoctor?.id
                            ? kBookingPrimary
                            : AppColors.border,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SlotSelector extends StatelessWidget {
  const _SlotSelector({
    required this.slots,
    required this.formatter,
    required this.selectedSlot,
    required this.onSelected,
  });

  final List<Slot> slots;
  final DateFormat formatter;
  final Slot? selectedSlot;
  final ValueChanged<Slot> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: slots
          .map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: slot.id == selectedSlot?.id
                        ? kBookingPrimary
                        : AppColors.border,
                  ),
                ),
                title: Text(
                  formatter.format(slot.startsAt.toLocal()),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${formatter.format(slot.startsAt.toLocal())} - '
                  '${formatter.format(slot.endsAt.toLocal())}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                trailing: Radio<Slot>(
                  value: slot,
                  groupValue: selectedSlot,
                  activeColor: kBookingPrimary,
                  onChanged: (_) => onSelected(slot),
                ),
                onTap: () => onSelected(slot),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SymptomField extends StatelessWidget {
  const _SymptomField({
    required this.controller,
    required this.hint,
    this.label,
    this.maxLines = 4,
  });

  final TextEditingController controller;
  final String? label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? '증상 설명',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
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
        ),
      ],
    );
  }
}

class _MedicineSwitch extends StatelessWidget {
  const _MedicineSwitch({
    required this.needsMedicine,
    required this.onChanged,
  });

  final bool needsMedicine;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
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
            value: needsMedicine,
            onChanged: onChanged,
            activeThumbColor: kBookingPrimary,
            activeTrackColor: kBookingPrimary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel ?? '새로고침'),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isEnabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBookingPrimary,
                disabledBackgroundColor: kBookingPrimary.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
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
      ),
    );
  }
}

class _BookingHeroCard extends StatelessWidget {
  const _BookingHeroCard({
    required this.onChangeAddress,
    this.address,
  });

  final VoidCallback onChangeAddress;
  final Address? address;

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
          if (address != null) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address!.roadAddress.isNotEmpty
                      ? address!.roadAddress
                      : address!.jibunAddress,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (address!.detailAddress != null &&
                    address!.detailAddress!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    address!.detailAddress!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Text(
              '주소를 선택해주세요',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
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
