import 'package:flutter/material.dart';
import 'package:stockapp/investment/sortable_header.dart';
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
  List<Map<String, dynamic>> searchResults = []; // ✅ 검색 결과 따로 저장
  bool isDropdownVisible = false;
  bool isLoading = true;
  String selectedSort = "상승률순";
  String selectedCategory = "전체";
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

    try {
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

      setState(() {
        allStocks = [...stockData, ...overseasData];
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

  void _filterStocksByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == "전체") {
        stocks = allStocks;
      } else if (category == "국내") {
        stocks = allStocks.where((stock) => !stock.containsKey("excd")).toList();
      } else if (category == "해외") {
        stocks = allStocks.where((stock) => stock.containsKey("excd")).toList();
      } else {
        stocks = [];
      }
    });
  }

  // 🔹 검색 기능 (리스트와 분리)
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

  // 🔹 검색 결과 선택 시 상세 페이지 이동
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
                // 🔹 검색창 (리스트와 완전히 독립)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: "종목 검색",
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

                // 🔹 주식 리스트 (검색과 완전 독립)
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
