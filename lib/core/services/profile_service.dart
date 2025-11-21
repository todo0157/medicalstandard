import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import '../errors/app_exception.dart';
import '../models/user_profile.dart';
import 'api_client.dart';

abstract class ProfileService {
  Future<UserProfile> getCurrentUserProfile();
  Future<UserProfile> getUserProfileById(String userId);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> uploadProfileImage(String userId, String imagePath);
  Future<void> updateCertificationStatus(
    String userId,
    CertificationStatus status,
  );
}

class ApiProfileService implements ProfileService {
  ApiProfileService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    final response = await _apiClient.get('/profiles/me');
    return UserProfile.fromJson(_extractProfile(response));
  }

  @override
  Future<UserProfile> getUserProfileById(String userId) async {
    final response = await _apiClient.get('/profiles/$userId');
    return UserProfile.fromJson(_extractProfile(response));
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await _apiClient.put('/profiles/${profile.id}', body: profile.toJson());
  }

  @override
  Future<void> uploadProfileImage(String userId, String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw const AppException.validation(
        message: '선택한 이미지를 찾을 수 없습니다.',
      );
    }
    final encoded = base64Encode(await file.readAsBytes());

    await _apiClient.post(
      '/profiles/$userId/photo',
      body: {'fileName': file.uri.pathSegments.last, 'imageData': encoded},
    );
  }

  @override
  Future<void> updateCertificationStatus(
    String userId,
    CertificationStatus status,
  ) async {
    await _apiClient.post(
      '/profiles/$userId/certification',
      body: {'status': status.name},
    );
  }

  Map<String, dynamic> _extractProfile(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;

    final profile = json['profile'];
    if (profile is Map<String, dynamic>) return profile;

    return json;
  }
}

class MockProfileService implements ProfileService {
  static final _mockProfile = UserProfile(
    id: 'user_123',
    name: '김민수',
    age: 34,
    gender: Gender.male,
    address: '경기도 성남시 분당구 불정로 6',
    profileImageUrl: 'https://readdy.ai/api/images/user/doctor_male_1.jpg',
    phoneNumber: '010-1234-5678',
    idNumber: '890101-1234567',
    appointmentCount: 12,
    treatmentCount: 8,
    isPractitioner: false,
    certificationStatus: CertificationStatus.none,
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    updatedAt: DateTime.now(),
  );

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProfile;
  }

  @override
  Future<UserProfile> getUserProfileById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProfile;
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> uploadProfileImage(String userId, String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> updateCertificationStatus(
    String userId,
    CertificationStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

class ResilientProfileService implements ProfileService {
  ResilientProfileService({
    required ProfileService primary,
    required ProfileService fallback,
  }) : _primary = primary,
       _fallback = fallback;

  final ProfileService _primary;
  final ProfileService _fallback;

  @override
  Future<UserProfile> getCurrentUserProfile() {
    return _withFallback((service) => service.getCurrentUserProfile());
  }

  @override
  Future<UserProfile> getUserProfileById(String userId) {
    return _withFallback((service) => service.getUserProfileById(userId));
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) {
    return _primary.updateUserProfile(profile);
  }

  @override
  Future<void> uploadProfileImage(String userId, String imagePath) {
    return _primary.uploadProfileImage(userId, imagePath);
  }

  @override
  Future<void> updateCertificationStatus(
    String userId,
    CertificationStatus status,
  ) {
    return _primary.updateCertificationStatus(userId, status);
  }

  Future<T> _withFallback<T>(
    Future<T> Function(ProfileService service) operation,
  ) async {
    try {
      return await operation(_primary);
    } catch (error, stackTrace) {
      developer.log(
        'Primary profile service failed, falling back to mock data.',
        error: error,
        stackTrace: stackTrace,
        name: 'ProfileService',
      );
      return operation(_fallback);
    }
  }
}
