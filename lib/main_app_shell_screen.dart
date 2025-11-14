import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가 (ko_KR)
import 'package:hanbang_app/chat_screen.dart';

// 4쪽&7쪽_대표 화면 설명&초기 화면.html의 Primary Color (#ec4899) 반영
const Color kPrimaryPink = Color(0xFFEC4899); 
const Color kPrimaryBlue = Color(0xFF3B82F6); // (HTML CSS 참고)
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

  // 각 탭에 해당하는 화면 목록
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // 홈 탭 (방문 진료 예약)
    const Center(child: Text("생활 탭", style: TextStyle(fontSize: 20, color: kPrimaryPink))),
    const ChatScreen(), // <--- 이 부분
    const Center(child: Text("프로필 탭", style: TextStyle(fontSize: 20, color: kPrimaryPink))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar (HTML 헤더 반영)
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: kPrimaryPink), // ri-menu-line
          onPressed: () {},
        ),
        title: const Text(
          "방문 진료",
          style: TextStyle(
            color: kDarkGray, // text-pink-900 (다크 그레이 계열)
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: kPrimaryPink), // ri-notification-line
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: kPrimaryPink.withOpacity(0.1),
      ),
      
      body: _widgetOptions.elementAt(_selectedIndex),
      
      // 하단 탭 바 (HTML nav 반영)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: '생활'), // ri-home-heart-line
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: '채팅'), // ri-chat-1-line
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '프로필'), // ri-user-line
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryPink,
        unselectedItemColor: const Color(0xFF9CA3AF), // gray-400
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        showUnselectedLabels: true,
      ),
    );
  }
}

// ----------------------------------------------------
// 홈 탭 (방문 진료 예약) UI 구현 (HTML main 영역)
// ----------------------------------------------------

// [수정됨] 3. 환자 데이터를 관리하기 위한 간단한 클래스
class Patient {
  final String id;
  final String name;
  final String imageUrl;
  final Color color;

  Patient({required this.id, required this.name, required this.imageUrl, required this.color});
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // [수정됨] '나'만 포함하도록 초기 환자 목록 변경
  final List<Patient> _patients = [
    Patient(
      id: "me", 
      name: "나", 
      imageUrl: "https://readdy.ai/api/search-image?query=Professional%20young%20Korean%20man%20in%20casual%20clothes%2C%20friendly%20smile%2C%20clean%20background%2C%20portrait%20photography%2C%20soft%20lighting%2C%20natural%20expression%2C%20modern%20style&width=64&height=64&seq=patient_me&orientation=squarish", 
      color: kPrimaryPink
    ),
    // '할머니' 항목 제거
  ];
  
  String _selectedPatientId = "me"; // '나' 기본 선택
  bool _symptomsVisible = false;
  DateTime? _selectedDate;
  String? _selectedSymptom;

