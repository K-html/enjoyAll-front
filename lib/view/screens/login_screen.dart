import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = ''; // 에러 메시지 상태를 저장할 변수

  @override
  void initState() {
    super.initState();
    KakaoSdk.init(
        nativeAppKey: 'cf72c449254527e96b9113645e895f57'); // 카카오 SDK 초기화
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    // 테스트용 계정과 비밀번호 확인
    if (email == 'test' && password == 'test') {
      // 아이디와 비밀번호가 "test"일 경우 메인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
      return; // 메인 페이지로 이동 후 이 메서드를 종료
    }

    try {
      final response = await http.post(
        Uri.parse('https://your-backend-api.com/login'), // 백엔드 로그인 API 주소
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await _saveJwtToken(responseData['token']); // JWT 토큰 저장
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()), // 메인 화면으로 이동
        );
      } else {
        setState(() {
          _errorMessage = '아이디와 비밀번호가 일치하지 않습니다.'; // 에러 메시지 설정
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '로그인 중 오류가 발생했습니다. 다시 시도해주세요.'; // 에러 메시지 설정
      });
    }
  }

  Future<void> _loginWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        // 카카오톡이 설치되어 있으면 카카오톡으로 로그인
        await UserApi.instance.loginWithKakaoTalk();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()), // 메인 화면으로 이동
        );
      } catch (error) {
        if (error is PlatformException && error.code == 'CANCELED') {
          return; // 사용자가 로그인 취소한 경우 처리
        }
        try {
          // 카카오톡 로그인 실패 시, 카카오 계정으로 로그인 시도
          await UserApi.instance.loginWithKakaoAccount();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()), // 메인 화면으로 이동
          );
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error'); // 오류 메시지 출력
        }
      }
    } else {
      try {
        // 카카오톡이 설치되어 있지 않으면 카카오 계정으로 로그인
        await UserApi.instance.loginWithKakaoAccount();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()), // 메인 화면으로 이동
        );
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error'); // 오류 메시지 출력
      }
    }
  }

  Future<void> _saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token); // JWT 토큰을 로컬에 저장
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 63),
                  child: Column(
                    children: [
                      FlutterLogo(size: 24),
                      SizedBox(height: 20),
                      Text(
                        'LOGIN',
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 20,
                          fontFamily: 'Gmarket Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      if (_errorMessage.isNotEmpty) ...[
                        // 에러 메시지 표시
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontFamily: 'Gmarket Sans',
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: '이메일을 입력하세요',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력하세요',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _login, // 로그인 시도
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 1,
                              color: Color(0xFF555454),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '로그인하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Gmarket Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 하단 소셜 로그인 및 기타 항목
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'SNS계정으로 로그인하기',
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 15,
                          fontFamily: 'Gmarket Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: _loginWithKakao, // 카카오톡 로그인 시도
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFFF7E300), // 카카오톡 노란색
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 1,
                              color: Color(0xFF555454),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '카카오톡으로 로그인하기',
                              style: TextStyle(
                                color: Colors.black, // 카카오톡 로고 색상
                                fontSize: 15,
                                fontFamily: 'Gmarket Sans',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            width: 1,
                            color: Color(0xFF555454),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '계정이 없으신가요? 간편가입하기',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'Gmarket Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '아이디 (이메일) 찾기',
                            style: TextStyle(
                              color: Color(0xFF636060),
                              fontSize: 12,
                              fontFamily: 'Gmarket Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '비밀번호 찾기',
                            style: TextStyle(
                              color: Color(0xFF636060),
                              fontSize: 12,
                              fontFamily: 'Gmarket Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
