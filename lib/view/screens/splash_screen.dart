import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';
import 'welcome_screen.dart';

class LoadingMobile extends StatefulWidget {
  @override
  _LoadingMobileState createState() => _LoadingMobileState();
}

class _LoadingMobileState extends State<LoadingMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward(); // 애니메이션 시작

    // 애니메이션이 끝나면 로그인 상태를 확인 후 다음 화면으로 이동
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateBasedOnLoginStatus();
      }
    });
  }

  Future<void> _navigateBasedOnLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');

    if (jwt != null && jwt.isNotEmpty) {
      // JWT가 존재하면 메인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      // JWT가 없으면 웰컴 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(seconds: 2),
              curve: Curves.easeOut,
              left: MediaQuery.of(context).size.width * -0.48 +
                  _controller.value *
                      (MediaQuery.of(context).size.width * 0.55),
              top: MediaQuery.of(context).size.height * 0.08,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF132AFA), Colors.white],
                  ),
                  shape: OvalBorder(),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 2),
              curve: Curves.easeOut,
              right: MediaQuery.of(context).size.width * -0.48 +
                  _controller.value *
                      (MediaQuery.of(context).size.width * 0.55),
              bottom: MediaQuery.of(context).size.height * 0.08,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF8F8F8), Color(0x99132AFA)],
                  ),
                  shape: OvalBorder(),
                ),
              ),
            ),
            Center(
              child: Text(
                '다누려',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'GmarketSansTTFBold',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
