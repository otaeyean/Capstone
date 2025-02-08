import 'package:flutter/material.dart';
import '../investment/stock_detail_screen.dart';

class StockListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> myStocks = [
    {"name": "테슬라", "price": "1,234원", "change": "-37(2.8%)"},
    {"name": "애플", "price": "1,234원", "change": "-37(2.8%)"},
    {"name": "삼성전자", "price": "1,234원", "change": "+37(2.8%)"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: myStocks.map((stock) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StockDetailScreen(stock: stock)),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 5),
            elevation: 1,
            child: ListTile(
              title: Text(stock["name"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(stock["price"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(stock["change"], style: TextStyle(color: stock["change"].contains("+") ? Colors.red : Colors.blue)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
