import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart'; // UserStockModel import

class StockListWidget extends StatelessWidget {
  final List<UserStockModel> stocks;

  const StockListWidget({Key? key, required this.stocks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: stocks.length,
      padding: EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (context, index) => SizedBox(width: 60),
      itemBuilder: (context, index) {
        final stock = stocks[index];
        final profitRate = stock.profitRate ?? 0.0;
        final profitText = "${profitRate >= 0 ? "+" : ""}${profitRate.toStringAsFixed(2)}%";
        final changeColor = profitRate >= 0 ? Colors.red : Colors.blue;

        return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEFF9F8),
              ),
              child: Icon(Icons.android, size: 36, color: Color(0xFF03314B)),
            ),
            SizedBox(height: 8),
            Text(
              stock.name ?? '이름 없음',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontFamily: 'MinSans',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              profitText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                fontFamily: 'MinSans',
                color: changeColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
