import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:firebase_core/firebase_core.dart'; // 추가
import 'firebase_options.dart'; // 추가 (flutterfire configure로 생성된 파일 필요, 없으면 수동 초기화 필요)

import 'app_router.dart';
import 'core/services/auth_session.dart';
import 'core/services/auth_state.dart';
import 'core/services/notification_service.dart'; // 추가

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Firebase 초기화 (플랫폼별 옵션 자동 설정)
  // firebase_options.dart 파일이 없다면 수동으로 설정하거나, flutterfire configure 명령어를 실행해야 함.
  // 사용자가 "앱 설정 파일 다운로드 완료"라고 했으므로, Android/iOS는 google-services.json/plist로 자동 처리될 수 있음.
  // Web의 경우 옵션이 필수임.
  // 일단 try-catch로 감싸서 초기화 시도.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initializeApp failed: $e");
    // Web 등에서 옵션 부족으로 실패할 수 있음. 
    // 하지만 모바일(Android/iOS)은 google-services.json/plist가 있으면 옵션 없이도 가능.
  }

  KakaoSdk.init(nativeAppKey: '6daf1cc619f2e11d4d4a129475e9c3ff');

  // 저장된 토큰 복원
  await AuthSession.instance.load();
  AuthState.instance.setAuthenticated(AuthSession.instance.token != null);
  final GoRouter router = createAppRouter(AuthSession.instance.token != null);

  runApp(ProviderScope(child: MyApp(router: router)));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 시 알림 서비스 초기화 및 권한 요청
    // (빌드 후에 실행되도록 addPostFrameCallback 사용 또는 직접 호출)
    // Provider를 통해 접근하려면 ref가 필요하므로 ConsumerState 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '한방 의료 앱',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: const Color(0xFF3B82F6),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      routerConfig: widget.router,
    );
  }
}
