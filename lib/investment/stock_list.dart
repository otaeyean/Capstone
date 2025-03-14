import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stock_detail_screen.dart'; // ???์ธ ?๋ฉด import

class StockList extends StatelessWidget {
  final List<Map<String, dynamic>> stocks;
  final bool isTradeVolumeSelected; // ??๊ฑฐ๋??๋ฒํผ??? ํ?์?์? ?ฌ๋? ์ถ๊?

  const StockList({required this.stocks, required this.isTradeVolumeSelected});

  String formatTradeVolume(int volume) {
    return volume >= 1000000
        ? "${(volume / 1000000).toStringAsFixed(1)}M"
        : NumberFormat("#,###").format(volume);
  }

  String formatKoreanPrice(double price) {
    return NumberFormat("#,###").format(price);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        var stock = stocks[index];

        // ??๊ด??๋ชฉ๋ก๊ณ??ผ๋ฐ ๋ชฉ๋ก???ฐ์ด???๋ ?ตํฉ
        double percent = (stock['stockChangePercent'] ?? stock['changeRate'] ?? 0).toDouble();
        double changePrice = (stock['stockChange'] ?? stock['changePrice'] ?? 0).toDouble();
        double currentPrice = (stock['stockCurrentPrice'] ?? stock['currentPrice'] ?? 0).toDouble();
        int tradeVolume = (stock['acml_vol'] ?? stock['tradeVolume'] ?? 0).toInt();

        // ???ด์ธ ์ฃผ์ ?ฌ๋? ?์ธ
        bool isOverseas = stock.containsKey("excd");

        // ???ด์ธ ์ฃผ์????changePrice ๋ถ??์กฐ์ 
        if (isOverseas && percent < 0) {
          changePrice = -changePrice;
        }

        String changeText = percent >= 0
            ? "+${percent.toStringAsFixed(2)}%"
            : "${percent.toStringAsFixed(2)}%";
        Color changeColor = percent >= 0 ? Colors.red : Colors.blue;
        String changePriceText = changePrice >= 0
            ? "+${changePrice.toStringAsFixed(2)}"
            : changePrice.toStringAsFixed(2);

        Color priceColor = isTradeVolumeSelected ? Colors.black : changeColor; // ??๊ฑฐ๋??? ํ ??๊ฒ???? ์?

        String priceText;
        if (isOverseas) {
          priceText = "\$${currentPrice.toStringAsFixed(4)}"; // ???ด์ธ ์ฃผ์ ?์??? ์?
        } else {
          priceText = "${formatKoreanPrice(currentPrice)} ??; // ??๊ต?ด ์ฃผ์ ?ผํ ์ถ๊?
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StockDetailScreen(stock: stock), // ???ด๋ฆญ ???์ธ ?๋ฉด?ผ๋ก ?ด๋
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
                      stock['stockName'] ?? '?????์',
                      style: TextStyle(
                          fontFamily: 'MinSans',
                          fontSize: 17,
                          fontWeight: FontWeight.w900),
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
                            color: priceColor, // ??๊ฑฐ๋??? ํ ??๊ฒ??? ?์น/?๋ฝ ? ํ ??๋ณ?๋ฅ  ?์
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
                          style: TextStyle(
                              fontFamily: 'MinSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: changeColor),
                        ),
                        SizedBox(height: 2),
                        Text(
                          changePriceText,
                          style: TextStyle(
                              fontFamily: 'MinSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: changeColor),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      formatTradeVolume(tradeVolume),
                      style: TextStyle(
                          fontFamily: 'MinSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.amber),
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

