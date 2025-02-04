import 'package:flutter/material.dart';

class StockDescription extends StatelessWidget {
  final Map<String, dynamic> stock;

  StockDescription({required this.stock});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( 
      child: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '회사 소개',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              stock['description'] ?? '회사 소개 정보 없음',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
