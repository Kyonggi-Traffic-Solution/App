import 'package:flutter/material.dart';
import '../widgets/video_item.dart';

class SafetyVideoScreen extends StatelessWidget {
  // 키 매개변수 추가
  const SafetyVideoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('안전관계통보 영상', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        children: [
          VideoItem(
            key: ValueKey('video1'),
            title: '안전 현장 점검', 
            date: '2023.04.15'
          ),
          VideoItem(
            key: ValueKey('video2'),
            title: '안전모 착용 교육', 
            date: '2023.04.16'
          ),
          VideoItem(
            key: ValueKey('video3'),
            title: '현장 안전점검', 
            date: '2023.04.17'
          ),
          VideoItem(
            key: ValueKey('video4'),
            title: '안전벨트 착용교육', 
            date: '2023.04.18'
          ),
        ],
      ),
      // CustomBottomNavBar 제거 - MainScreen의 네비게이션만 사용
    );
  }
}