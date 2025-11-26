import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';

/// 간단한 토큰 세션 관리
class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  static const _tokenKey = 'auth_token';
  static const _refreshKey = 'refresh_token';
  String? _token;
  String? _refreshToken;

  String? get token => _token;
  String? get refreshToken => _refreshToken;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshKey);
    AuthState.instance.setAuthenticated(_token != null);
  }

  Future<void> saveTokens({required String token, required String refreshToken}) async {
    _token = token;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshKey, refreshToken);
    AuthState.instance.setAuthenticated(true);
  }

  Future<void> clear() async {
    _token = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
    AuthState.instance.setAuthenticated(false);
  }
}
