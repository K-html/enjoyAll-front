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
      'title': '경로할인제도',
      'date': '2024. 7. 1.(월) ~ 26.(금)',
      'category1': '어르신',
      'category2': '사회복지시설',
      'details': '공영경로우대제도:\n'
          '- 철도(무궁화호 이하): 운임의 30% 할인\n'
          '- 철도(새마을호·KTX): 운임의 30% 할인 (단, 토요일·공휴일 제외)\n'
          '- 수도권전철, 도시철도, 용인경전철, 고궁, 능원, 국ㆍ공립박물관, 국ㆍ공립공원, 국ㆍ공립 미술관: 운임 또는 입장료 100% 할인\n'
          '- 국·공립 국악원: 입장료 50% 이상 할인\n'
          '- 국내 항공기: 운임의 10% 할인\n'
          '- 국내 여객선: 운임의 20% 할인\n'
          '※ 경로우대를 받고자 하는 자는 주민등록증 등 연령을 확인할 수 있는 신분증을 해당 시설의 관리자에게 제시해야 합니다.\n'
    },
    {
      'title': '기초연금',
      'date': '2024. 8. 10.(토) ~ 15.(목)',
      'category1': '어르신',
      'category2': '저소득복지',
      'details': '지원대상:\n'
          '- 만65세 이상으로 소득·재산 수준(소득인정액)이 선정기준액 이하인 노인\n'
          '  (직역연금 수급권자 및 그 배우자는 지급대상에서 제외)\n'
          '선정기준:\n'
          '- 단독가구 213만원, 부부가구 340.8만원\n'
          '- 보건복지부 사이트(http://basicpension.mohw.go.kr)에서 수급 가능여부 자가 진단 가능\n'
          '급여액:\n'
          '- 소득인정액에 따라 33,480원 ~ 334,810원 차등 지급\n'
          '신청시기:\n'
          '- 만65세 생일이 속하는 달의 1개월 전부터 신청 가능\n'
          '신청기관:\n'
          '- 주소지 읍·면·동 주민센터 또는 가까운 국민연금공단 지사\n'
          '지급시기:\n'
          '- 매월 25일\n'
    },
    {
      'title': '노인복지관 운영',
      'date': '2024. 7. 1.(월) ~ 26.(금)',
      'category1': '어르신',
      'category2': '사회복지시설',
      'details': '노인복지관 현황:\n'
          '- 구분: 용인시처인노인복지관, 용인시기흥노인복지관, 용인시수지노인복지관\n'
          '위치:\n'
          '  - 용인시처인노인복지관: 처인구 중부대로 1199 (삼가동, 문화복지행정타운 내)\n'
          '  - 용인시기흥노인복지관: 기흥구 산양로 71(신갈동)\n'
          '  - 용인시수지노인복지관: 수지구 포은대로 435 (풍덕천동, 수지행정타운 내)\n'
          '개관일:\n'
          '  - 용인시처인노인복지관: 2005.9.8\n'
          '  - 용인시기흥노인복지관: 2015.2.2\n'
          '  - 용인시수지노인복지관: 2012.5.22\n'
          '시설규모:\n'
          '  - 용인시처인노인복지관: 지하1층, 지상3층\n'
          '  - 용인시기흥노인복지관: 지하1층, 지상4층\n'
          '  - 용인시수지노인복지관: 지상1층(2층만 해당)\n'
          '위탁법인:\n'
          '  - 용인시처인노인복지관: 사회복지법인연꽃마을\n'
          '  - 용인시기흥노인복지관: 사회복지법인 위드캔복지재단\n'
          '  - 용인시수지노인복지관: 사회복지법인 지구촌사회복지재단\n'
          '홈페이지:\n'
          '  - 용인시처인노인복지관: http://www.yiswc.or.kr\n'
          '  - 용인시기흥노인복지관: http://www.ygsenior.or.kr\n'
          '  - 용인시수지노인복지관: http://www.sujibokji.or.kr\n'
          '주요시설:\n'
          '  - 사무실, 상담실, 체력단련실, 이미용실, 경로식당, 강당, 사회교육실, 컴퓨터실, 장기․바독실, 탁구장, 당구장\n'
          '주요사업:\n'
          '  - 의료복지사업: 건강강좌, 방문간호, 기능회복\n'
          '  - 사회교육사업: 교양교육, 건강증진, 취미여가, 정보화교실\n'
          '  - 복리후생사업: 경로식당, 이미용, 쉼터\n'
          '  - 지역복지사업: 어버이날, 노인의 날 행사, 결식, 결연 물품후원\n'
          '  - 자원봉사사업: 실버인력뱅크 운영\n'
    },
    {
      'title': '무료급식지원',
      'date': '2024. 8. 10.(토) ~ 15.(목)',
      'category1': '어르신',
      'category2': '저소득복지',
      'details': '저소득재가노인식사배달:\n'
          '- 지원대상: 거동이 불편하거나 기타 부득이한 사유로 점심을 거르는 60세 이상 기초생활수급 노인 및 차상위계층 노인\n'
          '- 사업수행기관: 2개소(인보노인복지센터, (사)아름다운미래커뮤니티)\n'
          '- 신청문의: 주소지 읍면동 주민센터\n\n'
          '경로식당 무료급식:\n'
          '- 지원대상: 60세 이상 기초생활수급 노인 및 차상위계층 노인\n'
          '- 사업수행기관: 3개소 (처인노인복지관, 기흥노인복지관, 수지노인복지관)\n'
    },
    {
      'title': '노인돌봄서비스',
      'date': '2024. 8. 10.(토) ~ 15.(목)',
      'category1': '어르신',
      'category2': '사회복지시설',
      'details': '노인맞춤돌봄서비스:\n'
          '- 사업대상: 65세 이상 기초생활수급자, 차상위, 기초연금 대상자 중 독거, 고령부부, 신체기능 저하 등 돌봄이 필요한 노인\n'
          '  ※ 장기요양등급, 재가지원서비스 중복지원 제외\n'
          '- 사업내용: 안전·안부확인, 일상생활(식사, 외출동행 등) 지원, 말벗, 지역 서비스 연계 등\n'
          '- 신청문의: 관할 읍면동 주민센터\n'
          '  ※ 맞춤돌봄서비스 수행기관 9개소\n\n'
          '재가노인지원서비스:\n'
          '- 사업대상: 위기상황으로 돌봄이 필요한 65세 이상\n'
          '  ※ 장기요양등급, 노인맞춤돌봄 중복지원 제외\n'
          '- 사업내용: 사례관리, 위기관리, 지역 서비스 연계 등\n'
          '- 신청문의: 주소지 읍면동 주민센터\n'
          '  ※ 재가지원서비스 기관 5개소\n\n'
          '독거노인응급안전안심서비스:\n'
          '- 사업대상: (독거노인) 실제로 혼자 살고 있는 65세 이상의 노인\n'
          '  (노인2인가구) 기초생활수급자, 차상위 및 기초연금수급자 중 한명이 건강취약 또는 모두 75세 이상\n'
          '  (조손가구) 65세 이상의 노인과 손·자녀 24세로 구성된 가구\n'
          '- 사업내용: 가정 내 화재·가스·동작감지기 등을 설치하여 모니터링 및 응급상황 대처\n'
          '- 신청문의: 주소지 읍면동 주민센터\n'
          '  ※ 수행기관: 용인시처인노인복지관\n\n'
          '용인 실버케어 순이 (비대면 AI 돌봄서비스):\n'
          '- 사업대상: 65세 이상 일상생활이 가능한 1~2인 가구 중 유사 돌봄서비스 미이용자\n'
          '- 사업내용: 웨어러블 손목밴드를 통한 행동이력 데이터를 축적·분석하여 앱알림으로 24시간 정보제공\n'
          '  축적된 데이터를 통해 행동개선 및 이상징후 알림으로 위험요인 사전 예방\n'
          '  ※ 운동량 알림, 식사 및 복약 횟수·간격 경고, 미기상, 미식사 알림 등\n'
          '  일상 생활관리 및 보호자(자녀) 알림서비스 제공\n'
          '- 신청문의: 주소지 읍면동 주민센터\n\n'
          '독거노인 공동생활 카네이션 하우스:\n'
          '- 사업대상: 만65세 이상 독거 노인\n'
          '- 사업내용: 친목 도모, 프로그램(웃음치료, 요리활동 등) 제공\n'
          '- 신청문의: 용인시 사랑의 집(☎031-338-5100)\n'
    },
    {
      'title': '월동난방비 지원',
      'date': '2024. 8. 10.(토) ~ 15.(목)',
      'category1': '어르신',
      'category2': '저소득복지',
      'details': '현황:\n'
          '- 지원대상: 국민기초생활보장 수급자 중 노인 개별가구(독거노인)\n'
          '- 지급시기: 1, 2, 3, 11, 12월 (연간 5개월)\n'
          '- 지급액: 가구당 월 50,000원\n'
    },
    {
      'title': '노인 장기요양 보험제도',
      'date': '2024. 8. 10.(토) ~ 15.(목)',
      'category1': '어르신',
      'category2': '장애인',
      'details': '이용대상:\n'
          '- 65세 이상 노인 또는 65세 미만 노인성질환을 가진 자로서 거동이 현저히 불편하여 장기요양등급(1~5등급, 인지지원등급)이 인정된 자\n'
          '01 국민건강보험공단:\n'
          '   - 장기요양인정신청 및 방문조사\n'
          '02 등급판정위원회:\n'
          '   - 장기요양인정 및 장기요양등급판정\n'
          '03 국민건강보험공단:\n'
          '   - 장기요양인정서, 개인별장기요양 이용계획서 송부\n'
          '04 장기요양기관:\n'
          '   - 장기요양 급여이용계약 및 장기요양 급여제공\n\n'
          '입소비용:\n'
          '- 본인부담금: 15~20%\n'
          '- 맞춤형 의료급여수급자: 지방자치단체 지원 (본인부담 없음)\n'
          '- 기타 의료급여수급자 및 일반인: 6~8% 본인부담\n\n'
          '기타 자세한 내용은 아래 <노인장기요양보험 홍보자료>를 참고해주시기 바랍니다.\n'
          '시행기관: 국민건강보험 공단\n'
          'Homepage: www.longtermcare.or.kr\n'
          '전화문의: 1577-1000\n',
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
