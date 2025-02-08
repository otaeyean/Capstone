import 'package:flutter/material.dart';
import '../investment/stock_detail_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class StockRanking extends StatefulWidget {
  @override
  _StockRankingState createState() => _StockRankingState();
}

class _StockRankingState extends State<StockRanking> {
  String selectedMarket = "국내"; // 국내/해외 선택
  String selectedCategory = "상승률"; // 상승률, 하락률, 거래량 선택
  List<Map<String, dynamic>> stockRankings = [];

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    String jsonString = await rootBundle.loadString('assets/company_data.json');
    final data = jsonDecode(jsonString)['stocks'];

    setState(() {
      List<Map<String, dynamic>> stocks = List<Map<String, dynamic>>.from(data);

      if (selectedCategory == "상승률") {
        stockRankings = stocks
            .where((stock) => stock['market'] == selectedMarket)
            .toList()
            ..sort((a, b) => (b['rise_percent']).compareTo(a['rise_percent']));
      } else if (selectedCategory == "하락률") {
        stockRankings = stocks
            .where((stock) => stock['market'] == selectedMarket)
            .toList()
            ..sort((a, b) => (b['fall_percent']).compareTo(a['fall_percent']));
      } else if (selectedCategory == "거래량") {
        stockRankings = stocks
            .where((stock) => stock['market'] == selectedMarket)
            .toList()
            ..sort((a, b) => (b['quantity']).compareTo(a['quantity']));
      }

      stockRankings = stockRankings.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 국내/해외 선택 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMarketButton("국내"),
            SizedBox(width: 16), // 간격 추가
            _buildMarketButton("해외"),
          ],
        ),
        SizedBox(height: 10),

        // 상승률, 하락률, 거래량 선택
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCategoryButton("상승률", Icons.trending_up),
            _buildCategoryButton("하락률", Icons.trending_down),
            _buildCategoryButton("거래량", Icons.swap_vert),
          ],
        ),
        SizedBox(height: 10),

        // 주식 순위 리스트
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200], // 연한 회색 배경
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: stockRankings.asMap().entries.map((entry) {
              int rank = entry.key + 1;
              var stock = entry.value;
              bool isRise = selectedCategory == "상승률";
              bool isFall = selectedCategory == "하락률";
              double percent = isRise ? stock['rise_percent'] : stock['fall_percent'];
              Color textColor = isRise ? Colors.red : (isFall ? Colors.blue : Colors.black);
              String arrow = isRise ? "▲" : (isFall ? "▼" : "");

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockDetailScreen(stock: stock),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$rank. ${stock['name']}", style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          Text(
                            "${stock['price'].toString()} 원",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "$arrow${percent.toStringAsFixed(2)}%",
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketButton(String market) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedMarket = market;
          _loadStockData();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedMarket == market ? Colors.black : Colors.white,
        foregroundColor: selectedMarket == market ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(market, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCategoryButton(String category, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
          _loadStockData();
        });
      },
      child: Column(
        children: [
          Icon(icon, color: selectedCategory == category ? Colors.black : Colors.grey),
          Text(
            category,
            style: TextStyle(
              color: selectedCategory == category ? Colors.black : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
