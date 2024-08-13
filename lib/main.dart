import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:khtml_hackathon_fe/view/screens/splash_screen.dart';

void main() {
  KakaoSdk.init(
    nativeAppKey: 'a992f248ec54d8a88ff00f88d7425feb',
    javaScriptAppKey: '4a74843fd13336d98e21499d3a256135',
  );
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
        ),
        home: LoadingMobile()); // 앱이 시작될 때 LoadingMobile 스크린을 먼저 보여줍니다.
    // home: MainScreen());
  }
}
