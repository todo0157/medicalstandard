import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../network/network_checker.dart';

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

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    await NetworkChecker.ensureConnected();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final mergedHeaders = {'Content-Type': 'application/json', ...?headers};

    try {
      final response = await _request(
        method: method,
        uri: uri,
        headers: mergedHeaders,
        body: body,
      ).timeout(AppConfig.apiTimeout);

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
      case 'GET':
      default:
        return _httpClient.get(uri, headers: headers);
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.trim();

    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) return {};
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    throw AppException.server(
      statusCode: statusCode,
      message: _extractErrorMessage(body),
    );
  }

  String _extractErrorMessage(String body) {
    if (body.isEmpty) return '알 수 없는 오류가 발생했습니다.';
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            '알 수 없는 오류가 발생했습니다.';
      }
      return body;
    } catch (_) {
      return body;
    }
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
