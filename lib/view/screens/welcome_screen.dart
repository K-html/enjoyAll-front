import 'package:flutter/material.dart';

import 'login_screen.dart';

// WelcomeScreen
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 배경 이미지
            Container(
              height: 223,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/welcomescreen_image.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 텍스트 설명
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '다누려의 맞춤형 인공지능 정보 안내 \n서비스를 경험해볼까요?',
                textAlign: TextAlign.left, // 텍스트 좌측 정렬
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'GmarketSansTTFMedium',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // 버튼들
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFF0093FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: Color(0xFF555454),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '시작하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'GmarketSansTTFBold',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
