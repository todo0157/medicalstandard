import 'package:flutter/material.dart';

// 11쪽_채팅화면.html의 Primary Color (#10B981) 반영
const Color kChatPrimaryGreen = Color(0xFF10B981);
const Color kChatBubbleGray = Color(0xFFF3F4F6); // secondary
const Color kDarkGray = Color(0xFF1F2937);
const Color kGrayText = Color(0xFF6B7280); 

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Widget> _chatMessages = [];
  bool _isInit = true; 

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // 초기 샘플 메시지 로드
      _chatMessages = [
        _buildTimestamp("오늘 오전 10:15"),
        _buildDoctorMessage("내일 예정된 시간에 방문드리고 필요하면 추후 꾸준히 관리해드릴게요. 도착 전에 한 번 더 연락드리겠습니다 😊"),
        _buildUserMessage("네 감사합니다 선생님 🙏"),
        _buildDoctorOptionsMessage(),
        _buildUserMessage("찌르는 듯이 아파요"),
        _buildUserMessage("움직이기가 너무 힘들어요"),
        _buildInfoCard(), // 방문진료 안내 카드
        _buildSuccessCard(), // 방문진료 예약 완료 카드
      ];
      _isInit = false; // 초기화 완료
    }
  }


  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 채팅 전송 로직
  void _handleSendMessage(String text) {
    final message = text.trim();
    if (message.isEmpty) return; 

    _chatController.clear(); 
    
    setState(() {
      _chatMessages.add(_buildUserMessage(message));
    });

    _scrollToBottom();
  }

  // 시스템 메시지(안내) 추가 로직
  void _addSystemMessage(String text) {
    setState(() {
      _chatMessages.add(_buildSystemMessageWidget(text));
    });
    _scrollToBottom();
  }

  // 맨 아래로 스크롤하는 유틸리티
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 채팅 메시지 스크롤 영역 (동적으로 변경)
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              return _chatMessages[index];
            },
          ),
        ),
        
        // 2. 하단 메시지 입력창
        _buildChatInputBar(),
      ],
    );
  }

  // [수정됨] 방문진료 요청 모달 (image_36072a.png)
  void _showVisitRequestModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        // [수정됨] 모달 내의 상태(선택된 시간)를 관리하기 위해 StatefulBuilder 사용
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // 모달 내부에서 사용할 상태 변수
            final TextEditingController addressController = TextEditingController(text: "서울시 강남구 삼성동 100-1, 101동 1503호");
            String selectedTime = "오늘 오후 2:00";
            final List<String> timeOptions = ["오늘 오후 2:00", "오늘 오후 3:00", "오늘 오후 4:00"];

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, 
                left: 24,
                right: 24,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 모달 상단 핸들
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 헤더
                  const Center(
                    child: Text(
                      "방문진료 요청",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDarkGray),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 안내 박스 (image_36072a.png의 초록색 박스)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kChatPrimaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: kChatPrimaryGreen, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "현재 환자는 재진 환자입니다 → 방문진료 가능",
                          style: TextStyle(color: kChatPrimaryGreen, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 환자 정보 (image_374a60.png 반영)
                  const Text("환자 정보", style: TextStyle(fontSize: 14, color: kGrayText)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("이름: 박영수 (남, 65세)", style: TextStyle(fontSize: 16, color: kDarkGray, fontWeight: FontWeight.w500)),
                        SizedBox(height: 4),
                        Text("최근 진료: 2024.01.15 (요통 치료)", style: TextStyle(fontSize: 14, color: kGrayText)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // [수정됨] 방문 주소 (TextField로 변경)
                  const Text("방문 주소", style: TextStyle(fontSize: 14, color: kGrayText)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kChatPrimaryGreen, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // [수정됨] 희망 방문 시간 (DropdownButton으로 변경)
                  const Text("희망 방문 시간", style: TextStyle(fontSize: 14, color: kGrayText)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedTime,
                        icon: const Icon(Icons.arrow_drop_down, color: kGrayText),
                        onChanged: (String? newValue) {
                          setModalState(() { // StatefulBuilder의 setState 사용
                            selectedTime = newValue!;
                          });
                        },
                        items: timeOptions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 16, color: kDarkGray)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 버튼
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("취소", style: TextStyle(color: kDarkGray)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _addSystemMessage("방문진료 요청이 접수되었습니다. 일정 확정 시 알림이 갑니다.");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kChatPrimaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text("요청 전송"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), // 하단 여백
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 모달 내부 정보 행 위젯 (이제 환자 정보만 처리)
  Widget _buildModalInfoRow({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: kGrayText)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 16, color: kDarkGray, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 시스템 메시지 위젯 (image_36590c.png)
  Widget _buildSystemMessageWidget(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), 
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // bg-blue-50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)), // border-blue-200
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 14)
            ),
          ),
        ],
      ),
    );
  }

  // 시간 표시 (예: "오늘 오전 10:15")
  Widget _buildTimestamp(String time) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6), // gray-100
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), // gray-500
        ),
      ),
    );
  }

  // 의사 메시지 버블 (왼쪽)
  Widget _buildDoctorMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage("https://readdy.ai/api/search-image?query=professional%20korean%20traditional%20medicine%20doctor%20portrait%2C%20middle%20aged%20male%2C%20white%20coat%2C%20friendly%20smile%2C%20medical%20professional%20headshot%2C%20clean%20background&width=64&height=64&seq=doctor002&orientation=squarish"),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: kChatBubbleGray, 
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4), 
              ),
            ),
            child: Text(message, style: const TextStyle(color: kDarkGray, fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }

  // 사용자(나) 메시지 버블 (오른쪽)
  Widget _buildUserMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: kChatPrimaryGreen, // bg-primary (green)
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: const Radius.circular(4), // rounded-br-md
              ),
            ),
            child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }

  // 의사 메시지 (옵션 버튼 포함)
  Widget _buildDoctorOptionsMessage() {
    Widget buildOption(String text) {
      return OutlinedButton(
        onPressed: () { /* (개선) 옵션 선택 시 로직 */ },
        style: OutlinedButton.styleFrom(
          foregroundColor: kDarkGray,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE5E7EB)), // border
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage("https://readdy.ai/api/search-image?query=professional%20korean%20traditional%20medicine%20doctor%20portrait%2C%20middle%20aged%20male%2C%20white%20coat%2C%20friendly%20smile%2C%20medical%20professional%20headshot%2C%20clean%20background&width=64&height=64&seq=doctor004&orientation=squarish"),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: kChatBubbleGray,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("통증이 심해지신 건 언제부터인가요?", style: TextStyle(color: kDarkGray, fontSize: 14, height: 1.5)),
                const SizedBox(height: 12),
                buildOption("찌르는 듯한 통증"),
                const SizedBox(height: 8),
                buildOption("묵직한 통증"),
                const SizedBox(height: 8),
                buildOption("당기는 통증"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 방문진료 안내 카드
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // bg-blue-50
        border: Border.all(color: const Color(0xFFDBEAFE)), // border-blue-200
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text("📌 방문진료 안내", style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          const Text("• 원칙: 시범기관 내원 후 1회 이상 진료받은 환자", style: TextStyle(color: Color(0xFF1E40AF), fontSize: 12)),
          const Text("• 예외: 한의사가 필요하다고 판단 시 초진도 가능", style: TextStyle(color: Color(0xFF1E40AF), fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showVisitRequestModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // bg-blue-600
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("방문진료 요청", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  // 예약 완료 카드
  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // bg-green-50
        border: Border.all(color: const Color(0xFFBBF7D0)), // border-green-200
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("오후 2:00 방문진료가 예약되었습니다.", style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w500, fontSize: 14)),
              SizedBox(height: 2),
              Text("일정 변경 시 미리 연락드리겠습니다.", style: TextStyle(color: Color(0xFF166534), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
  
  // 하단 메시지 입력창 (HTML의 input-container)
  Widget _buildChatInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4B5563)),
            onPressed: () { /* (개선) 파일/사진 첨부 */ },
          ),
          
          // 텍스트 필드
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: "메시지를 입력하세요...",
                filled: true,
                fillColor: kChatBubbleGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (text) => _handleSendMessage(text),
            ),
          ),
          const SizedBox(width: 8),
          
          // 전송 버튼
          ElevatedButton(
            onPressed: () => _handleSendMessage(_chatController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: kChatPrimaryGreen,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(Icons.send, size: 20),
          ),
        ],
      ),
    );
  }
}
