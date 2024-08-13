import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  final VoidCallback onBack;

  ChatScreen({required this.onBack});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Timer _scrollTimer;
  Timer? _userScrollTimer;

  double _fontSize = 16.0;

  final List<Map<String, dynamic>> categories = [
    {'name': '저소득복지', 'icon': Icons.volunteer_activism},
    {'name': '보훈대상자', 'icon': Icons.military_tech},
    {'name': '사회복지시설', 'icon': Icons.home_work},
    {'name': '어르신', 'icon': Icons.elderly},
    {'name': '장애인', 'icon': Icons.accessible},
    {'name': '아동', 'icon': Icons.child_care},
    {'name': '여성', 'icon': Icons.woman},
    {'name': '청년', 'icon': Icons.school},
    {'name': '주거복지', 'icon': Icons.house},
  ];

  bool _isAutoScrolling = false;

  @override
  void initState() {
    super.initState();

    _loadFontSize();

    if (_messages.isEmpty) {
      _startAutoScroll();
    }

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection !=
          ScrollDirection.idle) {
        _stopAutoScroll();

        _userScrollTimer?.cancel();

        _userScrollTimer = Timer(Duration(seconds: 3), () {
          if (_messages.isEmpty) {
            _resumeAutoScroll();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _userScrollTimer?.cancel();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    });
  }

  Future<void> _saveFontSize(double fontSize) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', fontSize);
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients && _messages.isEmpty) {
        double maxScrollExtent = _scrollController.position.maxScrollExtent;
        double currentScrollPosition = _scrollController.position.pixels;

        if (currentScrollPosition >= maxScrollExtent) {
          _scrollController.jumpTo(currentScrollPosition - maxScrollExtent);
        } else {
          _scrollController.animateTo(
            currentScrollPosition + 1,
            duration: Duration(milliseconds: 1),
            curve: Curves.linear,
          );
        }
      }
    });

    _isAutoScrolling = true;
  }

  void _stopAutoScroll() {
    if (_scrollTimer.isActive) {
      _scrollTimer.cancel();
      _isAutoScrolling = false;
    }
  }

  void _resumeAutoScroll() {
    if (!_isAutoScrolling && _messages.isEmpty) {
      _startAutoScroll();
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });

    _controller.clear();

    try {
      // 서버에 요청을 보냅니다.
      final response = await http.post(
        Uri.parse('http://175.45.205.178/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': text}),
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        debugPrint('Server response: $responseBody');

        final responseData = jsonDecode(responseBody);

        // 중첩된 JSON 파싱
        final nestedMessage = jsonDecode(responseData['message']);

        final botResponse =
            nestedMessage['message'] as String? ?? '서버 응답이 없습니다.';

        setState(() {
          _messages.add(ChatMessage(text: botResponse, isUser: false));
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(text: '오류가 발생했습니다.', isUser: false));
        });
        debugPrint(
            'Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Connection error: $e');
      setState(() {
        _messages.add(ChatMessage(text: '서버에 연결할 수 없습니다.', isUser: false));
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void _sendCategoryMessage(String category) {
    final question = '$category에 대해 알고 싶어요.';
    _sendMessage(question);
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('폰트 사이즈 조절'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: _fontSize,
                    min: 10.0,
                    max: 30.0,
                    divisions: 20,
                    label: _fontSize.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                  Text('현재 폰트 크기: ${_fontSize.toStringAsFixed(1)}'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                _saveFontSize(_fontSize);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: widget.onBack,
                  ),
                  Text(
                    '다누려',
                    style: TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: 22,
                      fontFamily: 'GmarketSansTTFMedium',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.black),
                    onPressed: () {
                      _showFontSizeDialog();
                    },
                  ),
                ],
              ),
            ),
            if (_messages.isEmpty)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        '안녕하세요\n무엇을 도와드릴까요?',
                        style: TextStyle(
                          color: Color(0xFF4051E8),
                          fontSize: 25,
                          fontFamily: 'GmarketSansTTFBold',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '원하시는 카테고리를 선택하시면\n관련 혜택을 알려드립니다',
                        style: TextStyle(
                          color: Color(0xFF595858),
                          fontSize: 18,
                          fontFamily: 'GmarketSansTTFBold',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 100),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.23,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          itemCount: categories.length * 100,
                          itemBuilder: (context, index) {
                            final category =
                                categories[index % categories.length];
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                _sendCategoryMessage(category['name']);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: _buildCategoryButton(
                                    category['name'], category['icon']),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? Colors.blue[300]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              fontSize: _fontSize,
                              color: message.isUser
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: '메시지를 입력해주세요!',
                                hintStyle: TextStyle(color: Colors.black),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(fontSize: _fontSize),
                            ),
                          ),
                          Icon(Icons.mic, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        _sendMessage(_controller.text);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text, IconData icon) {
    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2, color: Color(0xFF8C8C8C)),
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.orange),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'GmarketSansTTFBold',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
