import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';
import 'favorite_screen.dart';
import 'mypage_screen.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  List<Map<String, String>> _favorites = [];
  Set<String> selectedCategories = {};
  String? _nickname; // 닉네임 변수 추가
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadSelectedCategories();
    _loadUserInfo(); // 사용자 정보 로드
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteList = prefs.getStringList('favorites');
    if (favoriteList != null) {
      setState(() {
        _favorites = favoriteList
            .map((e) => Map<String, String>.from(jsonDecode(e)))
            .toList();
      });
    }
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email');
      _nickname = prefs.getString('nickname') ?? 'User';
      print('Nickname loaded: $_nickname');
      print('Email loaded: $_email');
    });
  }

  Future<void> _loadSelectedCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? selectedList = prefs.getStringList('selectedCategories');
    if (selectedList != null) {
      setState(() {
        selectedCategories = selectedList.toSet();
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          Mobile(
            favorites: _favorites,
            onFavoriteToggle: _toggleFavorite,
            selectedCategories: selectedCategories,
          ),
          ChatScreen(onBack: _onBackFromChat),
          FavoriteScreen(favorites: _favorites),
          MyPageScreen(
            email: _email ?? 'user@example.com',
            initialNickname: _nickname ?? 'User',
          ),
        ],
      ),
      bottomNavigationBar: _selectedIndex == 1
          ? null
          : Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.white),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.chat), label: 'Chat'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.favorite), label: 'Favorites'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'My'),
                ],
              ),
            ),
    );
  }

  void _toggleFavorite(Map<String, String> item) {
    setState(() {
      if (_favorites.any((favorite) => mapEquals(favorite, item))) {
        _favorites.removeWhere((favorite) => mapEquals(favorite, item));
      } else {
        _favorites.add(item);
      }
    });
    _saveFavorites();
  }

  Future<void> _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteList = _favorites.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('favorites', favoriteList);
  }

  void _onBackFromChat() {
    _onItemTapped(0);
  }
}

class Mobile extends StatefulWidget {
  final List<Map<String, String>> favorites;
  final Function(Map<String, String>) onFavoriteToggle;
  final Set<String> selectedCategories;

  const Mobile({
    Key? key,
    required this.favorites,
    required this.onFavoriteToggle,
    required this.selectedCategories,
  }) : super(key: key);

  @override
  _MobileState createState() => _MobileState();
}

class _MobileState extends State<Mobile> {
  bool isPopularOrder = false;
  bool isCategorySectionVisible = false;

  final List<Map<String, String>> data = [
    {
      'title': '자녀 학업 장려금 지원 (행사 정보 요약)',
      'date': '2024. 7. 1.(월) ~ 26.(금)',
      'category1': '교육',
      'category2': '장학금',
      'details': '자녀 학업 장려금에 대한 상세 내용이 여기에 들어갑니다.\n'
          '자녀 학업 장려금에 대한 상세 내용이 여기에 들어갑니다.'
    },
    {
      'title': '청소년 여름캠프 안내',
      'date': '2024. 8. 10.(토) ~ 15.(목)',
      'category1': '캠프',
      'category2': '청소년',
      'details': '청소년 여름캠프에 대한 상세 내용이 여기에 들어갑니다.',
    },
    {
      'title': 'test1',
      'date': '2024. 7. 1.(월) ~ 26.(금)',
      'category1': '11',
      'category2': '111',
      'details': 'test111111',
    },
    {
      'title': 'test2',
      'date': '2024. 8. 10.(토) ~ 15.(목)',
      'category1': '22',
      'category2': '222',
      'details': 'test22222',
    },
  ];

  final List<String> categories = [
    '저소득복지',
    '보훈대상자',
    '사회복지시설',
    '어르신',
    '장애인',
    '아동',
    '여성',
    '청년',
    '주거복지',
  ];

  Future<void> _saveSelectedCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> selectedList = widget.selectedCategories.toList();
    await prefs.setStringList('selectedCategories', selectedList);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildCategorySection(),
          Expanded(
            child: _buildContentSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryButton('카테고리'),
              const SizedBox(width: 140),
              _buildToggleButtons(),
            ],
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFF909090),
        ),
      ],
    );
  }

  Widget _buildCategoryButton(String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isCategorySectionVisible = !isCategorySectionVisible;
        });
      },
      child: Container(
        width: 91,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 1, color: const Color(0xFF8C8C8C)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'GmarketSansTTFBold',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            Icon(
              isCategorySectionVisible
                  ? Icons.arrow_drop_up
                  : Icons.arrow_drop_down,
              color: Colors.black,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      width: 140,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0x00ACACAC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: const Color(0xFF727272)),
      ),
      child: Row(
        children: [
          _buildToggleButton('조회순', !isPopularOrder, () {
            setState(() {
              isPopularOrder = false;
            });
          }),
          _buildToggleButton('마감순', isPopularOrder, () {
            setState(() {
              isPopularOrder = true;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      String text, bool isSelected, VoidCallback onPressed) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5263FC) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(width: 1, color: const Color(0xFF8C8C8C))
                : null,
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 12,
                fontFamily: 'GmarketSansTTFBold',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    if (!isCategorySectionVisible) return SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = widget.selectedCategories.contains(category);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 12,
                  fontFamily: 'GmarketSansTTFBold',
                  fontWeight: FontWeight.w500,
                ),
                backgroundColor: Color(0xFFFBFBFB),
                selectedColor: Colors.blue,
                checkmarkColor: Colors.white,
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (isSelected) {
                      widget.selectedCategories.remove(category);
                    } else {
                      widget.selectedCategories.add(category);
                    }

                    _saveSelectedCategories(); // 변경된 카테고리를 저장

                    // 선택된 카테고리 목록을 출력
                    print('Selected Categories: ${widget.selectedCategories}');
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final isFavorite =
            widget.favorites.any((favorite) => mapEquals(favorite, item));
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
                isFavorite: isFavorite,
                onFavoriteToggle: () {
                  widget.onFavoriteToggle(item);
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentCard({
    required String title,
    required String date,
    required String category1,
    required String category2,
    required bool isFavorite,
    required VoidCallback onFavoriteToggle,
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
              Spacer(),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.yellow : Colors.black,
                ),
                onPressed: onFavoriteToggle,
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

class DetailScreen extends StatelessWidget {
  final String title;
  final String date;
  final String category1;
  final String category2;
  final String details; // 상세 내용을 받을 변수 추가

  const DetailScreen({
    Key? key,
    required this.title,
    required this.date,
    required this.category1,
    required this.category2,
    required this.details, // 추가된 변수
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/image.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "GmarketSansTTFBold",
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: "GmarketSansTTFBold",
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildTag(category1),
                          const SizedBox(width: 10),
                          _buildTag(category2),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        details, // 상세 내용 표시
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "GmarketSansTTFBold",
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 16,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.share, color: Colors.black),
              onPressed: () {
                // 공유 버튼 동작 구현
              },
            ),
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
