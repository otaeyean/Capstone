import 'package:flutter/material.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import './detail_widgets/stock_change_info.dart';
import 'chart/chart_main.dart';
import './news/news.dart';
import './investment_main/mock_investment_screen.dart';
import './detail_widgets/description.dart';
import 'package:stockapp/server/investment/stock_description_server.dart'; // API ?îÏ≤≠ Ï∂îÍ?
import 'package:stockapp/investment/detail_widgets/stock_info.dart'; // ??StockInfo Ï∂îÍ?
import 'package:stockapp/investment/detail_widgets/info.dart';
import 'package:http/http.dart' as http; // Ï∂îÍ?: HTTP ?îÏ≤≠???ÑÌïú ?ºÏù¥Î∏åÎü¨Î¶?
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
        companyDescription = 'Ï£ºÏãù ?¥Î¶Ñ???ÜÏäµ?àÎã§.';
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
        companyDescription = '?åÏÇ¨ ?åÍ∞úÎ•?Î∂àÎü¨?§Îäî ???§Ìå®?àÏäµ?àÎã§.';
        isLoading = false;
      });
    }
  }

  // Í¥Ä??Ï∂îÍ?/??†ú API ?∏Ï∂ú
  Future<void> _toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    // ?Ä?•Îêú userId (nickname) Í∞Ä?∏Ïò§Í∏?    final userId = await AuthService.getUserId(); // AuthService?êÏÑú nickname??Í∞Ä?∏Ïò¥
    if (userId == null) {
      final snackBar = SnackBar(content: Text('Î°úÍ∑∏?∏Ïù¥ ?ÑÏöî?©Îãà??'));
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
          content: Text(isFavorite ? 'Í¥Ä????™©?ºÎ°ú ?±Î°ù?òÏóà?µÎãà?? : 'Í¥Ä????™©?êÏÑú ??†ú?òÏóà?µÎãà??),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final errorMessage = 'API ?îÏ≤≠ ?§Ìå®: ${response.statusCode}';
        final snackBar = SnackBar(content: Text(errorMessage));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        print('API ?∏Ï∂ú ?§Ìå®: $errorMessage');
      }
    } catch (e) {
      setState(() {
        isFavorite = !isFavorite; // API ?§Ìå® ???ÅÌÉú ?òÎèåÎ¶¨Í∏∞
      });
      final snackBar = SnackBar(content: Text('Í¥Ä????™© Ï∂îÍ?/??†ú???§Ìå®?àÏäµ?àÎã§.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('?êÎü¨ Î∞úÏÉù: $e');
    }
  }

  // ???àÏ†Ñ??Î¨∏Ïûê??-> double Î≥Ä???®Ïàò
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
      'name': widget.stock['stockName'] ?? '?¥Î¶Ñ ?ÜÏùå',
      'price': widget.stock['currentPrice'].toString(),
      'rise_percent': _parseDouble(widget.stock['changeRate']), // ???òÏ†ï
      'fall_percent': _parseDouble(widget.stock['changeRate']), // ???òÏ†ï
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
                    StockChangeInfo(stock: stock), // ??StockInfo ?úÍ±∞
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.yellow : Colors.grey,
                      ),
                      onPressed: _toggleFavorite, // Í¥Ä??Ï∂îÍ?/??†ú ?®Ïàò ?∏Ï∂ú
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
                      Tab(text: 'Ï∞®Ìä∏'),
                      Tab(text: 'Î™®Ïùò ?¨Ïûê'),
                      Tab(text: '?¥Ïä§'),
                      Tab(text: '?ÅÏÑ∏ ?ïÎ≥¥'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Ï∞®Ìä∏???¨Í∏∞ ?ôÏ†Å?ºÎ°ú ?§Ï†ï
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double chartHeight = constraints.maxHeight * 0.5; // ?îÎ©¥ ?íÏù¥??ÎπÑÎ??òÏó¨ Ï∞®Ìä∏ ?¨Í∏∞ ?§Ï†ï
                            return SizedBox(
                              height: chartHeight,
                              child: StockChartMain(stockCode: widget.stock['stockCode']), // Ï∞®Ìä∏ ?ÅÏö©
                            );
                          },
                        ),
                        MockInvestmentScreen(stockCode: stockCode), // stockCode ?ÑÎã¨
                        NewsScreen(stockName: stockName),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : companyDescription != null
                                      ? StockDescription(stock: stock, description: companyDescription!)
                                      : Text('?åÏÇ¨ ?åÍ∞ú ?ïÎ≥¥Î•?Î∂àÎü¨?????ÜÏäµ?àÎã§.', style: TextStyle(color: Colors.red)),
                              if (stockCode.isNotEmpty) StockInfoDetail(stockCode: stockCode), // stockCode Ï≤¥ÌÅ¨
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

