import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stockapp/investment/sortable_header.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/stock_api_service.dart';
import 'package:stockapp/investment/stock_list.dart';
import 'stock_detail_screen.dart'; // ???�세 ?�면 import

class InvestmentScreen extends StatefulWidget {
  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<Map<String, dynamic>> stocks = [];
  List<Map<String, dynamic>> allStocks = [];
  List<Map<String, dynamic>> watchlistStocks = []; // ??관??목록 ?�??  List<Map<String, dynamic>> searchResults = []; // ??검??결과 ?�로 ?�??  bool isDropdownVisible = false;
  bool isLoading = true;
  String selectedSort = "?�승률순";
  String selectedCategory = "?�체";
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> stockData = [];
    List<Map<String, dynamic>> overseasData = [];
    List<Map<String, dynamic>> watchlistData = [];

    try {
       final userId = await AuthService.getUserId(); // ???�용??ID 가?�오�?      if (selectedSort == "?�승률순") {
        stockData = await fetchStockData("rise");
        overseasData = await fetchStockData("rise/overseas", period: "DAILY");
      } else if (selectedSort == "?�락률순") {
        stockData = await fetchStockData("fall");
        overseasData = await fetchStockData("fall/overseas", period: "DAILY");
      } else if (selectedSort == "거래?�순") {
        stockData = await fetchStockData("trade-volume");
        overseasData = await fetchStockData("trade-volume/overseas");
      }

// ??관??목록 가?�오�?      if (userId != null) {
        watchlistData = await fetchWatchlistData(userId);
      }

      setState(() {
        allStocks = [...stockData, ...overseasData];
        watchlistStocks = watchlistData; // ??관??목록 ?�??        _filterStocksByCategory(selectedCategory);
        isLoading = false;
      });

    } catch (e) {
      print("?�이??로딩 ?�패: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterStocksByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == "?�체") {
        stocks = allStocks;
      } else if (category == "�?��") {
        stocks = allStocks.where((stock) => !stock.containsKey("excd")).toList();
      } else if (category == "?�외") {
        stocks = allStocks.where((stock) => stock.containsKey("excd")).toList();
      } else if (category == "관??) {
        stocks = watchlistStocks; // ??관??목록 ?�시
      } else {
        stocks = [];
      }
      _sortStocks();
    });
  }

// ??null 방어�?추�????�자 변???�수
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '')) ?? 0.0; // ???�자 ?�표 ?�거 ??변??  }
  return 0.0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    return int.tryParse(value.replaceAll(',', '')) ?? 0; // ???�자 ?�표 ?�거 ??변??  }
  return 0;
}

// ??관??목록 가?�오�?(UTF-8 ?�코??+ ?�자�?변??+ null 방어)
Future<List<Map<String, dynamic>>> fetchWatchlistData(String userId) async {
  final url = Uri.parse('http://withyou.me:8080/watchlist/$userId');
  final response = await http.get(url, headers: {'accept': '*/*'});

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(utf8.decode(response.bodyBytes)); // ??UTF-8 ?�코???�용

    // ?�버깅용: API?�서 받�? ?�이??출력
    print("?�� 관??목록 ?�이???�신: ${json.encode(data)}");

    return data.map((item) {
      return {
        "stockCode": item["stockCode"] ?? "",
        "stockName": item["stockName"] ?? "?�름 ?�음",
        "stockCurrentPrice": _toDouble(item["stockCurrentPrice"]),
        "stockChange": _toDouble(item["stockChange"]),
        "stockChangePercent": _toDouble(item["stockChangePercent"]),
        "acml_vol": _toInt(item["acml_vol"]),
        "acml_tr_pbmn": _toDouble(item["acml_tr_pbmn"]),
      };
    }).toList();
  } else {
    print("??관??목록 불러?�기 ?�패: ${response.statusCode}");
    return [];
  }
}

// ??관??목록???�함??경우 ?�렬 처리 추�?
void _sortStocks() {
  setState(() {
    if (selectedCategory == "관??) {
      // ??관??목록??경우 별도 ?�렬 (기본?�으�?API ?�이?�는 ?�렬 ???�어 ?�음)
      if (selectedSort == "?�승률순") {
        stocks.sort((a, b) => (_toDouble(b['stockChangePercent'])).compareTo(_toDouble(a['stockChangePercent'])));
      } else if (selectedSort == "?�락률순") {
        stocks.sort((a, b) => (_toDouble(a['stockChangePercent'])).compareTo(_toDouble(b['stockChangePercent'])));
      } else if (selectedSort == "거래?�순") {
        stocks.sort((a, b) => (_toInt(b['acml_vol'])).compareTo(_toInt(a['acml_vol'])));
      }
    }
  });
}



  // ?�� 검??기능 (리스?��? 분리)
  void _filterStocksByQuery(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = [];
        isDropdownVisible = false;
      } else {
        searchResults = allStocks
            .where((stock) => stock['stockName'].toString().toLowerCase().startsWith(query.toLowerCase()))
            .toList();
        isDropdownVisible = searchResults.isNotEmpty;
      }
    });
  }

  // ?�� 검??결과 ?�택 ???�세 ?�이지 ?�동
  void _goToStockDetail(Map<String, dynamic> stock) {
    setState(() {
      _searchController.text = stock['stockName'];
      isDropdownVisible = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailScreen(stock: stock),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption("?�승률순"),
              _buildSortOption("?�락률순"),
              _buildSortOption("거래?�순")
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option) {
    return ListTile(
      title: Text(option,
          style: TextStyle(
              fontSize: 14,
              fontWeight: selectedSort == option ? FontWeight.bold : FontWeight.normal,
              color: selectedSort == option ? Colors.blue : Colors.black)),
      trailing: selectedSort == option ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        Navigator.pop(context);
        setState(() {
          selectedSort = option;
          _loadStockData();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('모의 ?�자', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ?�� 검?�창 (리스?��? ?�전???�립)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: "종목 검??,
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: _filterStocksByQuery,
                      ),
                      if (isDropdownVisible)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: Column(
                            children: searchResults.map((stock) {
                              return ListTile(
                                title: Text(stock['stockName']),
                                onTap: () => _goToStockDetail(stock),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // ?�� ?�렬 �??�터 UI
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: ["?�체", "�?��", "?�외", "관??].map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: GestureDetector(
                              onTap: () => _filterStocksByCategory(category),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedCategory == category ? Colors.red : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 16),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextButton(
                        onPressed: _showSortOptions,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(selectedSort, style: TextStyle(color: Colors.black, fontSize: 14)),
                            Icon(Icons.arrow_drop_down, color: Colors.black, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                StockSortHeader(),

                // ?�� 주식 리스??(검?�과 ?�전 ?�립)
                Expanded(
                  child: stocks.isEmpty
                      ? Center(child: Text("?�이???�음", style: TextStyle(fontSize: 18, color: Colors.grey)))
                      : StockList(
                          stocks: List<Map<String, dynamic>>.from(stocks),
                          isTradeVolumeSelected: selectedSort == "거래?�순",
                        ),
                ),
              ],
            ),
    );
  }
}

