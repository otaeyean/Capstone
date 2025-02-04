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
      stocks.sort((a, b) => isPriceAscending
          ? a['price'].compareTo(b['price'])
          : b['price'].compareTo(a['price']));
    });
  }

  // 거래량 정렬
  void _sortByVolume() {
    setState(() {
      isVolumeAscending = !isVolumeAscending;
      stocks.sort((a, b) => isVolumeAscending
          ? a['quantity'].compareTo(b['quantity'])
          : b['quantity'].compareTo(a['quantity']));
    });
  }

  // 상승률과 하락률 토글
  void _toggleChangePercentage() {
    setState(() {
      isRise = !isRise; // 상승률과 하락률을 전환
    });
  }

  // 상승률 계산 (주식 가격 변화율)
  double _calculateChangePercent(Map<String, dynamic> stock) {
    double price = double.tryParse(stock['price'].toString().replaceAll(',', '').replaceAll('원', '')) ?? 0.0;
    double changeValue = double.tryParse(stock['change_value'].toString()) ?? 0.0;
    return (changeValue / price) * 100;
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
                SortableHeader(
                  onPriceSort: _sortByPrice,
                  onVolumeSort: _sortByVolume,
                  isRise: isRise,
                  toggleChangePercentage: _toggleChangePercentage,
                ),
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
