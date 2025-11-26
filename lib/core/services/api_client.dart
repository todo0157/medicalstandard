import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../network/network_checker.dart';
import 'auth_session.dart';
import 'auth_state.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    return _send(method: 'GET', path: path, headers: headers);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _send(method: 'POST', path: path, body: body, headers: headers);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _send(method: 'PUT', path: path, body: body, headers: headers);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _send(method: 'PATCH', path: path, body: body, headers: headers);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _send(method: 'DELETE', path: path, body: body, headers: headers);
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isRetry = false,
  }) async {
    await NetworkChecker.ensureConnected();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final token = AuthSession.instance.token;
    final mergedHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?headers
    };

    try {
      final response = await _request(
        method: method,
        uri: uri,
        headers: mergedHeaders,
        body: body,
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 401 && !isRetry && !_isRefreshPath(path)) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return _send(
            method: method,
            path: path,
            body: body,
            headers: headers,
            isRetry: true,
          );
        }
        // refresh 실패: 세션 정리 + 인증 상태 false
        await AuthSession.instance.clear();
        AuthState.instance.setAuthenticated(false);
      }

      _logResponse(method, uri, response);
      return _processResponse(response);
    } on SocketException {
      throw const AppException.network();
    } on TimeoutException {
      throw const AppException.timeout();
    }
  }

  Future<http.Response> _request({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    final encodedBody = body == null ? null : jsonEncode(body);
    _logRequest(method, uri, body);

    switch (method) {
      case 'POST':
        return _httpClient.post(uri, headers: headers, body: encodedBody);
      case 'PUT':
        return _httpClient.put(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        return _httpClient.patch(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        return _httpClient.delete(uri, headers: headers, body: encodedBody);
      case 'GET':
      default:
        return _httpClient.get(uri, headers: headers);
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final rawBody = response.body.trim();
    Map<String, dynamic>? decodedBody;

    if (rawBody.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawBody);
        if (decoded is Map<String, dynamic>) {
          decodedBody = decoded;
        }
      } catch (_) {
        // ignore decode errors, fall back to raw body
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (rawBody.isEmpty) return {};
      if (decodedBody != null) return decodedBody!;
      final decoded = jsonDecode(rawBody);
      return {'data': decoded};
    }

    final issues = _extractIssues(decodedBody);
    final message = _extractErrorMessage(rawBody, decodedBody);

    if (statusCode == 400) {
      throw AppException.validation(
        statusCode: statusCode,
        message: message,
        issues: issues,
      );
    }

    throw AppException.server(
      statusCode: statusCode,
      message: message,
      issues: issues,
    );
  }

  bool _isRefreshPath(String path) {
    return path.contains('/auth/refresh');
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = AuthSession.instance.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/refresh');
      final response = await _httpClient
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      final data = decoded['data'] as Map<String, dynamic>? ?? {};
      final access = data['token']?.toString();
      final refresh = data['refreshToken']?.toString();
      if (access == null || access.isEmpty || refresh == null || refresh.isEmpty) {
        return false;
      }
      await AuthSession.instance.saveTokens(token: access, refreshToken: refresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _extractErrorMessage(
    String rawBody,
    Map<String, dynamic>? decodedBody,
  ) {
    if (decodedBody != null) {
      return decodedBody['message']?.toString() ??
          decodedBody['error']?.toString() ??
          '알 수 없는 오류가 발생했습니다.';
    }
    if (rawBody.isEmpty) return '알 수 없는 오류가 발생했습니다.';
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            '알 수 없는 오류가 발생했습니다.';
      }
      return rawBody;
    } catch (_) {
      return rawBody;
    }
  }

  Map<String, List<String>>? _extractIssues(Map<String, dynamic>? decodedBody) {
    if (decodedBody == null) return null;
    final rawIssues = decodedBody['issues'];
    if (rawIssues is Map<String, dynamic>) {
      final result = <String, List<String>>{};
      rawIssues.forEach((key, value) {
        if (value is List) {
          final messages = value
              .map((item) => item?.toString())
              .whereType<String>()
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
          if (messages.isNotEmpty) result[key] = messages;
        } else if (value is String && value.trim().isNotEmpty) {
          result[key] = [value.trim()];
        }
      });
      return result.isEmpty ? null : result;
    }
    return null;
  }

  void close() {
    _httpClient.close();
  }

  void _logRequest(String method, Uri uri, Map<String, dynamic>? body) {
    if (!kDebugMode || !AppConfig.enableHttpLogging) return;
    debugPrint(
      '[API][$method] → $uri\nBody: ${body == null ? '-' : jsonEncode(body)}',
    );
  }

  void _logResponse(String method, Uri uri, http.Response response) {
    if (!kDebugMode || !AppConfig.enableHttpLogging) return;
    debugPrint(
      '[API][$method] ← $uri '
      '(status ${response.statusCode})\nResponse: ${response.body}',
    );
  }
}
