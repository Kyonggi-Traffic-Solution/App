import 'package:flutter/material.dart';

class Mascot_Screen extends StatelessWidget {
  const Mascot_Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8FFDB),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Image.asset(
            'assets/images/01.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          
        ],
      ),
    );
  }
}