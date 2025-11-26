import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';

class PreEmailVerifyScreen extends StatefulWidget {
  const PreEmailVerifyScreen({super.key, required this.token});

  final String? token;

  @override
  State<PreEmailVerifyScreen> createState() => _PreEmailVerifyScreenState();
}

class _PreEmailVerifyScreenState extends State<PreEmailVerifyScreen> {
  bool _loading = false;
  String? _message;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _startVerify();
  }

  Future<void> _startVerify() async {
    final token = widget.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _message = '토큰이 없습니다. 메일의 링크를 다시 확인해 주세요.';
        _success = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final email = await AuthService().confirmPreVerify(token: token);
      // 저장: 이후 회원가입 화면에서 확인할 수 있도록 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preverified_email', email);

      setState(() {
        _success = true;
        _message = '이메일 인증이 완료되었습니다. 회원가입을 계속 진행해 주세요.';
      });
    } catch (error) {
      final msg = error is AppException ? error.message : '인증에 실패했습니다. 링크를 다시 확인해 주세요.';
      setState(() {
        _success = false;
        _message = msg;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이메일 인증'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('인증 중입니다...'),
              ] else ...[
                Icon(
                  _success ? Icons.check_circle : Icons.error_outline,
                  color: _success ? Colors.green : Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _message ?? '인증 상태를 확인 중입니다.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startVerify,
                  child: const Text('다시 시도'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
