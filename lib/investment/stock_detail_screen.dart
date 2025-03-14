import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import './detail_widgets/stock_change_info.dart';
import 'chart/chart_main.dart';
import './news/news.dart';
import './investment_main/mock_investment_screen.dart';
import './detail_widgets/description.dart';
import 'package:stockapp/server/investment/stock_description_server.dart'; // API ?�청 추�?
import 'package:stockapp/investment/detail_widgets/stock_info.dart'; // ??StockInfo 추�?
import 'package:stockapp/investment/detail_widgets/info.dart';
import 'package:http/http.dart' as http; // 추�?: HTTP ?�청???�한 ?�이브러�?
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
    if (widget.stock['stockName'] == null || widget.stock['stockName'] ==  'N/A') {
      setState(() {
        companyDescription = '주식 ?�름???�습?�다.';
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
        companyDescription = '?�사 ?�개�?불러?�는 ???�패?�습?�다.';
        isLoading = false;
      });
    }
  }

  // 관??추�?/??�� API ?�출
  Future<void> _toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    // ?�?�된 userId (nickname) 가?�오�?    final userId = await AuthService.getUserId(); // AuthService?�서 nickname??가?�옴
    if (userId == null) {
      final snackBar = SnackBar(content: Text('로그?�이 ?�요?�니??'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final stockCode = widget.stock['stockCode'];

    try {
      final url = Uri.parse('http://withyou.me:8080/watchlist/${isFavorite ? 'add' : 'remove'}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '{"userId": "$userId", "stockCode": "$stockCode"}',
      );

      if (response.statusCode == 200) {
        final snackBar = SnackBar(
          content: Text(isFavorite ? '관????��?�로 ?�록?�었?�니?? : '관????��?�서 ??��?�었?�니??),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final errorMessage = 'API ?�청 ?�패: ${response.statusCode}';
        final snackBar = SnackBar(content: Text(errorMessage));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        print('API ?�출 ?�패: $errorMessage');
      }
    } catch (e) {
      setState(() {
        isFavorite = !isFavorite; // API ?�패 ???�태 ?�돌리기
      });
      final snackBar = SnackBar(content: Text('관????�� 추�?/??��???�패?�습?�다.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('?�러 발생: $e');
    }
  }

  // ???�전??문자??-> double 변???�수
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final stock = {
      'name': widget.stock['stockName'] ?? '?�름 ?�음',
      'price': widget.stock['currentPrice'].toString(),
      'rise_percent': _parseDouble(widget.stock['changeRate']), // ???�정
      'fall_percent': _parseDouble(widget.stock['changeRate']), // ???�정
      'quantity': widget.stock['tradeVolume'] ?? 0,
      'stockCode': widget.stock['stockCode'] ?? '',
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
                    SizedBox(height: 5),
                    StockInfo(stock: stock),
                    StockChangeInfo(stock: stock), // ??StockInfo ?�거
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.yellow : Colors.grey,
                      ),
                      onPressed: _toggleFavorite, // 관??추�?/??�� ?�수 ?�출
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
                      Tab(text: '모의 ?�자'),
                      Tab(text: '?�스'),
                      Tab(text: '?�세 ?�보'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 차트???�기 ?�적?�로 ?�정
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double chartHeight = constraints.maxHeight * 0.5; // ?�면 ?�이??비�??�여 차트 ?�기 ?�정
                            return SizedBox(
                              height: chartHeight,
                              child: StockChartMain(stockCode: widget.stock['stockCode']), // 차트 ?�용
                            );
                          },
                        ),
                        MockInvestmentScreen(stockCode: stockCode), // stockCode ?�달
                        NewsScreen(stockName: stockName),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : companyDescription != null
                                      ? StockDescription(stock: stock, description: companyDescription!)
                                      : Text('?�사 ?�개 ?�보�?불러?????�습?�다.', style: TextStyle(color: Colors.red)),
                              if (stockCode.isNotEmpty) StockInfoDetail(stockCode: stockCode), // stockCode 체크
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

