import 'dart:io';

import '../errors/app_exception.dart';

class NetworkChecker {
  const NetworkChecker._();

  static Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  static Future<void> ensureConnected() async {
    if (!await hasConnection()) {
      throw const AppException.network();
    }
  }
}
