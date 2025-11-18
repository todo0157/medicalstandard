import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:go_router/go_router.dart';

// 5履??뚯썝媛??html??Tailwind Config ?됱긽 諛섏쁺
const Color kPrimaryColor = Color(0xFF3B82F6);
const Color kKakaoColor = Color(0xFFFEE500); // 移댁뭅???ㅼ젣 ?됱긽
const Color kPassColor = Color(0xFF3B82F6); // PASS 踰꾪듉 ?됱긽 (html 湲곗?)
const Color kButtonDisabledColor = Color(0xFFE5E7EB); // 鍮꾪솢?깊솕 踰꾪듉 (html 湲곗?)
const Color kTextDisabledColor = Color(0xFF9CA3AF); // 鍮꾪솢?깊솕 ?띿뒪??(html 湲곗?)

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // ?쎄? ?숈쓽 ?곹깭
  bool _agreeAll = false;
  bool _terms1 = false;
  bool _terms2 = false;
  bool _terms3 = false;

  // ?낅젰 媛??곹깭
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idNumber1Controller = TextEditingController();
  final TextEditingController _idNumber2Controller = TextEditingController();

  bool _isSignupButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // ?낅젰 媛?蹂寃?媛먯?
    _nameController.addListener(_validateForm);
    _idNumber1Controller.addListener(_validateForm);
    _idNumber2Controller.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idNumber1Controller.dispose();
    _idNumber2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0xFFF3F4F6), // gray-100
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
          onPressed: () {
            // (개선) 뒤로가기 로직
          },
        ),
        title: const Text(
          "회원가입",
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48), // 타이틀 중앙 정렬을 위한 여백
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 환영 메시지
              const Text(
                "환영합니다!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "간편하게 가입하고 서비스를 이용해 보세요",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 24),

              // 2. 카카오 간편가입
              _buildButton(
                text: "카카오톡으로 간편가입",
                onPressed: _handleKakaoLogin, // [임시] 필수 연동
                backgroundColor: const Color(0xFFFEE500), // yellow-400
                textColor: const Color(0xFF1F2937), // gray-900
                icon: const Icon(Icons.chat_bubble, size: 20),
              ),
              const SizedBox(height: 16),

              // 3. Divider
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "또는",
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                ],
              ),
              const SizedBox(height: 16),

              // 4. 이름 입력
              _buildTextField(
                label: "이름",
                placeholder: "실명을 입력해주세요",
                controller: _nameController,
              ),
              const SizedBox(height: 12),

              // 5. 주민등록번호 입력
              _buildIdNumberField(
                idNumber1Controller: _idNumber1Controller,
                idNumber2Controller: _idNumber2Controller,
              ),
              const SizedBox(height: 16),

              // 6. PASS 인증
              _buildButton(
                text: "PASS로 본인인증 가입",
                onPressed: () {},
                backgroundColor: kPassColor,
                textColor: Colors.white,
                icon: const Icon(Icons.phone_android, size: 20),
              ),
              const SizedBox(height: 20),

              // 7. 약관 동의
              _buildTermsSection(),
              const SizedBox(height: 20),

              // 8. 가입하기 버튼
              _buildButton(
                text: "가입하기",
                onPressed: _isSignupButtonEnabled
                    ? _showSignupSuccessModal
                    : null,
                backgroundColor: _isSignupButtonEnabled
                    ? kPrimaryColor
                    : kButtonDisabledColor,
                textColor: _isSignupButtonEnabled
                    ? Colors.white
                    : kTextDisabledColor,
              ),
              const SizedBox(height: 16),

              // 9. 로그인 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "이미 계정이 있으신가요? ",
                    style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                  ),
                  GestureDetector(
                    onTap: () {
                      // (개선) 로그인 화면으로 이동
                    },
                    child: const Text(
                      "로그인",
                      style: TextStyle(
                        fontSize: 12,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // [異붽??? Key Hash 異쒕젰 諛?濡쒓렇??濡쒖쭅 (ANR ?먯씤 異붿쟻??
  void _handleKakaoLogin() async {
    try {
      // ----------------------------------------------------
      // [?꾩떆 肄붾뱶] Key Hash ?뺤씤 諛?異쒕젰 (濡쒓렇???뚯뒪?????꾩떆濡??ъ슜)
      // ----------------------------------------------------
      final hash = await KakaoSdk.origin;
      debugPrint('===================================================');
      debugPrint('???붾쾭洹????댁떆 (?꾩닔 ?깅줉): $hash');
      debugPrint('===================================================');
      // ----------------------------------------------------

      // 移댁뭅?ㅽ넚 ?ㅼ튂 ?щ? ?뺤씤
      bool isInstalled = await isKakaoTalkInstalled();

      // 移댄넚???ㅼ튂?섏뼱 ?덉쑝硫?移댄넚?쇰줈 濡쒓렇??
      if (isInstalled) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 移댄넚???놁쑝硫??밸툕?쇱슦?(怨꾩젙)濡?濡쒓렇??
        await UserApi.instance.loginWithKakaoAccount();
      }

      // 濡쒓렇???깃났 ???ъ슜???뺣낫 媛?몄삤湲?
      final user = await UserApi.instance.me();
      debugPrint(
        '?ъ슜???뺣낫 媛?몄삤湲??깃났'
        '\n?대쫫: ${user.kakaoAccount?.profile?.nickname}',
      );

      if (mounted) {
        _showSignupSuccessModal();
      }
    } catch (error) {
      debugPrint('移댁뭅??濡쒓렇???ㅽ뙣: $error');
    }
  }

  // 媛?낇븯湲?踰꾪듉 ?쒖꽦??濡쒖쭅 (html??script id="checkbox-handler" 李멸퀬)
  void _validateForm() {
    final bool nameValid = _nameController.text.trim().isNotEmpty;
    final bool id1Valid = _idNumber1Controller.text.trim().length == 6;
    final bool id2Valid = _idNumber2Controller.text.trim().length == 7;
    final bool termsValid = _terms1 && _terms2; // ?꾩닔 ?쎄?

    setState(() {
      _isSignupButtonEnabled = nameValid && id1Valid && id2Valid && termsValid;
    });
  }

  // 전체 동의 泥댄겕諛뺤뒪 濡쒖쭅
  void _onAgreeAllChanged(bool? value) {
    setState(() {
      _agreeAll = value ?? false;
      _terms1 = _agreeAll;
      _terms2 = _agreeAll;
      _terms3 = _agreeAll;
      _validateForm();
    });
  }

  // 媛쒕퀎 ?쎄? 泥댄겕諛뺤뒪 濡쒖쭅
  void _onTermChanged(int termNumber, bool? value) {
    setState(() {
      if (termNumber == 1) _terms1 = value ?? false;
      if (termNumber == 2) _terms2 = value ?? false;
      if (termNumber == 3) _terms3 = value ?? false;

      // 媛쒕퀎 ?좏깮???곕Ⅸ 전체 동의 泥댄겕 蹂寃?
      if (_terms1 && _terms2 && _terms3) {
        _agreeAll = true;
      } else {
        _agreeAll = false;
      }
      _validateForm();
    });
  }

  // 媛???꾨즺 紐⑤떖 (html??script id="signup-handler" 李멸퀬)
  void _showSignupSuccessModal() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5), // green-100
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF059669), // green-600
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "회원가입 완료!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "회원가입이 성공적으로 완료되었습니다.",
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _buildButton(
                  text: "확인",
                  onPressed: () {
                    // 1. 모달 닫기
                    Navigator.of(dialogContext).pop();

                    // 2. 메인 화면으로 이동 (go_router 사용)
                    if (!mounted) return;
                    context.go('/home');
                  },
                  backgroundColor: kPrimaryColor,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // [?꾩껜 ?ы븿?? 怨듯넻 踰꾪듉 ?꾩젽 (html??!rounded-button ?ㅽ???諛섏쁺)
  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    Icon? icon,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        disabledBackgroundColor: kButtonDisabledColor,
        foregroundColor: textColor,
        disabledForegroundColor: kTextDisabledColor,
        minimumSize: const Size(double.infinity, 50), // py-3.5 (14*2 + 22)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // rounded-button (8px)
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: 12), // gap-3
          ],
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // [?꾩껜 ?ы븿?? 怨듯넻 ?띿뒪???꾨뱶 ?꾩젽
  Widget _buildTextField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ), // px-3 py-2.5
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
              ), // border-gray-300
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // [?꾩껜 ?ы븿?? 주민등록번호 ?낅젰 ?꾨뱶
  Widget _buildIdNumberField({
    required TextEditingController idNumber1Controller,
    required TextEditingController idNumber2Controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "주민등록번호",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            SizedBox(
              width: 100, // html??w-20蹂대떎 ?볤쾶 ?≪쓬 (Flutter 湲곕낯 ?⑤뵫 怨좊젮)
              child: TextField(
                controller: idNumber1Controller,
                decoration: _idInputDecoration("000000"),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  if (value.length == 6) {
                    FocusScope.of(context).nextFocus();
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "-",
                style: TextStyle(fontSize: 20, color: Color(0xFF9CA3AF)),
              ),
            ),
            SizedBox(
              width: 100, // html??w-20蹂대떎 ?볤쾶 ?≪쓬
              child: TextField(
                controller: idNumber2Controller,
                decoration: _idInputDecoration("0000000"),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 7,
                obscureText: true, // 鍮꾨?踰덊샇 泥섎━
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // [?꾩껜 ?ы븿?? ID ?낅젰 ?꾨뱶 ?곗퐫?덉씠??
  InputDecoration _idInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      counterText: "", // maxLength 移댁슫???④린湲?
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
    );
  }

  // [?꾩껜 ?ы븿?? ?쎄? ?숈쓽 ?뱀뀡
  Widget _buildTermsSection() {
    return Column(
      children: [
        _buildCheckboxRow(
          title: "전체 동의",
          value: _agreeAll,
          onChanged: _onAgreeAllChanged,
          isMain: true,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 8), // pl-8 space-y-2
          child: Column(
            children: [
              _buildCheckboxRow(
                title: "[필수] 서비스 이용약관",
                value: _terms1,
                onChanged: (val) => _onTermChanged(1, val),
                showLink: true,
              ),
              const SizedBox(height: 8),
              _buildCheckboxRow(
                title: "[필수] 개인정보 처리방침",
                value: _terms2,
                onChanged: (val) => _onTermChanged(2, val),
                showLink: true,
              ),
              const SizedBox(height: 8),
              _buildCheckboxRow(
                title: "[선택] 마케팅 정보 수신 동의",
                value: _terms3,
                onChanged: (val) => _onTermChanged(3, val),
                showLink: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // [?꾩껜 ?ы븿?? 怨듯넻 泥댄겕諛뺤뒪 ???꾩젽 (html??checkbox-custom ?ㅽ???諛섏쁺)
  Widget _buildCheckboxRow({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isMain = false,
    bool showLink = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Row(
            children: [
              // Custom Checkbox
              Container(
                width: isMain ? 20 : 16,
                height: isMain ? 20 : 16,
                decoration: BoxDecoration(
                  color: value ? kPrimaryColor : Colors.transparent,
                  border: Border.all(
                    color: value ? kPrimaryColor : const Color(0xFFD1D5DB),
                    width: isMain ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: value
                    ? Icon(
                        Icons.check,
                        size: isMain ? 16 : 12,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12), // gap-3
              Text(
                title,
                style: TextStyle(
                  fontSize: isMain ? 14 : 12,
                  fontWeight: isMain ? FontWeight.w500 : FontWeight.normal,
                  color: isMain
                      ? const Color(0xFF111827)
                      : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
        if (showLink)
          GestureDetector(
            onTap: () {
              // (媛쒖꽑) ?쎄? 蹂닿린 留곹겕
            },
            child: const Text(
              "보기",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}
