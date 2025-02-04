import 'package:flutter/material.dart';

class StockChartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      color: Colors.grey[300],
      child: Center(child: Text('차트 자리')),
    );
  }
}
