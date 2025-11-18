enum AppExceptionType { network, timeout, server, validation, unexpected }

class AppException implements Exception {
  const AppException._(this.type, this.message, {this.statusCode});

  final AppExceptionType type;
  final String message;
  final int? statusCode;

  const AppException.network([String message = '네트워크 연결 상태를 확인해 주세요.'])
    : this._(AppExceptionType.network, message);

  const AppException.timeout([
    String message = '요청 시간이 초과되었습니다. 잠시 후 다시 시도해 주세요.',
  ]) : this._(AppExceptionType.timeout, message);

  const AppException.server({
    int? statusCode,
    String message = '서버에서 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
  }) : this._(AppExceptionType.server, message, statusCode: statusCode);

  const AppException.validation([String message = '입력값을 다시 확인해 주세요.'])
    : this._(AppExceptionType.validation, message);

  const AppException.unexpected([String message = '예상치 못한 오류가 발생했습니다.'])
    : this._(AppExceptionType.unexpected, message);

  @override
  String toString() => 'AppException($type, $message, statusCode: $statusCode)';
}
