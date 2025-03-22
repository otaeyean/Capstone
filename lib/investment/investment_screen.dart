import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stockapp/home/searchable_stock_list.dart';
import 'package:stockapp/investment/sortable_header.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/stock_api_service.dart';
import 'package:stockapp/investment/stock_list.dart';
import 'stock_detail_screen.dart'; // ✅ 상세 화면 import

class InvestmentScreen extends StatefulWidget {
  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<Map<String, dynamic>> stocks = [];
  List<Map<String, dynamic>> allStocks = [];
  List<Map<String, dynamic>> watchlistStocks = []; // ✅ 관심 목록 저장
  bool isDropdownVisible = false;
  bool isLoading = true;
  bool isSearchLoading = false; // 검색 데이터 로딩 상태
  String selectedSort = "상승률순";
  String selectedCategory = "전체";

  List<Map<String, dynamic>> searchStockList = []; // 새로 받아올 주식 리스트 검색용

  @override
  void initState() {
    super.initState();
    _loadStockData(); // 기본 주식 데이터 로드
    _loadSearchStockData();
  }

  Future<void> _loadStockData() async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> stockData = [];
    List<Map<String, dynamic>> overseasData = [];
    List<Map<String, dynamic>> watchlistData = [];

    try {
      final userId = await AuthService.getUserId(); // ✅ 사용자 ID 가져오기
      if (selectedSort == "상승률순") {
        stockData = await fetchStockData("rise");
        overseasData = await fetchStockData("rise/overseas", period: "DAILY");
      } else if (selectedSort == "하락률순") {
        stockData = await fetchStockData("fall");
        overseasData = await fetchStockData("fall/overseas", period: "DAILY");
      } else if (selectedSort == "거래량순") {
        stockData = await fetchStockData("trade-volume");
        overseasData = await fetchStockData("trade-volume/overseas");
      }

      // ✅ 관심 목록 가져오기
      if (userId != null) {
        watchlistData = await fetchWatchlistData(userId);
      }

      setState(() {
        allStocks = [...stockData, ...overseasData];
        watchlistStocks = watchlistData; // ✅ 관심 목록 저장
        _filterStocksByCategory(selectedCategory);
        isLoading = false;
      });

    } catch (e) {
      print("데이터 로딩 실패: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 관심 목록 가져오는 부분 (UTF-8 디코딩 적용)
  Future<List<Map<String, dynamic>>> fetchWatchlistData(String userId) async {
    final url = Uri.parse('http://withyou.me:8080/watchlist/$userId');
    final response = await http.get(url, headers: {'accept': '*/*'});

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes)); // ✅ UTF-8 디코딩 적용

      // 디버깅용: API에서 받은 데이터 출력
      print("🔹 관심 목록 데이터 수신: ${json.encode(data)}");

      return data.map((item) {
        return {
          "stockCode": item["stockCode"] ?? "",
          "stockName": item["stockName"] ?? "이름 없음",
          "stockCurrentPrice": _toDouble(item["stockCurrentPrice"]),
          "stockChange": _toDouble(item["stockChange"]),
          "stockChangePercent": _toDouble(item["stockChangePercent"]),
          "acml_vol": _toInt(item["acml_vol"]),
          "acml_tr_pbmn": _toDouble(item["acml_tr_pbmn"]),
        };
      }).toList();
    } else {
      print("❌ 관심 목록 불러오기 실패: ${response.statusCode}");
      return [];
    }
  }

  // 주식 리스트 가져오는 부분 (UTF-8 디코딩 적용)
  Future<void> _loadSearchStockData() async {
    setState(() {
      isSearchLoading = true; // 검색 데이터 로딩 시작
    });

    try {
      final response = await http.get(Uri.parse('http://withyou.me:8080/stock-list'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(utf8.decode(response.bodyBytes)); // ✅ UTF-8 디코딩 적용
        setState(() {
          searchStockList = data.map((item) => {
            'stockCode': item['stockCode'],
            'stockName': item['stockName'],
          }).toList();
          isSearchLoading = false; // 검색 데이터 로딩 완료
        });
      } else {
        throw Exception('주식 리스트를 가져오는 데 실패했습니다.');
      }
    } catch (e) {
      setState(() {
        isSearchLoading = false; // 로딩 실패시에도 false로 설정
      });
      print("Error fetching stock data: $e");
    }
  }

  void _filterStocksByCategory(String category) {
    setState(() {
      selectedCategory = category;
       isLoading = true; // 로딩 상태로 설정
      if (category == "전체") {
        stocks = allStocks;
      } else if (category == "국내") {
        stocks = allStocks.where((stock) => !stock.containsKey("excd")).toList();
      } else if (category == "해외") {
        stocks = allStocks.where((stock) => stock.containsKey("excd")).toList();
      } else if (category == "관심") {
         _loadStockData(); 
        stocks = watchlistStocks; // ✅ 관심 목록 표시
      } else {
        stocks = [];
      }
      _sortStocks();
        isLoading = false; // 로딩 완료
    });
  }

  // ✅ null 방어를 추가한 숫자 변환 함수
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '')) ?? 0.0; // ✅ 숫자 쉼표 제거 후 변환
    }
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value.replaceAll(',', '')) ?? 0; // ✅ 숫자 쉼표 제거 후 변환
    }
    return 0;
  }

  // ✅ 관심 목록이 포함될 경우 정렬 처리 추가
  void _sortStocks() {
    setState(() {
      if (selectedCategory == "관심") {
        // ✅ 관심 목록일 경우 별도 정렬 (기본적으로 API 데이터는 정렬 안 되어 있음)
        if (selectedSort == "상승률순") {
          stocks.sort((a, b) => (_toDouble(b['stockChangePercent'])).compareTo(_toDouble(a['stockChangePercent'])));
        } else if (selectedSort == "하락률순") {
          stocks.sort((a, b) => (_toDouble(a['stockChangePercent'])).compareTo(_toDouble(b['stockChangePercent'])));
        } else if (selectedSort == "거래량순") {
          stocks.sort((a, b) => (_toInt(b['acml_vol'])).compareTo(_toInt(a['acml_vol'])));
        }
      }
    });
  }

  // 🔹 정렬 및 필터 UI
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
              _buildSortOption("상승률순"),
              _buildSortOption("하락률순"),
              _buildSortOption("거래량순")
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
        title: Text('모의 투자', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔹 검색 리스트 화면
                isSearchLoading
                    ? Center(child: CircularProgressIndicator())
                    : SearchableStockList(stockList: searchStockList), // 검색 위젯에 검색 데이터 전달

                // 🔹 정렬 및 필터 UI
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: ["전체", "국내", "해외", "관심"].map((category) {
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

                // 🔹 주식 리스트
                Expanded(
                  child: stocks.isEmpty
                      ? Center(child: Text("데이터 없음", style: TextStyle(fontSize: 18, color: Colors.grey)))
                      : StockList(
                          stocks: List<Map<String, dynamic>>.from(stocks),
                          isTradeVolumeSelected: selectedSort == "거래량순",
                        ),
                ),
              ],
            ),
    );
  }
}
