import 'package:flutter/material.dart';
import 'mascot_screen.dart';
import 'safety_video_screen.dart';
import 'report_violation_screen.dart';
import 'safety_news_screen.dart';
import 'my_reports_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  // 지연 로딩을 위한 화면 선택 메서드
  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return Mascot_Screen(key: UniqueKey()); // 키 추가
      case 1:
        return SafetyVideoScreen(key: UniqueKey());
      case 2:
        return ReportViolationScreen(key: UniqueKey());
      case 3:
        return SafetyNewsScreen(key: UniqueKey());
      case 4:
        return MyReportsScreen(key: UniqueKey());
      default:
        return Mascot_Screen(key: UniqueKey());
    }
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(), // 지연 로딩 적용
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '마스코트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: '안전영상',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: '신고하기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.park),
            label: '관련뉴스',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '내 신고',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}