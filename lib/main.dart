import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'app_router.dart';
import 'core/services/auth_session.dart';
import 'core/services/auth_state.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Firebase 초기화 (웹/모바일 대응)
  try {
    if (kIsWeb) {
      // 웹 환경에서는 최소한의 옵션이라도 필요합니다.
      // (실제 프로젝트의 Firebase 웹 설정값으로 교체하는 것이 좋지만, 
      //  일단 초기화 실패로 앱이 멈추는 것을 방지합니다.)
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "dummy-api-key",
          appId: "dummy-app-id",
          messagingSenderId: "dummy-sender-id",
          projectId: "medicalstandard-a4a3e",
        ),
      );
    } else {
      // 모바일은 설정 파일 기반으로 자동 초기화
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase initializeApp skipped or failed: $e");
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 알림 서비스 초기화 (초기화 실패 시 내부적으로 무시됨)
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
