import 'package:flutter/material.dart';
import 'package:stockapp/investment/sortable_header.dart';
import 'package:stockapp/investment/stock_list.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'stock_detail_screen.dart';

class InvestmentScreen extends StatefulWidget {
  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<Map<String, dynamic>> stocks = [];
  bool isPriceAscending = true;
  bool isVolumeAscending = true;
  bool isRise = true;  // 기본 상승률로 설정

  // JSON 파일에서 데이터 로드
  Future<void> loadUserStockData() async {
    String jsonString = await rootBundle.loadString('assets/user_stock_data.json');
    final data = jsonDecode(jsonString);
    setState(() {
      stocks = List<Map<String, dynamic>>.from(data['stocks']);
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserStockData();
  }

  // 가격 정렬
  void _sortByPrice() {
    setState(() {
      isPriceAscending = !isPriceAscending;
      stocks.sort((a, b) {
        // 가격을 숫자로 변환하여 비교
        double priceA = double.tryParse(a['price'].toString().replaceAll(',', '').replaceAll('원', '')) ?? 0.0;
        double priceB = double.tryParse(b['price'].toString().replaceAll(',', '').replaceAll('원', '')) ?? 0.0;
        return isPriceAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      });
    });
  }

  // 거래량 정렬
  void _sortByVolume() {
    setState(() {
      isVolumeAscending = !isVolumeAscending;
      stocks.sort((a, b) {
        // 거래량을 숫자로 변환하여 비교
        return isVolumeAscending
            ? a['quantity'].compareTo(b['quantity'])
            : b['quantity'].compareTo(a['quantity']);
      });
    });
  }

  // 상승률과 하락률 토글
  void _toggleChangePercentage() {
    setState(() {
      isRise = !isRise; // 상승률과 하락률을 전환
    });
  }

double _calculateChangePercent(Map<String, dynamic> stock) {
  double price = double.tryParse(stock['price'].toString().replaceAll(',', '').replaceAll('원', '')) ?? 0.0;
  double changeValue = double.tryParse(stock['change_value'].toString()) ?? 0.0;

  // 상승률/하락률을 계산 (현재가 기준)
  double changePercent = (price != 0) ? (changeValue / price) * 100 : 0.0;

  return isRise ? (changePercent > 0 ? changePercent : 0.0) : (changePercent < 0 ? changePercent.abs() : 0.0);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('모의 투자'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                // 정렬 가능한 헤더 추가
                SortableHeader(
                  onPriceSort: _sortByPrice,
                  onVolumeSort: _sortByVolume,
                  isRise: isRise,
                  toggleChangePercentage: _toggleChangePercentage,
                ),
                // 주식 목록 추가
                StockList(
                  stocks: stocks,
                  isRise: isRise,
                  toggleChangePercentage: _toggleChangePercentage,
                  calculateChangePercent: _calculateChangePercent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
