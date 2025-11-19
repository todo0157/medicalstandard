import 'dart:io';

import 'package:flutter/foundation.dart';

import '../errors/app_exception.dart';

class NetworkChecker {
  const NetworkChecker._();

  static Future<bool> hasConnection() async {
    if (kIsWeb) {
      // Browsers already gatekeep connectivity; skip manual DNS lookups.
      return true;
    }
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on UnsupportedError {
      return false;
    }
  }

  static Future<void> ensureConnected() async {
    if (!await hasConnection()) {
      throw const AppException.network();
    }
  }
}
