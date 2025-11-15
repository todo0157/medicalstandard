import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/home/screens/main_app_shell_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/medical_records/medical_records_screen.dart';
import 'features/insurance/health_insurance_screen.dart';
import 'features/support/customer_support_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/legal/legal_notice_screen.dart';
import 'features/booking/appointment_booking_screen.dart';
import 'features/doctor/screens/find_doctor_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/signup',
  routes: [
    // Auth Routes
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
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

  // Error handler
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
