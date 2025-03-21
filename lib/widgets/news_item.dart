import 'package:flutter/material.dart';

class NewsItem extends StatelessWidget {
  final String title;

  const NewsItem({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}