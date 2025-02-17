import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/stock_api_service.dart';
import '../investment/stock_detail_screen.dart';

class StockRanking extends StatefulWidget {
  @override
  _StockRankingState createState() => _StockRankingState();
}

class _StockRankingState extends State<StockRanking> {
  String selectedMarket = "국내";
  String selectedCategory = "상승률";
  List<Map<String, dynamic>> stockRankings = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isError = false;
    });

    List<Map<String, dynamic>> stocks = [];

    try {
      if (selectedMarket == "국내") {
        if (selectedCategory == "상승률") {
          stocks = await fetchStockData("rise");
        } else if (selectedCategory == "하락률") {
          stocks = await fetchStockData("fall");
        } else if (selectedCategory == "거래량") {
          stocks = await fetchStockData("trade-volume");
        }
      } else if (selectedMarket == "해외") {
        if (selectedCategory == "상승률") {
          stocks = await fetchStockData("rise/overseas", period: "DAILY");
        } else if (selectedCategory == "하락률") {
          stocks = await fetchStockData("fall/overseas", period: "DAILY");
        } else if (selectedCategory == "거래량") {
          stocks = await fetchStockData("trade-volume/overseas");
        }
      }

      if (stocks.isEmpty) throw Exception("데이터 없음");

      if (mounted) {
        setState(() {
          stockRankings = stocks.take(5).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("🚨 데이터 로딩 실패: $e");
      if (mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    }
  }

  String formatTradeVolume(int volume) {
    if (volume >= 1000000000) {
      return "${(volume / 1000000000).toStringAsFixed(1)}B";
    } else if (volume >= 1000000) {
      return "${(volume / 1000000).toStringAsFixed(1)}M";
    } else if (volume >= 1000) {
      return "${(volume / 1000).toStringAsFixed(1)}K";
    } else {
      return "$volume";
    }
  }

  String formatKoreanPrice(int price) {
    return NumberFormat("#,###").format(price);
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
              child: Text("데이터를 불러올 수 없습니다.",
                  style: TextStyle(color: Colors.red, fontSize: 16)))
        else
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: stockRankings.length,
              itemBuilder: (context, index) {
                int rank = index + 1;
                var stock = stockRankings[index];
                bool isRise = selectedCategory == "상승률";
                bool isFall = selectedCategory == "하락률";
                bool isVolume = selectedCategory == "거래량";

                String valueText;
                Color valueTextColor = Colors.black;
                Color priceColor = isVolume ? Colors.black : Colors.black;

                if (isRise || isFall) {
                  double percent = stock['changeRate'] ?? 0.0;
                  String arrow = percent >= 0 ? "▲" : "▼";
                  valueText = "$arrow ${percent.toStringAsFixed(2)}%";
                  valueTextColor = percent >= 0 ? Colors.red : Colors.blue;
                  priceColor = valueTextColor; // ✅ 상승/하락이면 현재가 색상도 변경
                } else if (isVolume) {
                  int tradeVolume = stock['tradeVolume'] ?? 0;
                  valueText = formatTradeVolume(tradeVolume);
                  valueTextColor = Colors.amber; // ✅ 거래량 선택 시 노란색
                  priceColor = Colors.black; // ✅ 거래량일 때 현재가는 검정색
                } else {
                  valueText = "N/A";
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
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.grey.shade300, width: 1),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$rank. ${stock['stockName']}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Text(
                              selectedMarket == "해외"
                                  ? "\$${stock['currentPrice']}"
                                  : "${formatKoreanPrice(stock['currentPrice'])} 원",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: priceColor, // ✅ 현재가 색상 적용
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(valueText,
                                style: TextStyle(
                                  color: valueTextColor, // ✅ 거래량일 때 노란색 적용
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
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
          Text(category, style: TextStyle(color: selectedCategory == category ? Colors.black : Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}