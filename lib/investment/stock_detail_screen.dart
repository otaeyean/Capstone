import 'package:flutter/material.dart';
import './detail_widgets/stock_change_info.dart';
import 'chart/chart_main.dart';
import './detail_widgets/info.dart';
import './news/news.dart';
import './investment_main/mock_investment_screen.dart';
import './detail_widgets/description.dart';
import 'package:stockapp/server/investment/stock_description_server.dart'; // API 요청 추가

class StockDetailScreen extends StatefulWidget {
  final Map<String, dynamic> stock;

  StockDetailScreen({required this.stock});

  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  bool isFavorite = false;
  bool isLoading = true;
  String? companyDescription;

  @override
  void initState() {
    super.initState();
    _fetchCompanyDescription();
  }

  Future<void> _fetchCompanyDescription() async {
    try {
      String response = await fetchCompanyDescription(widget.stock['stockName']);
      setState(() {
        companyDescription = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        companyDescription = null;
        isLoading = false;
      });
    }
  }

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
    final stock = {
      'name': widget.stock['stockName'] ?? '이름 없음',
      'price': widget.stock['currentPrice'].toString(),
      'rise_percent': (widget.stock['changeRate'] ?? 0.0).toDouble(),
      'fall_percent': (widget.stock['changeRate'] ?? 0.0).toDouble(),
      'quantity': widget.stock['tradeVolume'] ?? 0,
    };

    final String stockName = stock['name'];
    final String stockCode = widget.stock['stockCode'] ?? '';

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
              length: 4,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: '차트'),
                      Tab(text: '모의 투자'),
                      Tab(text: '뉴스'),
                      Tab(text: '상세 정보'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                               StockChartMain(stockCode: widget.stock['stockCode']),  // ✅ 차트 적용
                             
                            ],
                          ),
                        ),
                        MockInvestmentScreen(),
                        NewsScreen(stockName: stockName),
                        SingleChildScrollView(
                          child: isLoading
                              ? Center(child: CircularProgressIndicator())
                              : companyDescription != null
                                  ? StockDescription(stock: stock, description: companyDescription!)
                                  : Container(),
                        ),
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