import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import './detail_widgets/stock_change_info.dart';
import 'chart/chart_main.dart';
import './news/news.dart';
import './investment_main/mock_investment_screen.dart';
import './detail_widgets/description.dart';
import 'package:stockapp/server/investment/stock_description_server.dart'; // API ?์ฒญ ์ถ๊?
import 'package:stockapp/investment/detail_widgets/stock_info.dart'; // ??StockInfo ์ถ๊?
import 'package:stockapp/investment/detail_widgets/info.dart';
import 'package:http/http.dart' as http; // ์ถ๊?: HTTP ?์ฒญ???ํ ?ผ์ด๋ธ๋ฌ๋ฆ?
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
        companyDescription = '์ฃผ์ ?ด๋ฆ???์ต?๋ค.';
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
        companyDescription = '?์ฌ ?๊ฐ๋ฅ?๋ถ๋ฌ?ค๋ ???คํจ?์ต?๋ค.';
        isLoading = false;
      });
    }
  }

  // ๊ด??์ถ๊?/??  API ?ธ์ถ
  Future<void> _toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    // ??ฅ๋ userId (nickname) ๊ฐ?ธ์ค๊ธ?    final userId = await AuthService.getUserId(); // AuthService?์ nickname??๊ฐ?ธ์ด
    if (userId == null) {
      final snackBar = SnackBar(content: Text('๋ก๊ทธ?ธ์ด ?์?ฉ๋??'));
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
          content: Text(isFavorite ? '๊ด????ชฉ?ผ๋ก ?ฑ๋ก?์?ต๋?? : '๊ด????ชฉ?์ ?? ?์?ต๋??),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final errorMessage = 'API ?์ฒญ ?คํจ: ${response.statusCode}';
        final snackBar = SnackBar(content: Text(errorMessage));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        print('API ?ธ์ถ ?คํจ: $errorMessage');
      }
    } catch (e) {
      setState(() {
        isFavorite = !isFavorite; // API ?คํจ ???ํ ?๋๋ฆฌ๊ธฐ
      });
      final snackBar = SnackBar(content: Text('๊ด????ชฉ ์ถ๊?/?? ???คํจ?์ต?๋ค.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('?๋ฌ ๋ฐ์: $e');
    }
  }

  // ???์ ??๋ฌธ์??-> double ๋ณ???จ์
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
      'name': widget.stock['stockName'] ?? '?ด๋ฆ ?์',
      'price': widget.stock['currentPrice'].toString(),
      'rise_percent': _parseDouble(widget.stock['changeRate']), // ???์ 
      'fall_percent': _parseDouble(widget.stock['changeRate']), // ???์ 
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
                    StockChangeInfo(stock: stock), // ??StockInfo ?๊ฑฐ
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.yellow : Colors.grey,
                      ),
                      onPressed: _toggleFavorite, // ๊ด??์ถ๊?/??  ?จ์ ?ธ์ถ
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
                      Tab(text: '์ฐจํธ'),
                      Tab(text: '๋ชจ์ ?ฌ์'),
                      Tab(text: '?ด์ค'),
                      Tab(text: '?์ธ ?๋ณด'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // ์ฐจํธ???ฌ๊ธฐ ?์ ?ผ๋ก ?ค์ 
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double chartHeight = constraints.maxHeight * 0.5; // ?๋ฉด ?์ด??๋น๋??์ฌ ์ฐจํธ ?ฌ๊ธฐ ?ค์ 
                            return SizedBox(
                              height: chartHeight,
                              child: StockChartMain(stockCode: widget.stock['stockCode']), // ์ฐจํธ ?์ฉ
                            );
                          },
                        ),
                        MockInvestmentScreen(stockCode: stockCode), // stockCode ?๋ฌ
                        NewsScreen(stockName: stockName),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : companyDescription != null
                                      ? StockDescription(stock: stock, description: companyDescription!)
                                      : Text('?์ฌ ?๊ฐ ?๋ณด๋ฅ?๋ถ๋ฌ?????์ต?๋ค.', style: TextStyle(color: Colors.red)),
                              if (stockCode.isNotEmpty) StockInfoDetail(stockCode: stockCode), // stockCode ์ฒดํฌ
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

