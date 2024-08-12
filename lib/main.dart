import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // Kakao SDK 패키지 임포트
import 'package:khtml_hackathon_fe/view/screens/splash_screen.dart';

void main() {
  KakaoSdk.init(nativeAppKey: 'cf72c449254527e96b9113645e895f57');
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: LoadingMobile(), // 앱이 시작될 때 LoadingMobile 스크린을 먼저 보여줍니다.
    );
  }
}
