import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_data.dart';
import 'package:stockapp/investment/stock_detail_screen.dart';

class StockListWidget extends StatefulWidget {
  @override
  _StockListWidgetState createState() => _StockListWidgetState();
}

class _StockListWidgetState extends State<StockListWidget> {
  List<UserStockData> userStocks = [];

  @override
  void initState() {
    super.initState();
    _loadUserStocks();
  }

  // 🔹 사용자 보유 주식 불러오기
  Future<void> _loadUserStocks() async {
    List<UserStockData> stocks = await loadUserStockData();
    setState(() {
      userStocks = stocks.take(3).toList(); // 최대 3개만 표시
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: userStocks.map((stock) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StockDetailScreen(stock: {
                  'name': stock.name,
                  'price': stock.price,
                  'rise_percent': stock.risePercent ?? 0.0,
                  'fall_percent': stock.fallPercent ?? 0.0,
                  'quantity': stock.quantity,
                }),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 5),
            elevation: 1,
            child: ListTile(
              title: Text(stock.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${stock.price} 원', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    stock.risePercent > 0
                        ? "+${stock.risePercent.toStringAsFixed(2)}%"
                        : "-${stock.fallPercent.toStringAsFixed(2)}%",
                    style: TextStyle(
                      color: stock.risePercent > 0 ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
