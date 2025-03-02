import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stockapp/stock_api_service.dart';
import '../investment/stock_detail_screen.dart';

class StockRanking extends StatefulWidget {
  @override
  _StockRankingState createState() => _StockRankingState();
}

class _StockRankingState extends State<StockRanking> {
  String selectedMarket = "국내";
  String selectedCategory = "상승률";
  List<Map<String, dynamic>> stockData = [];
  List<Map<String, dynamic>> visibleRankings = [];
  bool isLoading = true;
  bool isError = false;
  int startIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStockData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isError = false;
    });

    List<Map<String, dynamic>> stocks = [];

    try {
      if (selectedCategory == "상승률") {
        stocks = await fetchStockData("rise");
      } else if (selectedCategory == "하락률") {
        stocks = await fetchStockData("fall");
      } else if (selectedCategory == "거래량") {
        stocks = await fetchStockData("trade-volume");
      }

      if (stocks.isEmpty) throw Exception("데이터 없음");

      if (mounted) {
        setState(() {
          stockData = stocks;
          startIndex = 0;
          visibleRankings = stockData.sublist(0, 5);
          isLoading = false;
        });

        _timer?.cancel();
        _timer = Timer.periodic(Duration(seconds: 3), (_) {
          _updateRanking();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    }
  }

  void _updateRanking() {
    if (!mounted || stockData.length < 10) return;

    setState(() {
      startIndex = (startIndex + 1) % 6;
      visibleRankings = stockData.sublist(startIndex, startIndex + 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMarketButton("국내"),
            SizedBox(width: 16),
            _buildMarketButton("해외"),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCategoryButton("상승률", Icons.trending_up),
            _buildCategoryButton("하락률", Icons.trending_down),
            _buildCategoryButton("거래량", Icons.swap_vert),
          ],
        ),
        SizedBox(height: 10),
        if (isLoading)
          Center(child: CircularProgressIndicator())
        else if (isError)
          Center(
            child: Text(
              "데이터를 불러올 수 없습니다.",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          )
        else
          AnimatedSwitcher(
            duration: Duration(milliseconds: 800),
            child: _buildStockList(),
          ),
      ],
    );
  }

Widget _buildCategoryButton(String category, IconData icon) {
  bool isSelected = selectedCategory == category;
  Color iconColor;
  
  if (isSelected) {
    if (category == "상승률") {
      iconColor = Colors.red;
    } else if (category == "하락률") {
      iconColor = Colors.blue;
    } else {
      iconColor = Colors.black;
    }
  } else {
    iconColor = Colors.grey;
  }

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedCategory = category;
        _loadStockData();
      });
    },
    child: Column(
      children: [
        Icon(icon, color: iconColor),
        Text(
          category,
          style: TextStyle(
            color: isSelected ? iconColor : Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMarketButton(String market) {
    bool isSelected = selectedMarket == market;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMarket = market;
          _loadStockData();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          market,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

Widget _buildStockList() {
  return Column(
    key: ValueKey(startIndex),
    children: visibleRankings.map((stock) {
      int rank = stockData.indexOf(stock) + 1;
      bool isRise = selectedCategory == "상승률";
      bool isFall = selectedCategory == "하락률";

      String valueText;
      Color textColor;

      if (isRise || isFall) {
        double percent = stock['changeRate'] ?? 0.0;
        String sign = isRise ? "+" : "-";
        valueText = "$sign${percent.abs().toStringAsFixed(2)}%";
        textColor = isRise ? Colors.red : Colors.blue;
      } else {
        int tradeVolume = stock['tradeVolume'] ?? 0;
        valueText = "$tradeVolume";
        textColor = Colors.black;
      }

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
          margin: EdgeInsets.symmetric(vertical: 5),
          elevation: 1,
          color: const Color.fromARGB(255, 255, 255, 255),
          child: ListTile(
            title: Row(
              children: [
                Text(
                  "$rank. ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    "${stock['stockName']}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${stock['currentPrice'].toString()} 원",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  valueText,
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}
}
