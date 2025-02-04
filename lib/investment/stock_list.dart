import 'package:flutter/material.dart';
import 'stock_detail_screen.dart';

class StockList extends StatelessWidget {
  final List<Map<String, dynamic>> stocks;
  final bool isRise;  // 상승률/하락률을 토글할 상태
  final Function() toggleChangePercentage;
  final Function(Map<String, dynamic>) calculateChangePercent;

  const StockList({
    required this.stocks,
    required this.isRise,
    required this.toggleChangePercentage,
    required this.calculateChangePercent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stocks.map((stock) {
        double changePercent = calculateChangePercent(stock); // 상승률/하락률 계산

        // 절댓값을 구하고 소수점 2자리로 표시
        String formattedChangePercent = changePercent.abs().toStringAsFixed(2);

        // 상승률/하락률 표시: 상승률이면 + 부호를, 하락률이면 - 부호를 표시
        return Card(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(stock['name']),
                Text(stock['price'].toString()),  // 가격을 String으로 변환
                GestureDetector(
                  onTap: toggleChangePercentage,  // 토글할 때마다 상승률/하락률을 전환
                  child: Text(
                    '${isRise ? '+' : '-'}$formattedChangePercent%',  // 상승률/하락률 표시
                    style: TextStyle(
                      color: isRise ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                Text('${stock['quantity'].toString()}'),  // 거래량을 String으로 변환
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StockDetailScreen(stock: stock),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
