import 'package:flutter/material.dart';

class StockInfo extends StatelessWidget {
  final Map<String, dynamic> stock;

  const StockInfo({required this.stock, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String stockCode = stock['stockCode'] ?? '';
    final bool isOverseas = stockCode.contains(RegExp(r'[A-Za-z]')); // 알파벳 포함 여부로 해외 판단

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stock['name'],
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          isOverseas
              ? '\$${stock['price']}' // 해외는 달러 표시
              : '${stock['price']}원', // 국내는 원화
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
