import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockInfoDetail extends StatefulWidget {
  final String stockCode;

  StockInfoDetail({required this.stockCode});

  @override
  _StockInfoState createState() => _StockInfoState();
}

class _StockInfoState extends State<StockInfoDetail> {
  late Future<Map<String, dynamic>> _stockInfo;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _stockInfo = fetchStockInfo(widget.stockCode);
  }

  Future<Map<String, dynamic>> fetchStockInfo(String stockCode) async {
    final response = await http.get(
      Uri.parse('http://withyou.me:8080/stock-info/$stockCode'),
    );

    if (response.statusCode == 200) {
      await Future.delayed(Duration(milliseconds: 500)); 
      setState(() {
        _isLoaded = true;
      });
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stock info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상세 정보',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: _stockInfo,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('주식 정보를 불러올 수 없습니다.');
              } else if (!snapshot.hasData) {
                return Text('정보 없음');
              }

              final stockData = snapshot.data!;
              final stockInfoMap = {
                '거래량': stockData['tvol'],
                '매수 가능': '100',
                '고가': stockData['hypr'],
                '저가': stockData['lopr'],
                '52주 최고가': stockData['h52p'],
                '52주 최저가': stockData['l52p'],
                '시가 총액': stockData['tomv'],
                '시가 총액 순위': '2,317',
                'PER': stockData['per'],
                '외인보유비중': '0.0',
              };

              return AnimatedOpacity(
                opacity: _isLoaded ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], 
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: stockInfoMap.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              entry.value.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
