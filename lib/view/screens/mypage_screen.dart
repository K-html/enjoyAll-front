import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

// MyPageScreen: 사용자 정보 화면
class MyPageScreen extends StatefulWidget {
  final String email; // 사용자 이메일

  MyPageScreen({required this.email, required String nickname});

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String _nickname = ''; // 사용자 닉네임

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname') ?? 'User';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // 로그인 토큰 삭제
    await prefs.remove('nickname'); // 닉네임 삭제

    // 로그아웃 후 로그인 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9), // 배경색 설정
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50), // 상단 여백 추가
            Text(
              '안녕하세요',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'GmarketSansTTFBold',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '$_nickname님',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'GmarketSansTTFBold',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.email,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'GmarketSansTTFBold',
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final updatedNickname = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountEditScreen(
                          nickname: _nickname,
                        ),
                      ),
                    );
                    if (updatedNickname != null) {
                      setState(() {
                        _nickname = updatedNickname;
                      });
                    }
                  },
                  child: Text(
                    '계정관리',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'GmarketSansTTFBold',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE7E7E7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '대충 광고',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'GmarketSansTTFBold',
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Divider(color: Colors.grey),
            ListTile(
              title: Text(
                '내 정보 수정',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'GmarketSansTTFBold',
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // 내 정보 수정 클릭 시 처리
              },
            ),
            ListTile(
              title: Text(
                '고객센터',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'GmarketSansTTFBold',
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // 고객센터 클릭 시 처리
              },
            ),
            ListTile(
              title: Text(
                '이용약관',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'GmarketSansTTFBold',
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // 이용약관 클릭 시 처리
              },
            ),
            ListTile(
              title: Text(
                '앱 정보',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'GmarketSansTTFBold',
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // 앱 정보 클릭 시 처리
              },
            ),
            Spacer(),
            Center(
              child: GestureDetector(
                onTap: _logout, // 로그아웃 기능 실행
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'GmarketSansTTFMedium',
                    fontSize: 14,
                    decoration: TextDecoration.underline, // 밑줄 추가
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// AccountEditScreen: 사용자 정보 수정 화면
class AccountEditScreen extends StatefulWidget {
  final String nickname;

  AccountEditScreen({required this.nickname});

  @override
  _AccountEditScreenState createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.nickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveNickname() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', _nicknameController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('닉네임이 저장되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9), // 배경색 설정
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '계정 관리',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'GmarketSansTTFBold',
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            SizedBox(height: 24),
            _buildTextField(_nicknameController, '닉네임'),
            SizedBox(height: 36),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue, // 버튼 색상 변경
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // 버튼 모서리 둥글게
                ),
              ),
              onPressed: () async {
                await _saveNickname();
                Navigator.of(context).pop(_nicknameController.text);
              },
              child: Text(
                '저장',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'GmarketSansTTFBold',
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: Colors.black, // 텍스트 색상 설정
        fontFamily: 'GmarketSansTTFMedium',
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.black,
          fontFamily: 'GmarketSansTTFBold',
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}
