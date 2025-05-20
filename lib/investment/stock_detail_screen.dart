import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockapp/investment/detail_widgets/realtimetrade.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import './detail_widgets/stock_change_info.dart';
import 'chart/chart_main.dart';
import './news/news.dart';
import './investment_main/mock_investment_screen.dart';
import './detail_widgets/description.dart';
import 'package:stockapp/server/investment/info/stock_description_server.dart'; 
import 'package:stockapp/investment/detail_widgets/stock_info.dart'; 
import 'package:stockapp/investment/detail_widgets/info.dart';
import 'package:http/http.dart' as http; 

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
  Map<String, dynamic> _priceData = {}; // ✅ 가격 데이터 저장용

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();    
    _fetchCompanyDescription();
    _fetchPriceData(); // ✅ 가격/변동률 API 호출
  }

  Future<void> _fetchPriceData() async {
    final stockCode = widget.stock['stockCode'];
    try {
      final response = await http.get(
        Uri.parse('http://withyou.me:8080/current-price?stockCode=$stockCode'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _priceData = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('❌ 가격 정보 로드 실패: $e');
    }
  }

  Future<void> _fetchCompanyDescription() async {
    if (widget.stock['stockName'] == null || widget.stock['stockName'] == 'N/A') {
      setState(() {
        companyDescription = '주식 이름이 없습니다.';
        isLoading = false;
      });
      return;
    }

    try {
      String response = await fetchCompanyDescription(widget.stock['stockName']);
      setState(() {
        companyDescription = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        companyDescription = '회사 소개를 불러오는 데 실패했습니다.';
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      final snackBar = SnackBar(content: Text('로그인이 필요합니다.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final stockCode = widget.stock['stockCode'];

    setState(() {
      isFavorite = !isFavorite;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(stockCode, isFavorite);

    try {
      final url = Uri.parse('http://withyou.me:8080/watchlist/${isFavorite ? 'add' : 'remove'}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '{"userId": "$userId", "stockCode": "$stockCode"}',
      );

      final snackBar = SnackBar(
        content: Text(isFavorite ? '관심 항목으로 등록되었습니다' : '관심 항목에서 삭제되었습니다'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      setState(() {
        isFavorite = !isFavorite;
      });
      final snackBar = SnackBar(content: Text('관심 항목 추가/삭제에 실패했습니다.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('에러 발생: $e');
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final stockCode = widget.stock['stockCode'];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedFavorite = prefs.getBool(stockCode);

    if (savedFavorite != null) {
      setState(() {
        isFavorite = savedFavorite;
      });
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
String _formatPrice(dynamic value) {
  final doubleVal = _parseDouble(value);
  return NumberFormat("#,###").format(doubleVal); // 예: 55,900
}

  @override
  Widget build(BuildContext context) {
    final stock = {
      'name': widget.stock['stockName'] ?? '이름 없음',
      'price': _formatPrice(_priceData['stockPrice'] ?? widget.stock['currentPrice']),
      'rise_percent': _parseDouble(_priceData['changeRate'] ?? widget.stock['changeRate']), 
      'fall_percent': _parseDouble(_priceData['changeRate'] ?? widget.stock['changeRate']), 
      'quantity': widget.stock['tradeVolume'] ?? 0,
      'stockCode': widget.stock['stockCode'] ?? '',
    };

    final String stockName = stock['name'];
    final String stockCode = stock['stockCode'];

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
                    SizedBox(height: 5),
                    StockInfo(stock: stock),
                    StockChangeInfo(stock: stock),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.yellow : Colors.grey,
                        size: 40,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.notifications_none,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: DefaultTabController(
              length: 5,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: '차트'),
                      Tab(text: '실시간 체결가'),
                      Tab(text: '모의 투자'),
                      Tab(text: '뉴스'),
                      Tab(text: '상세 정보'),
                    ],
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.black,
                    indicatorColor: Colors.green,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double chartHeight = constraints.maxHeight * 0.5;
                            return SizedBox(
                              height: chartHeight,
                              child: StockChartMain(stockCode: stockCode),
                            );
                          },
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double chartHeight = constraints.maxHeight * 0.5;
                            return SizedBox(
                              height: chartHeight,
                              child: RealTimePriceChart(stockCode: stockCode),
                            );
                          },
                        ),
                        MockInvestmentScreen(stockCode: stockCode),
                        NewsScreen(stockName: stockName),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : companyDescription != null
                                      ? StockDescription(stock: stock, description: companyDescription!)
                                      : Text('회사 소개 정보를 불러올 수 없습니다.', style: TextStyle(color: Colors.red)),
                              if (stockCode.isNotEmpty) StockInfoDetail(stockCode: stockCode),
                            ],
                          ),
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
