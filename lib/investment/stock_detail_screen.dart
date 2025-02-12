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
    // ⚠ **null 값 방지 처리 (데이터 타입 변환 추가)**
    final stock = {
      'name': widget.stock['name'] ?? '이름 없음',
      'price': widget.stock['price'].toString(), // 🔥 안전한 변환
      'rise_percent': (widget.stock['rise_percent'] ?? 0.0).toDouble(), // 🔥 Null 체크 + double 변환
      'fall_percent': (widget.stock['fall_percent'] ?? 0.0).toDouble(), // 🔥 Null 체크 + double 변환
      'quantity': widget.stock['quantity'] ?? 0, // 🔥 Null 체크
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
                    StockInfo(stock: stock),
                    SizedBox(height: 5),
                    StockChangeInfo(stock: stock),
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