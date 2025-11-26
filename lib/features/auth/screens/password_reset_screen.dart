import 'package:flutter/material.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/auth_service.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key, required this.token});

  final String? token;

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final token = widget.token;
    final pw = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (token == null || token.isEmpty) {
      setState(() {
        _message = '토큰이 없습니다. 메일 링크를 다시 확인해 주세요.';
        _success = false;
      });
      return;
    }
    if (pw.length < 8 || pw != confirm) {
      setState(() {
        _message = '비밀번호는 8자 이상이고 확인란과 일치해야 합니다.';
        _success = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await AuthService().resetPassword(token: token, password: pw);
      setState(() {
        _success = true;
        _message = '비밀번호가 재설정되었습니다. 로그인해 주세요.';
      });
    } catch (error) {
      final msg = error is AppException ? error.message : '재설정에 실패했습니다. 다시 시도해 주세요.';
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
        title: const Text('비밀번호 재설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              '새 비밀번호를 입력해 주세요.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '새 비밀번호 (8자 이상)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _success ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: _loading ? null : _reset,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('재설정하기'),
            ),
          ],
        ),
      ),
    );
  }
}
