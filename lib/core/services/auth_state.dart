import 'package:flutter/foundation.dart';

/// Simple auth state notifier to refresh routing when token changes.
class AuthState {
  AuthState._();
  static final AuthState instance = AuthState._();

  final ValueNotifier<bool> _isAuthenticated = ValueNotifier<bool>(false);

  ValueListenable<bool> get listenable => _isAuthenticated;

  bool get isAuthenticated => _isAuthenticated.value;

  void setAuthenticated(bool value) {
    if (_isAuthenticated.value == value) return;
    _isAuthenticated.value = value;
  }
}
