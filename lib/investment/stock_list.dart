import 'package:flutter/material.dart';
import 'package:stockapp/investment/stock_detail_screen.dart';

class StockList extends StatelessWidget {
  final List<Map<String, dynamic>> stocks;
  final bool isRise;
  final Function() toggleChangePercentage;

  const StockList({
    required this.stocks,
    required this.isRise,
    required this.toggleChangePercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          var stock = stocks[index];

          double risePercent = stock['rise_percent'] ?? 0.0;
          double fallPercent = stock['fall_percent'] ?? 0.0;

          // 🔹 상승률/하락률 포맷팅 및 색상 설정
          String changeText = isRise
              ? "+${risePercent.toStringAsFixed(2)}%"
              : "-${fallPercent.toStringAsFixed(2)}%";

          Color changeColor = isRise
              ? (risePercent > 0 ? Colors.red : Colors.grey)
              : (fallPercent > 0 ? Colors.blue : Colors.grey);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StockDetailScreen(stock: stock),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔹 회사명
                    Expanded(
                      flex: 2,
                      child: Text(
                        stock['name'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // 🔹 현재가
                    Expanded(
                      flex: 2,
                      child: Text(
                        "${stock['price']} 원",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // 🔹 상승률 or 하락률
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: toggleChangePercentage,
                        child: Text(
                          changeText,
                          style: TextStyle(fontSize: 16, color: changeColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // 🔹 거래량
                    Expanded(
                      flex: 1,
                      child: Text(
                        stock['quantity'].toString(),
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
