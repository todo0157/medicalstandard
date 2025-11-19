import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../chat/screens/chat_screen.dart';
import '../../profile/screens/profile_screen.dart';

// 4쪽&7쪽_대표 화면 설명&초기 화면.html의 Primary Color (#ec4899) 반영
const Color kPrimaryPink = Color(0xFFEC4899);
const Color kPrimaryBlue = Color(0xFF3B82F6);
const Color kGrayText = Color(0xFF6B7280);
const Color kDarkGray = Color(0xFF1F2937);

// 메인 탭 구조 (하단 탭 바)
class MainAppShellScreen extends StatefulWidget {
  const MainAppShellScreen({super.key});

  @override
  State<MainAppShellScreen> createState() => _MainAppShellScreenState();
}

class _MainAppShellScreenState extends State<MainAppShellScreen> {
  int _selectedIndex = 0; // 0: 홈, 1: 생활, 2: 채팅, 3: 프로필

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Build the appropriate widget for the selected tab
  Widget _getBodyWidget(int index) {
    switch (index) {
      case 0:
        return const HomeScreen(); // 홈 탭 (방문 진료 예약)
      case 1:
        return const Center(
          child: Text(
            "생활 탭",
            style: TextStyle(fontSize: 20, color: kPrimaryPink),
          ),
        );
      case 2:
        return const ChatScreen(); // 채팅 탭
      case 3:
        return const ProfileScreen(); // 프로필 탭
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar (HTML 헤더 반영)
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: kPrimaryPink),
          onPressed: () {},
        ),
        title: const Text(
          "방문 진료",
          style: TextStyle(
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
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: kPrimaryPink,
              onPressed: () => context.push('/booking'),
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              label: const Text(
                '새 방문 예약',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryPink.withValues(alpha: 0.05),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPatientSelection(),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                /* 주소 검색 API 연동 */
              },
              child: _buildSelectionButton("주소를 입력해주세요", Icons.place_outlined),
            ),
            const SizedBox(height: 24),
            const Text(
              "언제 진료를 받을까요?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kDarkGray,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            const Text(
              "어떤 질환으로 진료받으시나요?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kDarkGray,
              ),
            ),
            const SizedBox(height: 16),
            _buildSymptomSelection(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/find-doctor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryPink,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "한의사 찾기",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
