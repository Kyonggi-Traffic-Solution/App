import 'package:flutter/material.dart';
import '../widgets/report_item.dart';

class MyReportsScreen extends StatelessWidget {

  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 신고 내역', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('신고자 목록을 보실 분은 관리자에게 문의하세요.', style: TextStyle(fontSize: 14)),
            SizedBox(height: 16),
            ReportItem(
              title: '신고 1', 
              description: '2023년 04월 15일 주변에서 담배피는 사람 발견'
            ),
            SizedBox(height: 16),
            ReportItem(
              title: '신고 2', 
              description: '2023년 04월 18일 공원 내 시설물 파손 발견'
            ),
          ],
        ),
      ),
    );
  }
}