enum AppEnvironment { development, staging, production }

class AppConfig {
  const AppConfig._();

  /// String representation of the environment passed at build time.
  static const String environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  /// Allows overriding the API host completely at build time.
  static const String _customApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Base URL of the backend API, falling back to environment defaults.
  static String get apiBaseUrl {
    if (_customApiBaseUrl.isNotEmpty) {
      return _customApiBaseUrl;
    }

    switch (environment) {
      case AppEnvironment.development:
        return 'https://dev.api.medicalstandard.dev';
      case AppEnvironment.staging:
        return 'https://staging.api.medicalstandard.dev';
      case AppEnvironment.production:
        return 'https://api.medicalstandard.dev';
    }
  }

  static final AppEnvironment environment = () {
    switch (environmentName.toLowerCase()) {
      case 'dev':
      case 'development':
        return AppEnvironment.development;
      case 'stage':
      case 'staging':
        return AppEnvironment.staging;
      default:
        return AppEnvironment.production;
    }
  }();

  /// Global timeout for HTTP requests.
  static const Duration apiTimeout = Duration(seconds: 12);
  
  /// Timeout for address search requests (longer for postal code searches).
  static const Duration addressSearchTimeout = Duration(seconds: 30);

  /// Derived WebSocket base URL matching the REST API host.
  static String get wsBaseUrl {
    final base = apiBaseUrl;
    if (base.startsWith('https://')) {
      return base.replaceFirst('https://', 'wss://');
    }
    if (base.startsWith('http://')) {
      return base.replaceFirst('http://', 'ws://');
    }
    return 'ws://$base';
  }

  static const bool _mockOverride = bool.fromEnvironment(
    'ENABLE_MOCK_SERVICES',
    defaultValue: false,
  );

  /// Returns true when the build explicitly requests mock services.
  static bool get useMockServices => _mockOverride;

  /// When true, the ApiClient will log requests/responses in debug builds.
  static const bool enableHttpLogging = bool.fromEnvironment(
    'ENABLE_HTTP_LOGGING',
    defaultValue: false,
  );
}
