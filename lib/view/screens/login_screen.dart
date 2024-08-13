import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'categoryselect_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _errorMessage = '';
  String? _email;
  String? _id;
  String? _nickname;

  @override
  void initState() {
    super.initState();
    KakaoSdk.init(
      nativeAppKey: 'a992f248ec54d8a88ff00f88d7425feb',
      javaScriptAppKey: '4a74843fd13336d98e21499d3a256135',
    );
  }

  Future<void> _saveJwtTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_access_token', accessToken);
    await prefs.setString('jwt_refresh_token', refreshToken);
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    print('Email saved: $email'); // 저장된 이메일 확인 로그
  }

  Future<void> _saveNickname(String nickname) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isSaved = await prefs.setString('nickname', nickname);
      print('Nickname saved: $nickname, Result: $isSaved');
    } catch (e) {
      print('Failed to save nickname: $e');
    }
  }

  Future<void> _loginWithKakao() async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      User user = await UserApi.instance.me();
      _email = user.kakaoAccount?.email;
      _id = user.id.toString();
      _nickname = user.kakaoAccount?.profile?.nickname;

      print('이메일: $_email');
      print('회원번호: $_id');
      print('닉네임: $_nickname');

      if (_email != null) {
        await _saveEmail(_email!); // 이메일 저장
      }

      if (_email != null && _id != null && _nickname != null) {
        final result = await _checkUserStatus(_id!, _email!);

        print('result 타입: ${result.runtimeType}');
        print('result 값: $result');

        if (result is Map<String, dynamic>) {
          print('Map 타입의 result 반환.');
          final tokens = Map<String, String>.from(result);

          // JWT 토큰을 Map에서 직접 접근하여 사용합니다.
          final jwtAccessToken = tokens['#jwtAccessToken'];
          final jwtRefreshToken = tokens['#jwtRefreshToken'];

          if (jwtAccessToken != null && jwtRefreshToken != null) {
            await _saveJwtTokens(jwtAccessToken, jwtRefreshToken);
          } else {
            print('JWT 토큰이 null입니다.');
            setState(() {
              _errorMessage = 'JWT 토큰이 유효하지 않습니다.';
            });
            return;
          }

          if (_nickname != null) {
            await _saveNickname(_nickname!);
          } else {
            print('닉네임이 null입니다. 저장할 수 없습니다.');
          }
          await _saveNickname(_nickname!);
          print('메인 페이지로 이동합니다.3');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
          return; // 추가적인 코드 실행을 방지하기 위해 return
        } else if (result is int) {
          print('int 타입의 result 반환.');
          int userId = result;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CategorySelectScreen(
                onKeywordSelected: (selectedKeyword) =>
                    _onKeywordSelected(selectedKeyword, userId, _nickname!),
              ),
            ),
          );
          return; // 추가적인 코드 실행을 방지하기 위해 return
        } else {
          print('예상치 못한 result 타입: ${result.runtimeType}');
          setState(() {
            _errorMessage = '사용자 상태 확인 중 오류가 발생했습니다.';
          });
        }
      } else {
        print('카카오 사용자 정보가 null로 반환되었습니다.');
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

  Future<void> _onKeywordSelected(
      String selectedKeyword, int userId, String nickname) async {
    print('서버로 전달될 selectedKeyword: $selectedKeyword'); // 로그 추가
    final joinSuccess =
        await _joinUser(userId.toString(), nickname, selectedKeyword);
    if (mounted) {
      if (joinSuccess) {
        await _saveNickname(_nickname!);
        print('메인 페이지로 이동합니다.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage = '회원가입 중 오류가 발생했습니다. 다시 시도해주세요.';
        });
      }
    }
  }

  Future<dynamic> _checkUserStatus(String id, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jwtAccessToken = prefs.getString('jwt_access_token');

      final response = await http.post(
        Uri.parse('http://175.45.205.178/auth/kakao'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtAccessToken',
        },
        body: jsonEncode(<String, String>{
          '#socialId': id,
          '#socialEmail': email,
        }),
      );

      print('auth/kakao 응답 상태 코드: ${response.statusCode}');
      print('auth/kakao 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['result'] != null &&
            responseData['result'] is Map<String, dynamic>) {
          final tokens = responseData['result'];

          await _saveJwtTokens(
            tokens['#jwtAccessToken'],
            tokens['#jwtRefreshToken'],
          );
          await _saveNickname(_nickname!);

          print('메인 페이지로 이동합니다.2');
          return tokens; // 정상적인 경우, tokens 반환
        } else {
          print('서버 응답에 예상하지 못한 데이터 구조.');
          return 'unexpected_data'; // 명확한 오류 메시지 반환
        }
      } else if (response.statusCode == 403) {
        final responseData = jsonDecode(response.body);
        if (responseData['result'] is int) {
          return responseData['result']; // 예상된 결과
        } else {
          print('서버에서 예상하지 못한 데이터 형식을 반환했습니다.');
          return 'unexpected_format'; // 명확한 오류 메시지 반환
        }
      } else {
        print('예상하지 못한 상태 코드: ${response.statusCode}');
        return 'unexpected_status'; // 명확한 오류 메시지 반환
      }
    } catch (e) {
      print('auth/kakao 요청 오류: $e');
      return 'request_error'; // 명확한 오류 메시지 반환
    }
  }

  Future<bool> _joinUser(String userId, String nickname, String keyword) async {
    print('서버로 전송될 keyword: $keyword');

    try {
      final response = await http.post(
        Uri.parse('http://175.45.205.178/auth/join'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userId': userId,
          'socialName': nickname,
          'keyword': keyword,
        }),
      );

      print('auth/join 응답 상태 코드: ${response.statusCode}');
      print('auth/join 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['result'] != null) {
          await _saveJwtTokens(
            responseData['result']['#jwtAccessToken'],
            responseData['result']['#jwtRefreshToken'],
          );
          return true;
        } else {
          print('auth/join 응답 데이터가 null입니다.');
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print('auth/join 요청 오류: $e');
      return false;
    }
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
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontFamily: 'Gmarket Sans',
                      ),
                    ),
                  ),
                SizedBox(height: 20),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
