// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hanbang_app/signup_screen.dart'; // 1. 우리가 만든 파일 import
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // [수정됨] 1. Kakao SDK 임포트

void main() async { // [수정됨] 2. async 추가
  // [수정됨] 3. runApp 전에 Flutter 바인딩을 보장합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // [수정됨] 4. ★ 여기에 사용자 키를 삽입했습니다 ★
  KakaoSdk.init(nativeAppKey: '6daf1cc619f2e11d4d4a129475e9c3ff'); 
 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '한방 의료 어플', // 사용자가 수정한 title 유지
      theme: ThemeData(
        // 앱 전체에 일관된 폰트 적용 (HTML 스타일과 유사하게)
        fontFamily: 'Roboto', 
        primaryColor: const Color(0xFF3B82F6), // 기본 색상
      ),
      debugShowCheckedModeBanner: false, // 오른쪽 위 'DEBUG' 배너 숨기기
      
      // 2. 앱의 '홈' 화면을 SignUpScreen으로 지정
      home: const SignUpScreen(), 
    );
  }
}