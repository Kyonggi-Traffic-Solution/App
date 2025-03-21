import 'package:flutter/material.dart';

class ReportViolationScreen extends StatelessWidget {

  const ReportViolationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위반 사항 신고하기', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('날짜', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 16),
              const Text('장소', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.location_on, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 16),
              const Text('위험한 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child:const Center(
                  child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('파일'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('위반 사항', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '위반사항을 입력해주세요',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}