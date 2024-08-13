import 'package:flutter/material.dart';

import 'main_screen.dart';

class FavoriteScreen extends StatelessWidget {
  final List<Map<String, String>> favorites;

  const FavoriteScreen({Key? key, required this.favorites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),
      appBar: AppBar(
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        backgroundColor: Colors.white, // 배경 색상 흰색으로 변경
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '즐겨찾기한 행사',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        elevation: 0, // 그림자 제거
      ),
      body: favorites.isEmpty
          ? Center(
              child: Text(
                '즐겨찾기한 항목이 없습니다.',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black54,
                  fontFamily: 'GmarketSansTTFBold',
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          title: item['title']!,
                          date: item['date']!,
                          category1: item['category1']!,
                          category2: item['category2']!,
                          details: item['details']!,
                          imagePath: item['imagePath'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      _buildContentCard(
                        title: item['title']!,
                        date: item['date']!,
                        category1: item['category1']!,
                        category2: item['category2']!,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildContentCard({
    required String title,
    required String date,
    required String category1,
    required String category2,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 300,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontFamily: 'GmarketSansTTFBold',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Container(
            width: 300,
            child: Text(
              date,
              style: const TextStyle(
                color: Color(0xFF595858),
                fontSize: 13,
                fontFamily: 'GmarketSansTTFBold',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildTag(category1),
              const SizedBox(width: 10),
              _buildTag(category2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      width: 60,
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x33ACACAC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF575050),
            fontSize: 11,
            fontFamily: 'GmarketSansTTFBold',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
