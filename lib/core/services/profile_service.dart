import '../models/user_profile.dart';

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

class MockProfileService implements ProfileService {
  // Mock data for development
  static final _mockProfile = UserProfile(
    id: 'user_123',
    name: '김민수',
    age: 34,
    gender: Gender.male,
    address: '경기도 용인시 수지구 죽전동',
    profileImageUrl:
        'https://readdy.ai/api/images/user/doctor_male_1.jpg',
    phoneNumber: '010-1234-5678',
    idNumber: '890101-1234567',
    appointmentCount: 12,
    treatmentCount: 8,
    isPractitioner: false,
    certificationStatus: CertificationStatus.none,
    createdAt: DateTime.now().subtract(Duration(days: 365)),
    updatedAt: DateTime.now(),
  );

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    return _mockProfile;
  }

  @override
  Future<UserProfile> getUserProfileById(String userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _mockProfile;
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await Future.delayed(Duration(milliseconds: 500));
    // In a real implementation, this would call a backend API
  }

  @override
  Future<void> uploadProfileImage(String userId, String imagePath) async {
    await Future.delayed(Duration(milliseconds: 1000));
    // In a real implementation, this would upload to Firebase Storage or similar
  }

  @override
  Future<void> updateCertificationStatus(
    String userId,
    CertificationStatus status,
  ) async {
    await Future.delayed(Duration(milliseconds: 500));
    // In a real implementation, this would call a backend API
  }
}
