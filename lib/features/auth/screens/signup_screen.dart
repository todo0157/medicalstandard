import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/auth_session.dart';

const Color kPrimaryColor = Color(0xFF3B82F6);
const Color kKakaoColor = Color(0xFFFEE500);
const Color kPassColor = Color(0xFF3B82F6);
const Color kButtonDisabledColor = Color(0xFFE5E7EB);
const Color kTextDisabledColor = Color(0xFF9CA3AF);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agreeAll = false;
  bool _terms1 = false;
  bool _terms2 = false;
  bool _terms3 = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idNumber1Controller = TextEditingController();
  final TextEditingController _idNumber2Controller = TextEditingController();

  bool _isSignupButtonEnabled = false;
  bool _isLoading = false;
  bool _emailVerifySending = false;
  bool _emailVerified = false;
  String? _verifyMessage;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
    _nameController.addListener(_validateForm);
    _idNumber1Controller.addListener(_validateForm);
    _idNumber2Controller.addListener(_validateForm);
    _loadPreverifiedEmail();
  }

  Future<void> _loadPreverifiedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('preverified_email');
    if (stored != null && stored.isNotEmpty) {
      final currentEmail = _emailController.text.trim().toLowerCase();
      if (currentEmail == stored.toLowerCase()) {
        setState(() {
          _emailVerified = true;
          _verifyMessage = '인증된 이메일입니다.';
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
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
        shadowColor: const Color(0xFFF3F4F6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 48)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '환영합니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '간편하게 가입하고 서비스를 이용해 보세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 24),

              _buildButton(
                text: '카카오톡으로 간편가입',
                onPressed: _launchKakaoAuth,
                backgroundColor: kKakaoColor,
                textColor: const Color(0xFF1F2937),
                icon: const Icon(Icons.chat_bubble, size: 20),
              ),
              const SizedBox(height: 16),

              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '또는',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                ],
              ),
              const SizedBox(height: 16),

              _buildEmailField(),
              const SizedBox(height: 12),

              _buildTextField(
                label: '비밀번호',
                placeholder: '영문, 숫자 포함 8자 이상',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: '비밀번호 확인',
                placeholder: '비밀번호를 다시 입력해 주세요',
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: '주소',
                placeholder: '방문 진료 받을 주소를 입력해 주세요',
                controller: _addressController,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: '이름',
                placeholder: '실명으로 입력해 주세요',
                controller: _nameController,
              ),
              const SizedBox(height: 12),

              _buildIdNumberField(
                idNumber1Controller: _idNumber1Controller,
                idNumber2Controller: _idNumber2Controller,
              ),
              const SizedBox(height: 16),

              _buildButton(
                text: 'PASS로 본인인증 (준비 중)',
                onPressed: () {},
                backgroundColor: kPassColor,
                textColor: Colors.white,
                icon: const Icon(Icons.phone_android, size: 20),
              ),
              const SizedBox(height: 20),

              _buildTermsSection(),
              const SizedBox(height: 20),

              _buildButton(
                text: '가입하기',
                onPressed: _isSignupButtonEnabled && !_isLoading && _emailVerified
                    ? _handleSignup
                    : null,
                backgroundColor: _isSignupButtonEnabled && _emailVerified
                    ? kPrimaryColor
                    : kButtonDisabledColor,
                textColor: _isSignupButtonEnabled && _emailVerified
                    ? Colors.white
                    : kTextDisabledColor,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '이미 계정이 있으신가요? ',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 12,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_verifyMessage != null)
                Text(
                  _verifyMessage!,
                  style: TextStyle(
                    color: _emailVerified ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchKakaoAuth() async {
    // TODO: kakao auth flow (existing)
  }

  Future<void> _sendVerifyEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _verifyMessage = '올바른 이메일을 입력해 주세요.';
        _emailVerified = false;
      });
      return;
    }
    setState(() {
      _emailVerifySending = true;
      _verifyMessage = null;
      _emailVerified = false;
    });
    try {
      await AuthService().sendPreVerifyEmail(email: email);
      setState(() {
        _verifyMessage = '인증 메일을 발송했습니다. 메일의 링크를 눌러 인증을 완료해 주세요.';
      });
    } catch (error) {
      final msg = error is AppException ? error.message : '인증 메일 발송에 실패했습니다.';
      setState(() {
        _verifyMessage = msg;
      });
    } finally {
      if (mounted) {
        setState(() {
          _emailVerifySending = false;
        });
        await _loadPreverifiedEmail();
        _validateForm();
      }
    }
  }

  void _validateForm() {
    final bool emailValid = _emailController.text.trim().contains('@');
    final String password = _passwordController.text.trim();
    final bool passwordValid = password.length >= 8;
    final bool confirmValid = _confirmPasswordController.text.trim() == password;
    final bool addressValid = _addressController.text.trim().isNotEmpty;
    final bool nameValid = _nameController.text.trim().isNotEmpty;
    final bool id1Valid = _idNumber1Controller.text.trim().length == 6;
    final bool id2Valid = _idNumber2Controller.text.trim().length == 7;
    final bool termsValid = _terms1 && _terms2;

    setState(() {
      _isSignupButtonEnabled = emailValid &&
          passwordValid &&
          confirmValid &&
          addressValid &&
          nameValid &&
          id1Valid &&
          id2Valid &&
          termsValid;
      if (!emailValid) {
        _emailVerified = false;
      }
    });
  }

  Future<void> _handleSignup() async {
    if (!_isSignupButtonEnabled || _isLoading || !_emailVerified) return;
    setState(() => _isLoading = true);
    try {
      final request = SignUpRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );
      final tokens = await AuthService().signUp(request);
      await AuthSession.instance.saveTokens(
        token: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('preverified_email');
      if (!mounted) return;
      _showSignupSuccessModal();
    } catch (error) {
      final message = error is AppException
          ? error.message
          : '회원가입 중 오류가 발생했습니다.';
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onAgreeAllChanged(bool? value) {
    setState(() {
      _agreeAll = value ?? false;
      _terms1 = _agreeAll;
      _terms2 = _agreeAll;
      _terms3 = _agreeAll;
      _validateForm();
    });
  }

  void _onTermChanged(int termNumber, bool? value) {
    setState(() {
      if (termNumber == 1) _terms1 = value ?? false;
      if (termNumber == 2) _terms2 = value ?? false;
      if (termNumber == 3) _terms3 = value ?? false;
      _agreeAll = _terms1 && _terms2 && _terms3;
      _validateForm();
    });
  }

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
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF059669),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '회원가입 완료!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '회원가입이 성공적으로 완료되었습니다.',
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _buildButton(
                  text: '확인',
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
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

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    Icon? icon,
    bool isLoading = false,
  }) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        disabledBackgroundColor: kButtonDisabledColor,
        foregroundColor: textColor,
        disabledForegroundColor: kTextDisabledColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      onPressed: effectiveOnPressed,
      child: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon,
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
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
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
              ),
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이메일',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'example@domain.com',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFD1D5DB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                  ),
                ),
                onChanged: (_) async {
                  _emailVerified = false;
                  _verifyMessage = null;
                  await _loadPreverifiedEmail();
                  _validateForm();
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _emailVerifySending ? null : _sendVerifyEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              child: _emailVerifySending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('인증'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIdNumberField({
    required TextEditingController idNumber1Controller,
    required TextEditingController idNumber2Controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '주민등록번호',
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
              width: 100,
              child: TextField(
                controller: idNumber1Controller,
                decoration: _idInputDecoration('000000'),
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
                '-',
                style: TextStyle(fontSize: 20, color: Color(0xFF9CA3AF)),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextField(
                controller: idNumber2Controller,
                decoration: _idInputDecoration('0000000'),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 7,
                obscureText: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _idInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      counterText: '',
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

  Widget _buildTermsSection() {
    return Column(
      children: [
        _buildCheckboxRow(
          title: '전체 동의',
          value: _agreeAll,
          onChanged: _onAgreeAllChanged,
          isMain: true,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 8),
          child: Column(
            children: [
              _buildCheckboxRow(
                title: '[필수] 이용약관',
                value: _terms1,
                onChanged: (val) => _onTermChanged(1, val),
                showLink: true,
              ),
              const SizedBox(height: 8),
              _buildCheckboxRow(
                title: '[필수] 개인정보 처리방침',
                value: _terms2,
                onChanged: (val) => _onTermChanged(2, val),
                showLink: true,
              ),
              const SizedBox(height: 8),
              _buildCheckboxRow(
                title: '[선택] 마케팅 정보 수신 동의',
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
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
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
            onTap: () {},
            child: const Text(
              '보기',
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
