import 'package:flutter/material.dart';

class StockDetailScreen extends StatelessWidget {
  final Map<String, dynamic> stock;

  StockDetailScreen({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stock['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticker: ${stock['ticker']}'),
            SizedBox(height: 8),
            Text('Price: ${stock['price']}원'),
            SizedBox(height: 8),
            Text('Change: ${stock['change_value']}원'),
            SizedBox(height: 8),
            Text('Description: ${stock['description']}'),
            SizedBox(height: 8),
            Text('Market: ${stock['market']}'),
            SizedBox(height: 8),
            Text('Quantity: ${stock['quantity']}'),
            SizedBox(height: 8),
            Text(
              stock['change_value'] > 0
                  ? 'Price increased by ${stock['rise_percent']}%'
                  : 'Price decreased by ${stock['fall_percent']}%',
              style: TextStyle(
                color: stock['change_value'] > 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
