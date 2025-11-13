import 'package:flutter/material.dart'; // <--- ★★★ 이 한 줄이 모든 오류를 해결합니다 ★★★

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
    const Center(child: Text("채팅 탭", style: TextStyle(fontSize: 20, color: kPrimaryPink))),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedPatient = "me"; // '나' 기본 선택
  bool _symptomsVisible = false;

  // HTML의 선택 버튼 스타일
  Widget _buildSelectionButton(String text, IconData icon) {
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
            style: TextStyle(color: text.contains("선택") ? kPrimaryBlue.withOpacity(0.8) : kDarkGray, fontSize: 15),
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
            border: Border.all(color: kPrimaryPink.withOpacity(0.3), width: 2, style: BorderStyle.solid), // border-dashed border-pink-200 (Flutter는 점선 border가 복잡하여 실선으로 대체)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPatientOption("나", "me", kPrimaryPink),
              _buildPatientOption("할머니", "grandmother", kPrimaryBlue),
              _buildPatientOption("추가", "add", kPrimaryBlue, isAddButton: true),
            ],
          ),
        ),
      ],
    );
  }

  // '누가' 섹션의 개별 옵션 버튼
  Widget _buildPatientOption(String label, String key, Color color, {bool isAddButton = false}) {
    bool isSelected = _selectedPatient == key;
    
    return GestureDetector(
      onTap: () {
        if (!isAddButton) {
          setState(() {
            _selectedPatient = key;
          });
        } else {
          // (개선) 환자 추가 모달 띄우기 (HTML의 addPatientModal)
        }
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), // rounded-2xl
              border: isSelected 
                  ? Border.all(color: color, width: 4) // 선택 시
                  : isAddButton 
                      ? Border.all(color: color.withOpacity(0.6), width: 2, style: BorderStyle.solid) // 추가 버튼 (점선 대체)
                      : null,
              color: color.withOpacity(0.1), // bg-pink-50 또는 bg-blue-50
            ),
            child: isAddButton 
                ? Icon(Icons.add, color: color.withOpacity(0.8), size: 30) // ri-add-line
                : Icon(key == "me" ? Icons.person : Icons.elderly, color: color, size: 30), // (임시 아이콘)
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color.withOpacity(0.9)),
          ),
        ],
      ),
    );
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
            "증상을 선택해주세요", 
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
              childAspectRatio: 2.0, // 카드 비율
              children: [
                _buildSymptomOption("근골격계"),
                _buildSymptomOption("감기"),
                _buildSymptomOption("두통"),
                _buildSymptomOption("기타"),
              ],
            ),
          )
      ],
    );
  }

  // '어떤 질환'의 개별 옵션 버튼
  Widget _buildSymptomOption(String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kPrimaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.healing_outlined, color: kPrimaryBlue, size: 24),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: kPrimaryBlue.withOpacity(0.9), fontWeight: FontWeight.w500)),
        ],
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
              // ▼▼▼ [수정됨] Icons.map_pin_line -> Icons.place_outlined ▼▼▼
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
              onTap: () { /* (개선) 날짜 선택 모달 띄우기 (HTML의 calendarOverlay) */ },
              child: _buildSelectionButton("날짜를 선택해주세요", Icons.calendar_today),
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