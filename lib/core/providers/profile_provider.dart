import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

// Service provider - provides the ProfileService instance
final profileServiceProvider = Provider<ProfileService>((ref) {
  // For now, use MockProfileService for development
  // Later, this can be replaced with a real implementation
  return MockProfileService();
});

// Async provider for current user profile
final currentUserProfileProvider =
    FutureProvider<UserProfile>((ref) async {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getCurrentUserProfile();
});

// Async provider for specific user profile
final userProfileProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getUserProfileById(userId);
});

// State notifier for managing profile updates
class ProfileStateNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileService _profileService;

  ProfileStateNotifier(this._profileService)
      : super(const AsyncValue.loading());

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        _profileService.getCurrentUserProfile());
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    try {
      await _profileService.updateUserProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> uploadProfileImage(String imagePath) async {
    try {
      final currentProfile = state.maybeWhen(
        data: (profile) => profile,
        orElse: () => null,
      );
      if (currentProfile != null) {
        await _profileService.uploadProfileImage(
          currentProfile.id,
          imagePath,
        );
        // Refresh profile after upload
        await loadProfile();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateCertificationStatus(
    CertificationStatus status,
  ) async {
    try {
      final currentProfile = state.maybeWhen(
        data: (profile) => profile,
        orElse: () => null,
      );
      if (currentProfile != null) {
        await _profileService.updateCertificationStatus(
          currentProfile.id,
          status,
        );
        // Refresh profile after update
        await loadProfile();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider for profile state management with updates
final profileStateNotifierProvider =
    StateNotifierProvider<ProfileStateNotifier, AsyncValue<UserProfile>>(
  (ref) {
    final profileService = ref.watch(profileServiceProvider);
    return ProfileStateNotifier(profileService);
  },
);
