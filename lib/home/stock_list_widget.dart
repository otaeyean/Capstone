import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart';

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
      separatorBuilder: (context, index) => SizedBox(width: 40),
      itemBuilder: (context, index) {
        final stock = stocks[index];
        final profitRate = stock.profitRate ?? 0.0;
        final profitText = "${profitRate >= 0 ? "+" : ""}${profitRate.toStringAsFixed(2)}%";
        final changeColor = profitRate >= 0 ? Colors.redAccent : Colors.blueAccent;

        final String stockImage = 'assets/images/${stock.name}_${stock.stockCode}.png';

        return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF4F4F6), // 거의 흰색에 가까운 중립 배경
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  stockImage,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              stock.name ?? '이름 없음',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'MinSans',
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
