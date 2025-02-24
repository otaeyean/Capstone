import 'package:flutter/material.dart';

class StockListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> myStocks = [
    {"name": "테슬라", "price": "1,234원", "change": "-37(2.8%)"},
    {"name": "애플", "price": "1,234원", "change": "-37(2.8%)"},
    {"name": "삼성전자", "price": "1,234원", "change": "+37(2.8%)"},
    {"name": "MSFT", "price": "1,234원", "change": "+37(2.8%)"},
  ];

  final PageController _pageController = PageController(viewportFraction: 1.0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 130, // 카드 높이 조정
          child: PageView.builder(
            controller: _pageController,
            itemCount: (myStocks.length / 2).ceil(),
            itemBuilder: (context, pageIndex) {
              int firstIndex = pageIndex * 2;
              int secondIndex = firstIndex + 1;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩 추가
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 카드 간격 균등하게 조정
                  children: [
                    Flexible(flex: 1, child: buildStockCard(myStocks[firstIndex], context)),
                    if (secondIndex < myStocks.length)
                      SizedBox(width: 10), // 카드 사이 여백 추가
                    if (secondIndex < myStocks.length)
                      Flexible(flex: 1, child: buildStockCard(myStocks[secondIndex], context)),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget buildStockCard(Map<String, dynamic> stock, BuildContext context) {
    Color backgroundColor = stock["change"].contains("+")
        ? Color(0xFFFFE5E5) // 연한 빨간색 (상승)
        : Color(0xFFE5F0FF); // 연한 파란색 (하락)

    return Container(
      width: double.infinity, // 가로 길이 최대한 늘리기
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stock["name"],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            stock["price"],
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            stock["change"],
            style: TextStyle(color: stock["change"].contains("+") ? Colors.red : Colors.blue),
          ),
        ],
      ),
    );
  }
}