  // HTML의 선택 버튼 스타일
  Widget _buildSelectionButton(String text, IconData icon) {
    bool isPlaceholder = text.contains("선택") || text.contains("입력");
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // rounded-lg
        border: Border.all(color: kPrimaryBlue.withOpacity(0.3)), // border-blue-200
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isPlaceholder ? kPrimaryBlue.withOpacity(0.8) : kDarkGray, 
              fontSize: 15,
              fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          Icon(icon, color: kPrimaryBlue.withOpacity(0.6)), // text-blue-400
        ],
      ),
    );
  }

  // HTML의 '누가' 섹션
  Widget _buildPatientSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "누가 진료를 받을까요?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kDarkGray),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // rounded-2xl
            border: Border.all(color: kPrimaryPink.withOpacity(0.3), width: 2, style: BorderStyle.solid), 
          ),
          child: Row(
            // [수정됨] Row의 정렬을 spaceEvenly -> flex-start (start)로 변경
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 동적 환자 목록 생성
              ..._patients.map((patient) => Padding(
                padding: const EdgeInsets.only(right: 24.0), // 환자 간 간격
                child: _buildPatientOption(patient),
              )).toList(),
              _buildAddPatientButton(), // '추가' 버튼
            ],
          ),
        ),
      ],
    );
  }

  // '누가' 섹션의 개별 옵션 버튼
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
              borderRadius: BorderRadius.circular(16), // rounded-2xl
              border: isSelected ? Border.all(color: patient.color, width: 4) : null, // 선택 시
              color: patient.color.withOpacity(0.1), // bg-pink-50 또는 bg-blue-50
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
                  size: 30
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            patient.name,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: patient.color.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  // '환자 추가' 버튼
  Widget _buildAddPatientButton() {
    return GestureDetector(
      onTap: () {
        _showAddPatientModal(context); // 모달 띄우기
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), // rounded-2xl
              border: Border.all(color: kPrimaryBlue.withOpacity(0.6), width: 2, style: BorderStyle.solid), // 점선 대체
            ),
            child: Icon(Icons.add, color: kPrimaryBlue.withOpacity(0.8), size: 30), // ri-add-line
          ),
          const SizedBox(height: 8),
          Text(
            "추가",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kPrimaryBlue.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  // 환자 추가 모달 (addPatientModal)
  void _showAddPatientModal(BuildContext context) {
    // HTML의 환자 추가 옵션들
    final List<Patient> addOptions = [
      Patient(
        id: "mother", 
        name: "어머니", 
        imageUrl: "https://readdy.ai/api/search-image?query=Kind%20middle%20aged%20Korean%20mother%20with%20warm%20smile%2C%20gentle%20expression%2C%20casual%20clothes%2C%20soft%20lighting%2C%20portrait%20photography%2C%20clean%20background&width=80&height=80&seq=patient_mother&orientation=squarish", 
        color: kPrimaryBlue
      ),
      Patient(
        id: "child", 
        name: "자녀", 
        imageUrl: "https://readdy.ai/api/search-image?query=Cute%20Korean%20child%20with%20bright%20smile%2C%20happy%20expression%2C%20casual%20clothes%2C%20soft%20lighting%2C%20portrait%20photography%2C%20clean%20background&width=80&height=80&seq=patient_child&orientation=squarish", 
        color: kPrimaryBlue
      ),
      Patient(
        id: "grandfather", 
        name: "할아버지", 
        imageUrl: "https://readdy.ai/api/search-image?query=Kind%20elderly%20Korean%20grandfather%20with%20gentle%20smile%2C%20warm%20expression%2C%20traditional%20Korean%20style%2C%20soft%20lighting%2C%20portrait%20photography%2C%20clean%20background&width=80&height=80&seq=patient_grandfather&orientation=squarish", 
        color: kPrimaryBlue
      ),
      Patient(
        id: "spouse", 
        name: "배우자", 
        imageUrl: "https://readdy.ai/api/search-image?query=Professional%20Korean%20spouse%20with%20friendly%20smile%2C%20kind%20expression%2C%20casual%20clothes%2C%20soft%20lighting%2C%20portrait%20photography%2C%20clean%20background&width=80&height=80&seq=patient_spouse&orientation=squarish", 
        color: kPrimaryBlue
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 모달 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("환자 추가", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kDarkGray)),
                  IconButton(
                    icon: const Icon(Icons.close, color: kGrayText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 환자 추가 그리드
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // HTML과 동일하게 2열
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
                        // 중복 추가 방지
                        if (!_patients.any((p) => p.id == patient.id)) {
                          _patients.add(patient);
                          _selectedPatientId = patient.id; // 새로 추가된 환자를 선택
                        }
                      });
                      Navigator.of(context).pop(); // 모달 닫기
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 80, // HTML의 w-20
                          height: 80, // HTML의 h-20
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16), // rounded-2xl
                            color: kPrimaryBlue.withOpacity(0.1), // bg-blue-50
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              patient.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_add_alt_1_outlined, color: kPrimaryBlue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(patient.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kDarkGray)),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }


  // 날짜 선택 모달 (Date Picker) 기능
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // 오늘부터 선택 가능
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryPink, // 헤더 배경색
              onPrimary: Colors.white, // 헤더 글자색
              onSurface: kDarkGray, // 날짜 글자색
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryPink, // 버튼 글자색
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // 날짜 상태 업데이트
      });
    }
  }


  // HTML의 '어떤 질환' 섹션
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
            _selectedSymptom ?? "증상을 선택해주세요", // 선택된 증상 표시
            _symptomsVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down, // ri-arrow-down-s-line
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
              childAspectRatio: 2.5, // HTML과 비율 맞춤 (w-full p-4)
              children: [
                _buildSymptomOption("근골격계", "https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20bone%20and%20joint%20symbol%20with%20gentle%20care%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame%2C%20warm%20blue%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus&width=48&height=48&seq=symptom_musculoskeletal_blue&orientation=squarish"),
                _buildSymptomOption("감기", "https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20medical%20thermometer%20and%20tissue%20box%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame%2C%20warm%20blue%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus&width=48&height=48&seq=symptom_cold_blue&orientation=squarish"),
                _buildSymptomOption("두통", "https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20head%20with%20gentle%20pain%20relief%20symbol%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame%2C%20warm%20blue%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus&width=48&height=48&seq=symptom_headache_blue&orientation=squarish"),
                _buildSymptomOption("기타", "https://readdy.ai/api/search-image?query=icon%2C%203D%20cartoon%20medical%20stethoscope%20and%20health%20check%20symbol%2C%20the%20icon%20should%20take%20up%2070%25%20of%20the%20frame%2C%20warm%20blue%20colors%20with%20soft%20gradients%2C%20minimalist%20design%2C%20smooth%20rounded%20shapes%2C%20subtle%20shading%2C%20no%20outlines%2C%20centered%20composition%2C%20isolated%20on%20white%20background%2C%20playful%20and%20friendly%20aesthetic%2C%20isometric%20perspective%2C%20high%20detail%20quality%2C%20clean%20and%20modern%20look%2C%20single%20object%20focus&width=48&height=48&seq=symptom_other_blue&orientation=squarish"),
              ],
            ),
          )
      ],
    );
  }

  // '어떤 질환'의 개별 옵션 버튼 (HTML의 이미지 경로 포함)
  Widget _buildSymptomOption(String label, String imageUrl) {
    bool isSelected = _selectedSymptom == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSymptom = label; // 증상 상태 업데이트
          _symptomsVisible = false; // 그리드 닫기
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryBlue.withOpacity(0.1) : Colors.white, // 선택 시 색상 변경
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? kPrimaryBlue : kPrimaryBlue.withOpacity(0.2), // 선택 시 테두리
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(imageUrl, width: 24, height: 24, errorBuilder: (context, error, stackTrace) => const Icon(Icons.healing_outlined, color: kPrimaryBlue)),
            const SizedBox(width: 10),
            Text(
              label, 
              style: TextStyle(
                color: kDarkGray, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              )
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryPink.withOpacity(0.05), // bg-pink-50
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 누가 진료를 받을까요?
            _buildPatientSelection(),
            const SizedBox(height: 24),

            // 2. 주소를 입력해주세요
            GestureDetector(
              onTap: () { /* (개선) 주소 검색 API 연동 */ },
              child: _buildSelectionButton("주소를 입력해주세요", Icons.place_outlined),
            ),
            const SizedBox(height: 24),

            // 3. 언제 진료를 받을까요?
            const Text(
              "언제 진료를 받을까요?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kDarkGray),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: _buildSelectionButton(
                _selectedDate == null 
                    ? "날짜를 선택해주세요" 
                    : DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate!), // 예: 2025년 11월 13일 (목)
                Icons.calendar_today
              ),
            ),
            const SizedBox(height: 24),

            // 4. 어떤 질환으로 진료받으시나요?
            const Text(
              "어떤 질환으로 진료받으시나요?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kDarkGray),
            ),
            const SizedBox(height: 16),
            _buildSymptomSelection(), // 드롭다운 그리드 포함
            const SizedBox(height: 32),

            // 5. 한의사 찾기 버튼
            ElevatedButton(
              onPressed: () { /* (개선) 한의사 찾기 화면으로 이동 */ },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryPink,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52), // py-4
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // rounded-button
                ),
                elevation: 0,
              ),
              child: const Text(
                "한의사 찾기",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20), // 하단 탭 바 여유 공간
          ],
        ),
      ),
    );
  }
}