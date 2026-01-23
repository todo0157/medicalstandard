import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../doctor/providers/doctor_providers.dart';
import '../../life/screens/life_screen.dart'; // 추가
import '../../../core/models/address.dart';
import '../../../core/models/doctor.dart';
import '../../../core/providers/ui_mode_provider.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/models/user_profile.dart';

// 디자인 시스템 import (Phase 1)
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/widgets/common_button.dart';
import '../../../shared/widgets/common_card.dart';
import '../../../shared/widgets/common_badge.dart';

// 4쪽&7쪽_대표 화면 설명&초기 화면.html의 Primary Color (#ec4899) 반영
const Color kPrimaryPink = Color(0xFFEC4899);
const Color kPrimaryBlue = Color(0xFF3B82F6);
const Color kGrayText = Color(0xFF6B7280);
const Color kDarkGray = Color(0xFF1F2937);

// 메인 탭 구조 (하단 탭 바)
class MainAppShellScreen extends ConsumerStatefulWidget {
  const MainAppShellScreen({super.key});

  @override
  ConsumerState<MainAppShellScreen> createState() => _MainAppShellScreenState();
}

class _MainAppShellScreenState extends ConsumerState<MainAppShellScreen> {
  int _selectedIndex = 0; // 0: 홈, 1: 생활, 2: 채팅, 3: 프로필

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Build the appropriate widget for the selected tab
  Widget _getBodyWidget(int index) {
    final uiMode = ref.watch(uiModeProvider);
    
    switch (index) {
      case 0:
        return const HomeScreen(); // 홈 탭 (방문 진료 예약 또는 한의사 전용)
      case 1:
        return const LifeScreen(); // 생활 탭 (교체됨)
      case 2:
        // 채팅 목록 화면 표시
        return const ChatListScreen();
      case 3:
        return const ProfileScreen(); // 프로필 탭
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiMode = ref.watch(uiModeProvider);
    final profileState = ref.watch(profileStateNotifierProvider);
    
    // UI 모드에 따라 AppBar 제목 변경
    String appBarTitle = "방문 진료";
    if (_selectedIndex == 0) {
      appBarTitle = uiMode == UIMode.practitioner ? "한의사 대시보드" : "방문 진료";
    } else if (_selectedIndex == 1) {
      appBarTitle = "건강 생활";
    } else if (_selectedIndex == 2) {
      appBarTitle = "채팅";
    } else if (_selectedIndex == 3) {
      appBarTitle = "프로필";
    }
    
    // AppBar leading 버튼 결정
    Widget? leadingButton;
    if (_selectedIndex == 0 && uiMode == UIMode.patient) {
      // 환자 모드: 한의사 전용 버튼
      leadingButton = IconButton(
        icon: const Icon(Icons.local_hospital, color: kPrimaryPink),
        tooltip: '한의사 전용',
        onPressed: () {
          final profile = profileState.asData?.value;
          if (profile != null &&
              profile.certificationStatus == CertificationStatus.verified &&
              profile.isPractitioner) {
            // 한의사 인증 완료된 경우 한의사 모드로 전환
            ref.read(uiModeProvider.notifier).switchToPractitioner();
          } else {
            // 한의사 인증 안 된 경우 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('프로필에서 한의사 인증을 완료해주세요'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      );
    } else if (_selectedIndex == 0 && uiMode == UIMode.practitioner) {
      // 한의사 모드: 환자 전용 버튼
      leadingButton = IconButton(
        icon: const Icon(Icons.person, color: kPrimaryPink),
        tooltip: '환자 전용',
        onPressed: () {
          ref.read(uiModeProvider.notifier).switchToPatient();
        },
      );
    } else {
      // 다른 탭: 기본 메뉴 버튼
      leadingButton = IconButton(
        icon: const Icon(Icons.menu, color: kPrimaryPink),
        onPressed: () {},
      );
    }
    
    return Scaffold(
      // App Bar (HTML 헤더 반영)
      appBar: AppBar(
        leading: leadingButton,
        title: Text(
          appBarTitle,
          style: const TextStyle(
            color: kDarkGray,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: kPrimaryPink),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: kPrimaryPink.withValues(alpha: 0.1),
      ),

      body: _getBodyWidget(_selectedIndex),

      // 하단 탭 바
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: '생활',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryPink,
        unselectedItemColor: const Color(0xFF9CA3AF),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        showUnselectedLabels: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: null,
    );
  }
}

// Patient 클래스
class Patient {
  final String id;
  final String name;
  final String imageUrl;
  final Color color;

  Patient({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
  });
}

// HomeScreen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Patient> _patients = [
    Patient(
      id: "me",
      name: "나",
      imageUrl:
          "https://readdy.ai/api/search-image?query=Professional%20young%20Korean%20man%20in%20casual%20clothes%2C%20friendly%20smile%2C%20clean%20background%2C%20portrait%20photography%2C%20soft%20lighting%2C%20natural%20expression%2C%20modern%20style&width=64&height=64&seq=patient_me&orientation=squarish",
      color: kPrimaryPink,
    ),
  ];

  String _selectedPatientId = "me";
  bool _symptomsVisible = false;
  DateTime? _selectedDate;
  String? _selectedSymptom;
  Address? _selectedAddress;
  Doctor? _selectedDoctor;

  Widget _buildSelectionButton(String text, IconData icon) {
    bool isPlaceholder = text.contains("선택") || text.contains("입력");

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isPlaceholder
                  ? kPrimaryBlue.withValues(alpha: 0.8)
                  : kDarkGray,
              fontSize: 15,
              fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          Icon(icon, color: kPrimaryBlue.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  Widget _buildAddressButton(Address? address) {
    final bool isPlaceholder = address == null;
    final String displayText = address == null
        ? "주소를 입력해주세요"
        : (address.roadAddress.isNotEmpty
            ? address.roadAddress
            : address.jibunAddress);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kPrimaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: TextStyle(
                    color: isPlaceholder
                        ? kPrimaryBlue.withValues(alpha: 0.8)
                        : kDarkGray,
                    fontSize: 15,
                    fontWeight:
                        isPlaceholder ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
                if (address?.detailAddress != null &&
                    address!.detailAddress!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    address.detailAddress!,
                    style: TextStyle(
                      color: kDarkGray,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.place_outlined,
              color: kPrimaryBlue.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  Widget _buildPatientSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "누가 진료를 받을까요?",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kDarkGray,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: kPrimaryPink.withValues(alpha: 0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ..._patients.map(
                (patient) => Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: _buildPatientOption(patient),
                ),
              ),
              _buildAddPatientButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientOption(Patient patient) {
    bool isSelected = _selectedPatientId == patient.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPatientId = patient.id;
        });
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: patient.color, width: 4)
                  : null,
              color: patient.color.withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                patient.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  patient.id == "me" ? Icons.person : Icons.elderly,
                  color: patient.color,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            patient.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: patient.color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPatientButton() {
    return GestureDetector(
      onTap: () {
        _showAddPatientModal(context);
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kPrimaryBlue.withValues(alpha: 0.6),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(
              Icons.add,
              color: kPrimaryBlue.withValues(alpha: 0.8),
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "추가",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: kPrimaryBlue.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPatientModal(BuildContext context) {
    final List<Patient> addOptions = [
      Patient(
        id: "mother",
        name: "어머니",
        imageUrl:
            "https://readdy.ai/api/search-image?query=Kind%20middle%20aged%20Korean%20mother%20with%20warm%20smile%2C%20gentle%20expression%2C%20casual%20clothes%2C%20soft%20lighting%2C%20portrait%20photography%2C%20clean%20background&width=80&height=80&seq=patient_mother&orientation=squarish",
        color: kPrimaryBlue,
      ),
      Patient(
        id: "child",
        name: "자녀",
        imageUrl:
            "https://readdy.ai/api/search-image?query=Cute%20Korean%20child%20with%20bright%20smile%2C%20happy%20expression%2C%20casual%20clothes%2C%20soft%20lighting%2C%20portrait%20photography%2C%20clean%20background&width=80&height=80&seq=patient_child&orientation=squarish",
        color: kPrimaryBlue,
      ),
      Patient(
        id: "grandfather",
        name: "할아버지",
        imageUrl:
            "https://readdy.ai/api/search-image?query=Kind%20elderly%20Korean%20grandfather%20with%20gentle%20smile%2C%20warm%20expression%2C%20traditional%20Korean%20style%2C%20soft%20lighting%2C%20portrait%20photography%2C%20clean%20background&width=80&height=80&seq=patient_grandfather&orientation=squarish",
        color: kPrimaryBlue,
      ),
      Patient(
        id: "spouse",
        name: "배우자",
        imageUrl:
            "https://readdy.ai/api/search-image?query=Professional%20Korean%20spouse%20with%20friendly%20smile%2C%20kind%20expression%2C%20casual%20clothes%2C%20soft%20lighting%2C%20portrait%20photography%2C%20clean%20background&width=80&height=80&seq=patient_spouse&orientation=squarish",
        color: kPrimaryBlue,
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext sheetContext) {
        final double bottomPadding = MediaQuery.of(
          sheetContext,
        ).viewInsets.bottom;

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "환자 추가",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kDarkGray,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: kGrayText),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: addOptions.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final patient = addOptions[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!_patients.any((p) => p.id == patient.id)) {
                              _patients.add(patient);
                              _selectedPatientId = patient.id;
                            }
                          });
                          Navigator.of(sheetContext).pop();
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: kPrimaryBlue.withValues(alpha: 0.1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  patient.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.person_add_alt_1_outlined,
                                        color: kPrimaryBlue,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              patient.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: kDarkGray,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryPink,
              onPrimary: Colors.white,
              onSurface: kDarkGray,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kPrimaryPink),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildSymptomSelection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _symptomsVisible = !_symptomsVisible;
            });
          },
          child: _buildSelectionButton(
            _selectedSymptom ?? "증상을 선택해주세요",
            _symptomsVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          ),
        ),
        if (_symptomsVisible)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.only(top: 12),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildSymptomOption(
                  "근골격계",
                  "https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20bone%20and%20joint%20symbol%20with%20gentle%20care%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame%2C%20warm%20blue%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus&width=48&height=48&seq=symptom_musculoskeletal_blue&orientation=squarish",
                ),
                _buildSymptomOption(
                  "감기",
                  "https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20medical%20thermometer%20and%20tissue%20box%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame%2C%20warm%20blue%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus&width=48&height=48&seq=symptom_cold_blue&orientation=squarish",
                ),
                _buildSymptomOption(
                  "두통",
                  "https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20head%20with%20gentle%20pain%20relief%20symbol%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame%2C%20warm%20blue%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus&width=48&height=48&seq=symptom_headache_blue&orientation=squarish",
                ),
                _buildSymptomOption(
                  "기타",
                  "https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20medical%20stethoscope%20and%20health%20check%20symbol%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame%2C%20warm%20blue%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus&width=48&height=48&seq=symptom_other_blue&orientation=squarish",
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSymptomOption(String label, String imageUrl) {
    bool isSelected = _selectedSymptom == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSymptom = label;
          _symptomsVisible = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? kPrimaryBlue.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? kPrimaryBlue
                : kPrimaryBlue.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.healing_outlined, color: kPrimaryBlue),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: kDarkGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // Phase 1 개선: 새로운 UI 메서드들
  // ========================================

  /// 상단 브랜딩 헤더 (하니비 로고 + 환영 메시지)
  Widget _buildBrandingHeader(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileStateNotifierProvider);
    final userName = profileState.maybeWhen(
      data: (profile) => profile.name,
      orElse: () => '사용자',
    );

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: AppRadius.cardLargeRadius,
        boxShadow: AppShadows.brandShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 하니비 로고
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                '하니비',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // 환영 메시지
          Text(
            '안녕하세요, ${userName}님',
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            '오늘 어떤 도움이 필요하신가요?',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// 메인 서비스 카드 (방문진료)
  Widget _buildMainServiceCard(BuildContext context) {
    return AppGradientCard(
      gradient: AppColors.brandGradient,
      padding: EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.cardLargeRadius,
      shadow: true,
      onTap: () async {
        // 기존 "한의사 찾기" 버튼과 동일한 로직
        final doctor = await context.push<Doctor>('/find-doctor');
        if (doctor != null && mounted) {
          setState(() {
            _selectedDoctor = doctor;
            if (doctor.clinicLat != null && doctor.clinicLng != null) {
              _selectedAddress = Address(
                roadAddress: doctor.clinicName,
                jibunAddress: doctor.clinicName,
                x: doctor.clinicLng ?? 0,
                y: doctor.clinicLat ?? 0,
                distance: doctor.distanceKm ?? 0,
                addressElements: [],
              );
            }
          });
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 배지
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: AppRadius.badgeSmallRadius,
                  ),
                  child: Text(
                    '방문 진료',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                // 제목
                Text(
                  '방문 진료\n한의사',
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                // 설명
                Text(
                  '한의사 방문진료 예약하기',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                // 버튼
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.buttonRadius,
                  ),
                  child: Text(
                    '예약하기',
                    style: AppTypography.button.copyWith(
                      color: AppColors.brandOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 일러스트 이미지
          SizedBox(
            width: 80,
            height: 80,
            child: Image.network(
              'https://readdy.ai/api/search-image?query=Professional%20doctor%20character%20illustration%2C%20friendly%20male%20doctor%20with%20stethoscope%2C%20medical%20uniform%2C%20smiling%2C%20clean%20medical%20illustration%20style%2C%20isolated%20on%20transparent%20background%2C%20centered%20composition%2C%20the%20character%20should%20take%20up%2080%25%20of%20the%20frame&width=80&height=80&seq=doctor1&orientation=squarish',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.medical_services,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 추가 서비스 그리드
  Widget _buildAdditionalServices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추가 서비스',
          style: AppTypography.titleSmall,
        ),
        SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.1,
          children: [
            _buildServiceCard(
              title: '의료기기\n추천',
              badge: '🍯 추천 제품',
              icon: Icons.medical_services,
              color: AppColors.brandYellow,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('의료기기 추천 화면 준비 중입니다.')),
                );
              },
            ),
            _buildServiceCard(
              title: '요양보호사\n부르기',
              badge: '요양 서비스',
              icon: Icons.elderly,
              color: AppColors.brandOrange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('요양보호사 서비스 준비 중입니다.')),
                );
              },
            ),
            _buildServiceCard(
              title: '의료기기\n대여',
              icon: Icons.accessible,
              color: AppColors.secondary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('의료기기 대여 서비스 준비 중입니다.')),
                );
              },
            ),
            _buildServiceCard(
              title: '장기요양등급\n신청하기',
              icon: Icons.description,
              color: AppColors.accent,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('장기요양등급 신청 화면 준비 중입니다.')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 서비스 카드 (추가 서비스 그리드용)
  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required Color color,
    String? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 배지 (있을 경우)
            if (badge != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: AppRadius.badgeSmallRadius,
                ),
                child: Text(
                  badge,
                  style: AppTypography.captionSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              SizedBox(height: AppSpacing.sm),
            // 제목
            Text(
              title,
              style: AppTypography.headingSmall,
            ),
            // 아이콘
            Align(
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiMode = ref.watch(uiModeProvider);
    
    // UI 모드에 따라 다른 화면 표시
    if (uiMode == UIMode.practitioner) {
      return const PractitionerHomeScreen();
    }
    
    // 환자 모드 - Phase 1 개선 UI
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✨ Phase 1 추가: 브랜딩 헤더
            _buildBrandingHeader(context, ref),
            SizedBox(height: AppSpacing.sectionSpacing),
            
            // ✨ Phase 1 추가: 메인 서비스 카드 (방문진료)
            _buildMainServiceCard(context),
            SizedBox(height: AppSpacing.sectionSpacing),
            
            // ✨ Phase 1 추가: 추가 서비스 그리드
            _buildAdditionalServices(context),
            SizedBox(height: AppSpacing.sectionSpacing),
            
            // 🔄 기존 유지: 환자 선택
            _buildPatientSelection(),
            SizedBox(height: AppSpacing.lg),
            
            // 🔄 기존 유지: 주소 입력
            GestureDetector(
              onTap: () async {
                final address = await context.push<Address>(
                  '/address/search',
                );
                if (address != null && mounted) {
                  setState(() {
                    _selectedAddress = address;
                  });
                }
              },
              child: _buildAddressButton(_selectedAddress),
            ),
            SizedBox(height: AppSpacing.lg),
            
            // 🔄 기존 유지: 날짜 선택
            Text(
              "언제 진료를 받을까요?",
              style: AppTypography.titleSmall,
            ),
            SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: _buildSelectionButton(
                _selectedDate == null
                    ? "날짜를 선택해주세요"
                    : DateFormat(
                        'yyyy년 MM월 dd일 (E)',
                        'ko_KR',
                      ).format(_selectedDate!),
                Icons.calendar_today,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            
            // 🔄 기존 유지: 증상 선택
            Text(
              "어떤 질환으로 진료받으시나요?",
              style: AppTypography.titleSmall,
            ),
            SizedBox(height: AppSpacing.md),
            _buildSymptomSelection(),
            
            // ❌ 기존 "한의사 찾기" 버튼 삭제 (메인 서비스 카드로 대체됨)
            
            // 🔄 기존 유지: 선택된 한의사 정보
            if (_selectedDoctor != null) ...[
              SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.cardRadius,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_hospital, 
                          color: AppColors.primary, 
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedDoctor!.name,
                                style: AppTypography.headingMedium,
                              ),
                              Text(
                                "${_selectedDoctor!.specialty} · ${_selectedDoctor!.clinicName}",
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedDoctor = null;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    // 예약 가능한 시간 표시
                    Consumer(
                      builder: (context, ref, _) {
                        final slotsAsync = ref.watch(slotsProvider(_selectedDoctor!.id));
                        return slotsAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stack) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              '예약 가능한 시간을 불러올 수 없습니다.',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                          data: (slots) {
                            if (slots.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  '예약 가능한 시간이 없습니다. 다른 한의사를 선택해 주세요.',
                                  style: TextStyle(color: kGrayText, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  '예약 가능한 시간',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: kDarkGray,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: slots.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final slot = slots[index];
                                      final startsAt = slot.startsAt.toLocal();
                                      final endsAt = slot.endsAt.toLocal();
                                      return InkWell(
                                        onTap: () {
                                          // 슬롯 선택 시 예약 화면으로 이동
                                          context.push(
                                            '/booking',
                                            extra: {
                                              'selectedDoctor': _selectedDoctor,
                                              'selectedAddress': _selectedAddress,
                                              'selectedDate': startsAt,
                                              'selectedSymptom': _selectedSymptom,
                                              'selectedSlot': slot,
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: kPrimaryPink.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: kPrimaryPink,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${DateFormat('MM월 dd일 (E) HH:mm', 'ko_KR').format(startsAt)} - ${DateFormat('HH:mm').format(endsAt)}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 14,
                                                color: kGrayText,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// 한의사 전용 홈 화면
class PractitionerHomeScreen extends ConsumerWidget {
  const PractitionerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileStateNotifierProvider);
    
    return Container(
      color: kPrimaryBlue.withValues(alpha: 0.05),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 환영 메시지
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kPrimaryBlue.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: profileState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('프로필을 불러올 수 없습니다.'),
                data: (profile) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_hospital, color: kPrimaryBlue, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${profile.name} 한의사님',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kDarkGray,
                                ),
                              ),
                              if (profile.clinicName != null && profile.clinicName!.isNotEmpty)
                                Text(
                                  profile.clinicName!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kGrayText,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kPrimaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: kPrimaryBlue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '인증 완료',
                            style: TextStyle(
                              color: kPrimaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (profile.licenseNumber != null && profile.licenseNumber!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Text(
                              '자격증 번호: ${profile.licenseNumber}',
                              style: TextStyle(
                                color: kGrayText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 예약 관리 섹션
            const Text(
              "예약 관리",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kDarkGray,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kPrimaryBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  _buildStatCard(
                    icon: Icons.calendar_today,
                    label: '오늘 예약',
                    value: '0',
                    color: kPrimaryBlue,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    icon: Icons.pending_actions,
                    label: '대기 중',
                    value: '0',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    icon: Icons.check_circle,
                    label: '완료',
                    value: '0',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 빠른 액션
            const Text(
              "빠른 액션",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kDarkGray,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.schedule,
                    label: '일정 관리',
                    color: kPrimaryBlue,
                    onTap: () {
                      context.push('/doctor-schedule');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.people,
                    label: '환자 관리',
                    color: kPrimaryPink,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('환자 관리 기능은 준비 중입니다.')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.medical_services,
                    label: '진료 기록',
                    color: Colors.green,
                    onTap: () {
                      context.push('/medical-records');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.chat_bubble,
                    label: '채팅',
                    color: Colors.orange,
                    onTap: () {
                      // 채팅 탭으로 이동
                      // MainAppShellScreen의 _selectedIndex를 변경해야 하지만,
                      // 여기서는 간단히 메시지만 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('채팅 탭을 이용해주세요.')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: kDarkGray,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kDarkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
