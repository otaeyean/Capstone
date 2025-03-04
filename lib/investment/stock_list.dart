import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stock_detail_screen.dart'; // ✅ 상세 화면 import

class StockList extends StatelessWidget {
  final List<Map<String, dynamic>> stocks;
  final bool isTradeVolumeSelected; // ✅ 거래량 버튼이 선택되었는지 여부 추가

  const StockList({required this.stocks, required this.isTradeVolumeSelected});

  String formatTradeVolume(int volume) {
    return volume >= 1000000 ? "${(volume / 1000000).toStringAsFixed(1)}M" : NumberFormat("#,###").format(volume);
  }

  String formatKoreanPrice(double price) { // ✅ 가격도 double 변환
    return NumberFormat("#,###").format(price);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        var stock = stocks[index];

        // ✅ `double` 변환하여 오류 방지
        double percent = (stock['changeRate'] ?? 0).toDouble();
        double changePrice = (stock['changePrice'] ?? 0).toDouble();
        double currentPrice = (stock['currentPrice'] ?? 0).toDouble();

        bool isOverseas = stock.containsKey("excd");

        // ✅ 해외 주식일 때 changePrice 부호 조정
        if (isOverseas && percent < 0) {
          changePrice = -changePrice;
        }

        String changeText = percent >= 0 ? "+${percent.toStringAsFixed(2)}%" : "${percent.toStringAsFixed(2)}%";
        Color changeColor = percent >= 0 ? Colors.red : Colors.blue;
        String changePriceText = changePrice >= 0
            ? "+${changePrice.toStringAsFixed(2)}"
            : changePrice.toStringAsFixed(2);

        Color priceColor = isTradeVolumeSelected ? Colors.black : changeColor; // ✅ 거래량 선택 시 검은색 유지

        String priceText;
        if (isOverseas) {
          priceText = "\$${currentPrice.toStringAsFixed(4)}"; // ✅ 해외 주식 소수점 유지
        } else {
          priceText = "${formatKoreanPrice(currentPrice)} 원"; // ✅ 국내 주식 쉼표 추가
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StockDetailScreen(stock: stock), // ✅ 클릭 시 상세 화면으로 이동
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            color: Colors.grey[100],
            child: Container(
              height: 70,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      stock['stockName'] ?? '알 수 없음',
                      style: TextStyle(fontFamily: 'MinSans', fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          priceText,
                          style: TextStyle(
                            fontFamily: 'MinSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: priceColor, // ✅ 거래량 선택 시 검은색, 상승/하락 선택 시 변동률 색상
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          changeText,
                          style: TextStyle(fontFamily: 'MinSans', fontSize: 16, fontWeight: FontWeight.w900, color: changeColor),
                        ),
                        SizedBox(height: 2),
                        Text(
                          changePriceText,
                          style: TextStyle(fontFamily: 'MinSans', fontSize: 15, fontWeight: FontWeight.w900, color: changeColor),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      formatTradeVolume(stock['tradeVolume'] ?? 0),
                      style: TextStyle(fontFamily: 'MinSans',fontSize: 16, fontWeight: FontWeight.w400, color: Colors.amber),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}