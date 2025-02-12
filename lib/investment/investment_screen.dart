import 'package:flutter/material.dart';
import 'package:stockapp/investment/sortable_header.dart';
import 'package:stockapp/stock_api_service.dart';
import 'stock_list.dart';


class InvestmentScreen extends StatefulWidget {
  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<Map<String, dynamic>> stocks = [];
  List<Map<String, dynamic>> filteredStocks = [];
  bool isLoading = true;
  String selectedSort = "상승률순"; // ✅ 기본 정렬 방식
  String selectedCategory = "전체"; // ✅ 기본 카테고리

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  // 🔹 API 호출 (정렬 기준 변경 시)
  Future<void> _loadStockData() async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> stockData = [];
    try {
      if (selectedSort == "상승률순") {
        stockData = await fetchStockData("rise");
      } else if (selectedSort == "하락률순") {
        stockData = await fetchStockData("fall");
      } else if (selectedSort == "거래량순") {
        stockData = await fetchStockData("trade-volume");
      }

      setState(() {
        stocks = stockData;
        _filterStocksByCategory(); // ✅ 카테고리에 맞게 필터링
        isLoading = false;
      });
    } catch (e) {
      print("🚨 데이터 로딩 실패: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🔹 카테고리 필터링
  void _filterStocksByCategory() {
    setState(() {
      if (selectedCategory == "전체") {
        filteredStocks = List.from(stocks);
      } else {
        filteredStocks = stocks
            .where((stock) => stock['category'] == selectedCategory)
            .toList();
      }
    });
  }

  // 🔹 정렬 옵션 선택 바텀시트
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption("상승률순"),
              _buildSortOption("하락률순"),
              _buildSortOption("거래량순"),
            ],
          ),
        );
      },
    );
  }

  // 🔹 정렬 옵션 UI
  Widget _buildSortOption(String option) {
    return ListTile(
      title: Text(
        option,
        style: TextStyle(
          fontSize: 18,
          fontWeight: selectedSort == option ? FontWeight.bold : FontWeight.normal,
          color: selectedSort == option ? Colors.blue : Colors.black,
        ),
      ),
      trailing: selectedSort == option ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {
        setState(() {
          selectedSort = option;
        });
        Navigator.pop(context);
        _loadStockData();
      },
    );
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
          // 🔹 정렬 기준 버튼 (오른쪽 상단)
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200], // ✅ 회색 배경 추가
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: _showSortOptions,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size(100, 40), // ✅ 네모 박스 느낌 유지
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                children: [
                  Text(
                    selectedSort, // ✅ 선택한 정렬 방식 표시
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_drop_down, color: Colors.black), // ✅ 아래 화살표 아이콘 추가
                ],
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔹 카테고리 선택 (아래로 이동)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ["전체", "국내", "해외", "관심"].map((category) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                            _filterStocksByCategory();
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
                ),

                // 🔹 테이블 헤더 (정렬 기능 제거된 UI)
                StockSortHeader(),

                // 🔹 주식 목록
                Expanded(
                  child: StockList(
                    endpoint: selectedSort == "거래량순" ? "trade-volume" : (selectedSort == "상승률순" ? "rise" : "fall"),
                    period: "DAILY",
                  ),
                ),
              ],
            ),
    );
  }
}
