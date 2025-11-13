// lib/main.dart (전체 덮어쓰기)

import 'package:flutter/material.dart';
import 'package:hanbang_app/signup_screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
// [수정됨] 1. 한글 언어 설정을 위한 임포트
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(nativeAppKey: '6daf1cc619f2e11d4d4a129475e9c3ff'); 
 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '한방 의료 어플',
      theme: ThemeData(
        fontFamily: 'Roboto', 
        primaryColor: const Color(0xFF3B82F6),
      ),
      debugShowCheckedModeBanner: false,
      
      // [수정됨] 2. 한글 날짜(DateFormat)를 위한 로케일 설정
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어 (기본값)
      ],
      locale: const Locale('ko', 'KR'), // 앱의 기본 언어를 한국어로 설정

      home: const SignUpScreen(), 
    );
  }
}