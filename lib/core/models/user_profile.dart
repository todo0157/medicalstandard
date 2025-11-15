import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum CertificationStatus { none, pending, verified }

enum Gender { male, female }

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    required int age,
    required Gender gender,
    required String address,
    String? profileImageUrl,
    String? phoneNumber,
    String? idNumber,
    @Default(0) int appointmentCount,
    @Default(0) int treatmentCount,
    @Default(false) bool isPractitioner,
    String? licenseNumber,
    String? clinicName,
    @Default(CertificationStatus.none) CertificationStatus certificationStatus,
    DateTime? certificationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
