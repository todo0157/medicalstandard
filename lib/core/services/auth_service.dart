import '../errors/app_exception.dart';
import 'api_client.dart';

class SignUpRequest {
  SignUpRequest({
    required this.email,
    required this.password,
    required this.name,
    this.age,
    this.gender,
    this.address,
    this.phoneNumber,
  });

  final String email;
  final String password;
  final String name;
  final int? age;
  final String? gender;
  final String? address;
  final String? phoneNumber;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (address != null) 'address': address,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };
}

class AuthTokens {
  AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthTokens> signUp(SignUpRequest request) async {
    final response = await _apiClient.post('/auth/signup', body: request.toJson());
    return _parseTokens(response, onError: '회원가입 결과를 받아오지 못했습니다.');
  }

  Future<AuthTokens> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return _parseTokens(response, onError: '로그인 결과를 받아오지 못했습니다.');
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final response = await _apiClient.post(
      '/auth/refresh',
      body: {'refreshToken': refreshToken},
    );
    return _parseTokens(response, onError: '토큰 갱신에 실패했습니다.');
  }

  Future<AuthTokens> loginWithKakao({
    required String code,
    String? redirectUri,
  }) async {
    final response = await _apiClient.post(
      '/auth/kakao',
      body: {
        'code': code,
        if (redirectUri != null) 'redirectUri': redirectUri,
      },
    );
    return _parseTokens(response, onError: '카카오 인증에 실패했습니다.');
  }

  AuthTokens _parseTokens(Map<String, dynamic> response, {required String onError}) {
    final data = response['data'] as Map<String, dynamic>?;
    final access = data?['token']?.toString();
    final refresh = data?['refreshToken']?.toString();
    if (access == null || access.isEmpty || refresh == null || refresh.isEmpty) {
      throw AppException.server(message: onError);
    }
    return AuthTokens(accessToken: access, refreshToken: refresh);
  }
}
