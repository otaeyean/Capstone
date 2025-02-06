import 'package:flutter/material.dart';

class StockChangeInfo extends StatelessWidget {
  final Map<String, dynamic> stock;
  StockChangeInfo({required this.stock});

  @override
  Widget build(BuildContext context) {
    bool isPositive = stock['change_value'] > 0;
    return Text(
      '어제보다 ${isPositive ? '+' : ''}${stock['change_value']}원 (${isPositive ? stock['rise_percent'] : stock['fall_percent']}%)',
      style: TextStyle(
        color: isPositive ? Colors.red : Colors.blue,
        fontSize: 13,
      ),
    );
  }
}
