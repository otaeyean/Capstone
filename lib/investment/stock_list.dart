import 'package:flutter/material.dart';
import 'package:stockapp/stock_api_service.dart';
import 'package:stockapp/investment/stock_detail_screen.dart';

class StockList extends StatefulWidget {
  final String endpoint;
  final String period;

  const StockList({
    required this.endpoint,
    this.period = "DAILY",
  });

  @override
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  List<Map<String, dynamic>> stocks = [];

  @override
  void initState() {
    super.initState();
    _fetchStockData();
  }

  Future<void> _fetchStockData() async {
    List<Map<String, dynamic>> data = await fetchStockData(widget.endpoint, period: widget.period);
    setState(() {
      stocks = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return stocks.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              var stock = stocks[index];
              bool isRise = widget.endpoint == "rise";

              double percent = isRise ? stock['changeRate'] : stock['changeRate'].abs();
              String changeText = isRise
                  ? "+${percent.toStringAsFixed(2)}%"
                  : "-${percent.toStringAsFixed(2)}%";
              Color changeColor = isRise ? Colors.red : Colors.blue;

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
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6), // ✅ 간격 늘림
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Container(
                    height: 60, // ✅ 카드 높이 증가
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 14), // ✅ 패딩 증가
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 🔹 주식 이름
                        Expanded(
                          flex: 2,
                          child: Text(
                            stock['stockName'] ?? '알 수 없음',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // ✅ 글씨 크기 증가
                          ),
                        ),
                        // 🔹 현재가
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${stock['currentPrice']} 원",
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // 🔹 상승률 or 하락률
                        Expanded(
                          flex: 2,
                          child: Text(
                            changeText,
                            style: TextStyle(fontSize: 18, color: changeColor), // ✅ 글씨 크기 증가
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // 🔹 거래량
                        Expanded(
                          flex: 1,
                          child: Text(
                            stock['tradeVolume'].toString(),
                            style: TextStyle(fontSize: 18), // ✅ 글씨 크기 증가
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