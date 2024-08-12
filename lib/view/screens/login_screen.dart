import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'categoryselect_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  @override
  void initState() {
    super.initState();

    KakaoSdk.init(
      nativeAppKey: 'a992f248ec54d8a88ff00f88d7425feb',
      javaScriptAppKey: '4a74843fd13336d98e21499d3a256135',
    );
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email == 'test' && password == 'test') {
      await _saveJwtToken('dummy_test_token');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CategorySelectScreen()),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://your-backend-api.com/login'),
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
        await _saveJwtToken(responseData['token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CategorySelectScreen()),
        );
      } else {
        setState(() {
          _errorMessage = '아이디와 비밀번호가 일치하지 않습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '로그인 중 오류가 발생했습니다. 다시 시도해주세요.';
      });
    }
  }

  Future<void> _loginWithKakao() async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        // 카카오톡 앱을 통해 로그인
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오 계정 웹뷰로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 로그인 성공 후 사용자 정보 가져오기
      User user = await UserApi.instance.me();
      String? nickname = user.kakaoAccount?.profile?.nickname;
      String? email = user.kakaoAccount?.email;
      String? id = user.id.toString();

      print('닉네임: $nickname');
      print('이메일: $email');
      print("회원번호: $id");

      if (nickname != null && email != null && id != null) {
        await _registerUser(nickname, email, id);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CategorySelectScreen()),
        );
      } else {
        setState(() {
          _errorMessage = '카카오에서 사용자 정보를 가져올 수 없습니다.';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = '카카오 로그인 중 오류가 발생했습니다.';
      });
      print('카카오 로그인 실패: $error');
    }
  }

  Future<void> _registerUser(String nickname, String email, String id) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-backend-api.com/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'nickname': nickname,
          'email': email,
          'id': id, // 회원번호를 포함하여 전송
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await _saveJwtToken(responseData['token']);
      } else {
        setState(() {
          _errorMessage = '회원가입 중 오류가 발생했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '회원가입 중 오류가 발생했습니다.';
      });
    }
  }

  Future<void> _saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
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
                        onTap: _login,
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
                        onTap: _loginWithKakao,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFFF7E300),
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
                                color: Colors.black,
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
