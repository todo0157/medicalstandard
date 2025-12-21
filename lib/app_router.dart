import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/services/auth_session.dart';
import 'core/services/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/password_reset_screen.dart';
import 'features/auth/screens/email_verify_screen.dart';
import 'features/auth/screens/pre_email_verify_screen.dart';
import 'features/booking/appointment_booking_screen.dart';
import 'features/doctor/screens/find_doctor_screen.dart';
import 'features/home/screens/main_app_shell_screen.dart';
import 'features/insurance/health_insurance_screen.dart';
import 'features/legal/legal_notice_screen.dart';
import 'features/auth/screens/kakao_callback_screen.dart';
import 'features/medical_records/medical_records_screen.dart';
import 'features/profile/screens/profile_edit_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/certification_request_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/support/customer_support_screen.dart';
import 'features/address/screens/address_search_screen.dart';
import 'features/chat/screens/chat_list_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/chat/screens/practitioner_chat_screen.dart';
import 'features/doctor/screens/doctor_schedule_screen.dart';
import 'core/models/doctor.dart';
import 'core/models/address.dart';
import 'core/models/appointment.dart';

GoRouter createAppRouter(bool isAuthenticated) {
  return GoRouter(
    refreshListenable: AuthState.instance.listenable,
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
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return PasswordResetScreen(token: token);
        },
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return EmailVerifyScreen(token: token);
        },
      ),
      GoRoute(
        path: '/verify-pre',
        name: 'verify-pre',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return PreEmailVerifyScreen(token: token);
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
      GoRoute(
        path: '/profile/certification-request',
        name: 'certification-request',
        pageBuilder: (context, state) => MaterialPage(
          child: const CertificationRequestScreen(),
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
        pageBuilder: (context, state) {
          // Appointment 객체가 직접 전달된 경우 (수정 모드)
          if (state.extra is Appointment) {
            final appointment = state.extra as Appointment;
            return MaterialPage(
              child: AppointmentBookingScreen(
                existingAppointment: appointment,
              ),
            );
          }
          // Map 형태로 전달된 경우 (새 예약 모드)
          final extra = state.extra as Map<String, dynamic>?;
          return MaterialPage(
            child: AppointmentBookingScreen(
              selectedDoctor: extra?['selectedDoctor'] as Doctor?,
              selectedAddress: extra?['selectedAddress'] as Address?,
              selectedDate: extra?['selectedDate'] as DateTime?,
              selectedSymptom: extra?['selectedSymptom'] as String?,
            ),
          );
        },
      ),
      // Find Doctor
      GoRoute(
        path: '/find-doctor',
        name: 'find-doctor',
        pageBuilder: (context, state) => MaterialPage(
          child: const FindDoctorScreen(),
        ),
      ),
      // Doctor Schedule
      GoRoute(
        path: '/doctor-schedule',
        name: 'doctor-schedule',
        pageBuilder: (context, state) => MaterialPage(
          child: const DoctorScheduleScreen(),
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

      // Address Search
      GoRoute(
        path: '/address/search',
        name: 'address-search',
        pageBuilder: (context, state) => MaterialPage(
          child: const AddressSearchScreen(),
        ),
      ),

      // Chat Routes
      GoRoute(
        path: '/chat',
        name: 'chat-list',
        pageBuilder: (context, state) => MaterialPage(
          child: const ChatListScreen(),
        ),
      ),
      GoRoute(
        path: '/chat/:sessionId',
        name: 'chat-detail',
        pageBuilder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final isPractitioner = state.extra is Map && (state.extra as Map)['isPractitioner'] == true;
          return MaterialPage(
            child: isPractitioner
                ? PractitionerChatScreen(sessionId: sessionId)
                : ChatScreen(sessionId: sessionId),
          );
        },
      ),
      GoRoute(
        path: '/practitioner-chat/:sessionId',
        name: 'practitioner-chat-detail',
        pageBuilder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return MaterialPage(
            child: PractitionerChatScreen(sessionId: sessionId),
          );
        },
      ),
    ],
    redirect: (context, state) {
      final hasToken = AuthState.instance.isAuthenticated && AuthSession.instance.token != null;
      final location = state.matchedLocation;
      final allowUnauthed = location == '/login' ||
          location == '/signup' ||
          location == '/kakao-callback' ||
          location == '/reset-password' ||
          location == '/verify-email';

      if (!hasToken && !allowUnauthed) return '/signup';
      if (hasToken && (location == '/login' || location == '/signup')) return '/home';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('에러')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(state.error.toString()),
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
