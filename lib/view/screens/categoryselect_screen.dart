import 'package:flutter/material.dart';

import 'main_screen.dart';

class CategorySelectScreen extends StatefulWidget {
  final Function(String) onKeywordSelected;

  CategorySelectScreen({required this.onKeywordSelected});

  @override
  _CategorySelectScreenState createState() => _CategorySelectScreenState();
}

class _CategorySelectScreenState extends State<CategorySelectScreen> {
  Set<String> selectedCategories = {};
  String _errorMessage = '';

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

  void _onConfirm() {
    if (selectedCategories.isNotEmpty) {
      String selectedKeyword = selectedCategories.first;
      widget.onKeywordSelected(selectedKeyword);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      setState(() {
        _errorMessage = '카테고리를 하나 이상 선택해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '카테고리 선택',
          style: TextStyle(
            fontFamily: 'GmarketSansTTFBold',
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected =
                      selectedCategories.contains(category['name']);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedCategories.remove(category['name']);
                        } else {
                          selectedCategories.add(category['name']);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF4051E8) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'],
                            size: 48,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          SizedBox(height: 8),
                          Text(
                            category['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _onConfirm,
              child: Text('확인'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Color(0xFF4051E8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
