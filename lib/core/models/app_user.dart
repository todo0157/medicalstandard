import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_profile.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

enum AuthProvider { kakao, pass, manual }

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    required AuthProvider authProvider,
    required UserProfile profile,
    required bool isEmailVerified,
    required bool isPhoneVerified,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
