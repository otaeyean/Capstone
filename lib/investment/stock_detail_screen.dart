import 'package:flutter/material.dart';
import './detail_widgets/stock_change_info.dart';
import 'chart/chart_placeholder.dart';
import './detail_widgets/info.dart';
import './detail_widgets/description.dart';
import './news/news.dart';
import './investment_main/mock_investment_screen.dart';

class StockDetailScreen extends StatefulWidget {
  final Map<String, dynamic> stock;

  StockDetailScreen({required this.stock});

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  bool isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    final snackBar = SnackBar(
      content: Text(isFavorite ? '관심 항목으로 등록되었습니다' : '관심 항목에서 삭제되었습니다'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {

    // ✅ **null 값 방지 및 필드명 수정**
    final stock = {
      'name': widget.stock['stockName'] ?? '이름 없음', // 🔥 필드명 일치
      'price': widget.stock['currentPrice']?.toString() ?? "0 원", // 🔥 가격 null 체크
      'changePrice': widget.stock['changePrice'] ?? 0.0, // 🔥 변동금액 null 체크
      'changeRate': widget.stock['changeRate'] ?? 0.0, // 🔥 변동률 null 체크
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock['name'],
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      stock['price'], // ✅ null 방지된 가격 표시
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "어제보다 ${stock['changePrice']}원 (${stock['changeRate']}%)", // ✅ 변동금액, 변동률 표시
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: stock['changeRate'] >= 0 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.yellow : Colors.grey,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    Icon(
                      Icons.notifications_none,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: '차트'),
                      Tab(text: '뉴스'),
                      Tab(text: '모의 투자'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              StockChartPlaceholder(),
                              StockDescription(stock: stock),
                            ],
                          ),
                        ),
                        NewsScreen(),
                        MockInvestmentScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
