import 'package:flutter/material.dart';

class StockList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('내 종목 목록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        // 내 종목보기 내용을 여기에 추가
        Placeholder(fallbackHeight: 100), // 임시로 Placeholder로 대체
      ],
    );
  }
}
