import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../models/user_profile.dart';
import '../services/api_client.dart';
import '../services/profile_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  final fallback = MockProfileService();

  if (AppConfig.useMockServices) {
    return fallback;
  }

  final apiClient = ref.watch(apiClientProvider);
  return ResilientProfileService(
    primary: ApiProfileService(apiClient),
    fallback: fallback,
  );
});

// Async provider for current user profile
final currentUserProfileProvider = FutureProvider<UserProfile>((ref) async {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getCurrentUserProfile();
});

// Async provider for specific user profile
final userProfileProvider = FutureProvider.family<UserProfile, String>((
  ref,
  userId,
) async {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getUserProfileById(userId);
});

// State notifier for managing profile updates
class ProfileStateNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileService _profileService;
  bool _isLoading = false;

  ProfileStateNotifier(this._profileService)
    : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    _isLoading = true;
    state = const AsyncValue.loading();
    try {
      final profile = await _profileService.getCurrentUserProfile();
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _withRefresh(() => _profileService.updateUserProfile(profile));
  }

  Future<void> uploadProfileImage(String imagePath) async {
    final profile = state.asData?.value;
    if (profile == null) return;
    await _withRefresh(
      () => _profileService.uploadProfileImage(profile.id, imagePath),
    );
  }

  Future<void> updateCertificationStatus(CertificationStatus status) async {
    final profile = state.asData?.value;
    if (profile == null) return;
    await _withRefresh(
      () => _profileService.updateCertificationStatus(profile.id, status),
    );
  }

  Future<void> _withRefresh(Future<void> Function() operation) async {
    state = const AsyncValue.loading();
    try {
      await operation();
      await loadProfile(forceRefresh: true);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Provider for profile state management with updates
final profileStateNotifierProvider =
    StateNotifierProvider<ProfileStateNotifier, AsyncValue<UserProfile>>((ref) {
      final profileService = ref.watch(profileServiceProvider);
      return ProfileStateNotifier(profileService);
    });
