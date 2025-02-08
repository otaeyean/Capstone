import 'package:flutter/material.dart';
import 'package:stockapp/investment/sortable_header.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'stock_list.dart';

class InvestmentScreen extends StatefulWidget {
  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<Map<String, dynamic>> stocks = [];
  List<Map<String, dynamic>> filteredStocks = [];
  List<String> searchSuggestions = [];
  bool isPriceAscending = true;
  bool isVolumeAscending = true;
  bool isRise = true;
  String selectedCategory = "전체";
  String searchQuery = "";

  // 🔹 모든 주식 데이터를 로드
  Future<void> loadStockData() async {
    String jsonString = await rootBundle.loadString('assets/company_data.json');
    final data = jsonDecode(jsonString);

    setState(() {
      stocks = List<Map<String, dynamic>>.from(data['stocks']);
      filteredStocks = List.from(stocks); // 🔹 전체 리스트 유지
    });

    print("로드된 주식 개수: ${stocks.length}"); // 🛠 디버깅 출력
  }

  @override
  void initState() {
    super.initState();
    loadStockData();
  }

  // 🔹 검색 자동완성 및 필터링
  void _filterStocks(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredStocks = List.from(stocks); // 검색어 없을 때 전체 리스트 유지
        searchSuggestions = [];
      } else {
        // 🔹 자동완성 목록
        searchSuggestions = stocks
            .where((stock) => stock['name'].toString().contains(query))
            .map((stock) => stock['name'].toString())
            .toList();
      }
    });
  }

  // 🔹 가격 정렬
  void _sortByPrice() {
    setState(() {
      isPriceAscending = !isPriceAscending;
      filteredStocks.sort((a, b) {
        double priceA = double.tryParse(a['price'].toString().replaceAll(',', '').replaceAll('원', '')) ?? 0.0;
        double priceB = double.tryParse(b['price'].toString().replaceAll(',', '').replaceAll('원', '')) ?? 0.0;
        return isPriceAscending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      });
    });
  }

  // 🔹 거래량 정렬
  void _sortByVolume() {
    setState(() {
      isVolumeAscending = !isVolumeAscending;
      filteredStocks.sort((a, b) {
        return isVolumeAscending
            ? a['quantity'].compareTo(b['quantity'])
            : b['quantity'].compareTo(a['quantity']);
      });
    });
  }

  // 🔹 상승률/하락률 정렬 (null 값 대비)
  void _sortByChangePercent() {
    setState(() {
      filteredStocks.sort((a, b) {
        double percentA = isRise ? (a['rise_percent'] ?? 0.0) : (a['fall_percent'] ?? 0.0);
        double percentB = isRise ? (b['rise_percent'] ?? 0.0) : (b['fall_percent'] ?? 0.0);
        return percentB.compareTo(percentA);
      });
    });

 
  }

  // 🔹 상승률과 하락률 토글
  void _toggleChangePercentage() {
    setState(() {
      isRise = !isRise;
      _sortByChangePercent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('모의 투자'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // 🔹 검색창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  onChanged: _filterStocks,
                  decoration: InputDecoration(
                    hintText: '검색',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
                if (searchSuggestions.isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: searchSuggestions
                          .map((suggestion) => ListTile(
                                title: Text(suggestion),
                                onTap: () {
                                  setState(() {
                                    searchQuery = suggestion;
                                    searchSuggestions = [];
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),

          // 🔹 카테고리 선택
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["전체", "국내", "해외", "관심"].map((category) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedCategory == category ? Colors.red : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10),

          // 🔹 정렬 가능한 헤더
          SortableHeader(
            onPriceSort: _sortByPrice,
            onVolumeSort: _sortByVolume,
            onChangeSort: _sortByChangePercent,
            isRise: isRise,
            toggleChangePercentage: _toggleChangePercentage,
          ),

          // 🔹 주식 목록
          Expanded(
            child: StockList(
              stocks: filteredStocks,
              isRise: isRise,
              toggleChangePercentage: _toggleChangePercentage,
            ),
          ),
        ],
      ),
    );
  }
}
