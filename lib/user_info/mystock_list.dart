import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_data.dart';
import 'package:stockapp/investment/stock_detail_screen.dart';

class MyStockList extends StatelessWidget {
  final List<UserStockData> stocks;

  MyStockList({required this.stocks}); // ✅ UserInfoScreen에서 데이터 받기

  @override
  Widget build(BuildContext context) {
    return stocks.isEmpty
        ? Center(child: Text("보유한 주식이 없습니다."))
        : ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              var stock = stocks[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(stock.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${stock.quantity}주 | 총 보유액: ${stock.totalValue.toStringAsFixed(0)} 원'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${stock.price.toStringAsFixed(0)} 원', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${stock.profitRate.toStringAsFixed(2)} %',
                          style: TextStyle(color: stock.profitRate >= 0 ? Colors.red : Colors.blue)),
                    ],
                  ),
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
                ),
              );
            },
          );
  }
}
