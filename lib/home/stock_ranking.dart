import 'package:flutter/material.dart';
import 'package:stockapp/stock_api_service.dart';
import '../investment/stock_detail_screen.dart';

class StockRanking extends StatefulWidget {
  @override
  _StockRankingState createState() => _StockRankingState();
}

class _StockRankingState extends State<StockRanking> {
  String selectedMarket = "국내"; // 국내/해외 선택
  String selectedCategory = "상승률"; // 상승률, 하락률, 거래량 선택
  List<Map<String, dynamic>> stockRankings = [];
  bool isLoading = true; // ✅ 로딩 상태 변수
  bool isError = false; // ✅ API 실패 감지 변수

  @overrideP
  void initState() {
    super.initState();
    _loadStockData();
  }

  // 🔹 주식 데이터 불러오기
  Future<void> _loadStockData() async {
    if (!mounted) return; // ✅ 현재 위젯이 활성화된 상태인지 확인

    setState(() {
      isLoading = true;
      isError = false; // ✅ 에러 상태 초기화
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

      if (stocks.isEmpty) throw Exception("데이터 없음"); // ✅ 빈 데이터 처리

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
          isError = true; // ✅ 오류 상태 true 설정
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ 국내/해외 선택 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMarketButton("국내"),
            SizedBox(width: 16),
            _buildMarketButton("해외"),
          ],
        ),
        SizedBox(height: 10),

        // ✅ 상승률, 하락률, 거래량 선택 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCategoryButton("상승률", Icons.trending_up),
            _buildCategoryButton("하락률", Icons.trending_down),
            _buildCategoryButton("거래량", Icons.swap_vert),
          ],
        ),
        SizedBox(height: 10),

        // ✅ 로딩 중 화면
        if (isLoading)
          Center(child: CircularProgressIndicator())
        // ✅ 에러 발생 시 메시지 표시
        else if (isError)
          Center(child: Text("데이터를 불러올 수 없습니다.", style: TextStyle(color: Colors.red, fontSize: 16)))
        else
          // ✅ 주식 순위 리스트
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              shrinkWrap: true, // ✅ 내부 리스트뷰 자동 조절
              physics: NeverScrollableScrollPhysics(), // ✅ 외부 스크롤과 충돌 방지
              itemCount: stockRankings.length,
              itemBuilder: (context, index) {
                int rank = index + 1;
                var stock = stockRankings[index];
                bool isRise = selectedCategory == "상승률";
                bool isFall = selectedCategory == "하락률";
                bool isVolume = selectedCategory == "거래량";
                
                // ✅ 값 결정 (거래량 or 상승률/하락률 %)
                String valueText;
                Color textColor = Colors.black;
                String arrow = "";

                if (isRise) {
                  double percent = stock['changeRate'] ?? 0.0;
                  valueText = "▲ ${percent.toStringAsFixed(2)}%";
                  textColor = Colors.red;
                } else if (isFall) {
                  double percent = stock['changeRate'] ?? 0.0;
                  valueText = "▼ ${percent.toStringAsFixed(2)}%";
                  textColor = Colors.blue;
                } else if (isVolume) {
                  int tradeVolume = stock['tradeVolume'] ?? 0;
                  valueText = "$tradeVolume"; // 🔥 거래량 그대로 표시
                  textColor = Colors.black;
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
                        bottom: BorderSide(color: Colors.grey.shade300, width: 1), // ✅ 줄 추가
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$rank. ${stock['stockName']}",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Text(
                              "${stock['currentPrice'].toString()} 원",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Text(
                              valueText,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            ),
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

  // ✅ 국내/해외 버튼 스타일
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

  // ✅ 카테고리 버튼 스타일
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