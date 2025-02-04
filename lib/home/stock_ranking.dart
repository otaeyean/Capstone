import 'package:flutter/material.dart';

class StockRanking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('실시간 랭킹', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('국내', style: TextStyle(color: Colors.blue)),
            SizedBox(width: 20),
            Text('해외', style: TextStyle(color: Colors.blue)),
          ],
        ),
        SizedBox(height: 20),
        // 실시간 랭킹 리스트 불러오기
        Placeholder(fallbackHeight: 200), // 임시로 Placeholder로 대체
      ],
    );
  }
}
