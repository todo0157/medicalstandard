import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/services/auth_session.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/booking/appointment_booking_screen.dart';
import 'features/doctor/screens/find_doctor_screen.dart';
import 'features/home/screens/main_app_shell_screen.dart';
import 'features/insurance/health_insurance_screen.dart';
import 'features/legal/legal_notice_screen.dart';
import 'features/auth/screens/kakao_callback_screen.dart';
import 'features/medical_records/medical_records_screen.dart';
import 'features/profile/screens/profile_edit_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/support/customer_support_screen.dart';

GoRouter createAppRouter(bool isAuthenticated) {
  return GoRouter(
    initialLocation: isAuthenticated ? '/home' : '/signup',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/kakao-callback',
      name: 'kakao-callback',
      builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        if (code == null || code.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Kakao 인증 코드가 없습니다.')),
          );
        }
        return KakaoCallbackScreen(code: code);
      },
    ),

      // Main App Shell (with nested navigation)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainAppShellScreen(),
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => MaterialPage(
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'profile-edit',
        pageBuilder: (context, state) => MaterialPage(
          child: const ProfileEditScreen(),
        ),
      ),

      // Medical Records
      GoRoute(
        path: '/medical-records',
        name: 'medical-records',
        pageBuilder: (context, state) => MaterialPage(
          child: const MedicalRecordsScreen(),
        ),
      ),
      // Appointment Booking
      GoRoute(
        path: '/booking',
        name: 'booking',
        pageBuilder: (context, state) => MaterialPage(
          child: const AppointmentBookingScreen(),
        ),
      ),
      // Find Doctor
      GoRoute(
        path: '/find-doctor',
        name: 'find-doctor',
        pageBuilder: (context, state) => MaterialPage(
          child: const FindDoctorScreen(),
        ),
      ),

      // Health Insurance
      GoRoute(
        path: '/health-insurance',
        name: 'health-insurance',
        pageBuilder: (context, state) => MaterialPage(
          child: const HealthInsuranceScreen(),
        ),
      ),

      // Support
      GoRoute(
        path: '/support',
        name: 'support',
        pageBuilder: (context, state) => MaterialPage(
          child: const CustomerSupportScreen(),
        ),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => MaterialPage(
          child: const SettingsScreen(),
        ),
      ),

      // Legal Notice
      GoRoute(
        path: '/legal',
        name: 'legal',
        pageBuilder: (context, state) => MaterialPage(
          child: const LegalNoticeScreen(),
        ),
    ),
  ],
    redirect: (context, state) {
      final hasToken = AuthSession.instance.token != null;
      final location = state.matchedLocation;
      final isAuthPage = location == '/login' || location == '/signup';
      final isKakaoCallback = location == '/kakao-callback';

      // 카카오 콜백은 토큰 없더라도 그대로 통과
      if (isKakaoCallback) return null;

      if (!hasToken && !isAuthPage) return '/signup';
      if (hasToken && isAuthPage) return '/home';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('오류')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text('페이지를 찾을 수 없습니다'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
}
