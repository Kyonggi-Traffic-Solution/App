import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();  // 바인딩 초기화 보장
 
  // 에러 핸들링 추가
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter error: ${details.exception}');
  };
  
  runApp(SafetyApp());
}

class SafetyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '안전 신고 앱',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}