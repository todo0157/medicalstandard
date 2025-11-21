import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/auth_session.dart';

const String _kakaoRedirectUri = String.fromEnvironment(
  'KAKAO_REDIRECT_URI',
  defaultValue: 'http://localhost:5173/kakao-callback',
);

class KakaoCallbackScreen extends StatefulWidget {
  const KakaoCallbackScreen({super.key, required this.code});

  final String code;

  @override
  State<KakaoCallbackScreen> createState() => _KakaoCallbackScreenState();
}

class _KakaoCallbackScreenState extends State<KakaoCallbackScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _handleKakaoLogin();
  }

  Future<void> _handleKakaoLogin() async {
    try {
      final tokens = await AuthService().loginWithKakao(
        code: widget.code,
        redirectUri: _kakaoRedirectUri,
      );
      await AuthSession.instance.saveTokens(
        token: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      if (!mounted) return;
      context.go('/home');
    } catch (error) {
      final msg = error is AppException
          ? error.message
          : '카카오 인증에 실패했습니다. 다시 시도해주세요.';
      setState(() {
        _error = msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('카카오 인증 중입니다...'),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('로그인으로 돌아가기'),
                  ),
                ],
              ),
      ),
    );
  }
}
