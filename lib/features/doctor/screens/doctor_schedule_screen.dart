import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../core/models/slot.dart';
import '../../../core/services/auth_session.dart';
import '../../../core/config/app_config.dart';

const Color kPrimaryPink = Color(0xFFEC4899);
const Color kPrimaryBlue = Color(0xFF3B82F6);
const Color kGrayText = Color(0xFF6B7280);
const Color kDarkGray = Color(0xFF1F2937);

// Slot 서비스 Provider
final doctorSlotsProvider = FutureProvider.autoDispose<List<Slot>>((ref) async {
  final token = AuthSession.instance.token;
  if (token == null) {
    throw Exception('인증이 필요합니다.');
  }

  final response = await http.get(
    Uri.parse('${AppConfig.apiBaseUrl}/doctors/my/slots'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List;
    return data.map((item) => Slot.fromJson(item as Map<String, dynamic>)).toList();
  } else {
    throw Exception('슬롯을 불러올 수 없습니다.');
  }
});

class DoctorScheduleScreen extends ConsumerStatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  ConsumerState<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends ConsumerState<DoctorScheduleScreen> {
  // 요일별 선택 (0=월요일, 6=일요일)
  final Set<int> _selectedDays = {};
  
  // 시간대 목록 (30분 단위)
  final List<String> _timeSlots = [];
  
  // 선택된 시간대
  String? _selectedStartTime;
  String? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
  }

  void _generateTimeSlots() {
    _timeSlots.clear();
    for (int hour = 9; hour <= 18; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final time = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        _timeSlots.add(time);
      }
    }
  }

  String _getDayName(int dayIndex) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[dayIndex];
  }

  Future<void> _createWeeklySlots() async {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('요일을 선택해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedStartTime == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('시작 시간과 종료 시간을 선택해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final startParts = _selectedStartTime!.split(':');
    final endParts = _selectedEndTime!.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);

    if (endHour < startHour || (endHour == startHour && endMinute <= startMinute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('종료 시간은 시작 시간보다 늦어야 합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final token = AuthSession.instance.token;
      if (token == null) {
        throw Exception('인증이 필요합니다.');
      }

      // 오늘부터 4주 동안의 슬롯 생성
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 28));
      int createdCount = 0;

      for (var date = now; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
        // 선택된 요일인지 확인 (월요일=1, 일요일=7)
        final weekday = date.weekday; // 1=월요일, 7=일요일
        final dayIndex = weekday - 1; // 0=월요일, 6=일요일

        if (_selectedDays.contains(dayIndex)) {
          final startsAt = DateTime(
            date.year,
            date.month,
            date.day,
            startHour,
            startMinute,
          );

          final endsAt = DateTime(
            date.year,
            date.month,
            date.day,
            endHour,
            endMinute,
          );

          try {
            final response = await http.post(
              Uri.parse('${AppConfig.apiBaseUrl}/doctors/my/slots'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'startsAt': startsAt.toUtc().toIso8601String(),
                'endsAt': endsAt.toUtc().toIso8601String(),
              }),
            );

            if (response.statusCode == 201) {
              createdCount++;
            }
          } catch (e) {
            // 개별 슬롯 생성 실패는 무시하고 계속 진행
            continue;
          }
        }
      }

      if (createdCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$createdCount개의 진료 가능 시간이 등록되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(doctorSlotsProvider);
        setState(() {
          _selectedDays.clear();
          _selectedStartTime = null;
          _selectedEndTime = null;
        });
      } else {
        throw Exception('슬롯 생성에 실패했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    try {
      final token = AuthSession.instance.token;
      if (token == null) {
        throw Exception('인증이 필요합니다.');
      }

      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}/doctors/my/slots/$slotId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('진료 가능 시간이 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(doctorSlotsProvider);
      } else {
        throw Exception('슬롯 삭제에 실패했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(doctorSlotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '진료 가능 시간 관리',
          style: TextStyle(color: kDarkGray, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: kPrimaryBlue.withValues(alpha: 0.1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 요일별 시간대 설정 섹션
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '요일별 진료 가능 시간 설정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kDarkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '선택한 요일에 대해 향후 4주 동안의 시간대가 자동으로 생성됩니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: kGrayText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 요일 선택
                  const Text(
                    '요일 선택',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kDarkGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final isSelected = _selectedDays.contains(index);
                      return FilterChip(
                        label: Text(_getDayName(index)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(index);
                            } else {
                              _selectedDays.remove(index);
                            }
                          });
                        },
                        selectedColor: kPrimaryBlue.withValues(alpha: 0.2),
                        checkmarkColor: kPrimaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? kPrimaryBlue : kDarkGray,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? kPrimaryBlue : kGrayText.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // 시간 선택
                  const Text(
                    '시간 선택',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kDarkGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStartTime,
                          decoration: InputDecoration(
                            labelText: '시작 시간',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: _timeSlots.map((time) {
                            return DropdownMenuItem(
                              value: time,
                              child: Text(time),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStartTime = value;
                              // 종료 시간이 시작 시간보다 이전이면 초기화
                              if (_selectedEndTime != null && value != null) {
                                final startParts = value.split(':');
                                final endParts = _selectedEndTime!.split(':');
                                final startHour = int.parse(startParts[0]);
                                final startMinute = int.parse(startParts[1]);
                                final endHour = int.parse(endParts[0]);
                                final endMinute = int.parse(endParts[1]);
                                
                                if (endHour < startHour || (endHour == startHour && endMinute <= startMinute)) {
                                  _selectedEndTime = null;
                                }
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedEndTime,
                          decoration: InputDecoration(
                            labelText: '종료 시간',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: _timeSlots.where((time) {
                            if (_selectedStartTime == null) return true;
                            final startParts = _selectedStartTime!.split(':');
                            final timeParts = time.split(':');
                            final startHour = int.parse(startParts[0]);
                            final startMinute = int.parse(startParts[1]);
                            final timeHour = int.parse(timeParts[0]);
                            final timeMinute = int.parse(timeParts[1]);
                            
                            return timeHour > startHour || (timeHour == startHour && timeMinute > startMinute);
                          }).map((time) {
                            return DropdownMenuItem(
                              value: time,
                              child: Text(time),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedEndTime = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _createWeeklySlots,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '진료 가능 시간 등록',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 등록된 시간 목록
            const Text(
              '등록된 진료 가능 시간',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kDarkGray,
              ),
            ),
            const SizedBox(height: 16),
            slotsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('오류: ${error.toString()}'),
              ),
              data: (slots) {
                if (slots.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kGrayText.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.schedule, size: 48, color: kGrayText.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          '등록된 진료 가능 시간이 없습니다.',
                          style: TextStyle(color: kGrayText),
                        ),
                      ],
                    ),
                  );
                }

                // 날짜별로 그룹화
                final groupedSlots = <String, List<Slot>>{};
                for (final slot in slots) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(slot.startsAt.toLocal());
                  groupedSlots.putIfAbsent(dateKey, () => []).add(slot);
                }

                return Column(
                  children: groupedSlots.entries.map((entry) {
                    final date = DateTime.parse(entry.key);
                    final daySlots = entry.value;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kPrimaryBlue.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(date),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kDarkGray,
                              ),
                            ),
                          ),
                          ...daySlots.map((slot) {
                            final startsAt = slot.startsAt.toLocal();
                            final endsAt = slot.endsAt.toLocal();
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: kGrayText.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    slot.isBooked ? Icons.check_circle : Icons.schedule,
                                    color: slot.isBooked ? Colors.green : kPrimaryBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${DateFormat('HH:mm').format(startsAt)} - ${DateFormat('HH:mm').format(endsAt)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: slot.isBooked ? Colors.green : kDarkGray,
                                        fontWeight: slot.isBooked ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (slot.isBooked)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '예약됨',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  else
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('삭제 확인'),
                                            content: const Text('이 진료 가능 시간을 삭제하시겠습니까?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('취소'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteSlot(slot.id);
                                                },
                                                child: const Text('삭제', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
