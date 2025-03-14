import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stockapp/investment/sortable_header.dart';
import 'package:stockapp/server/SharedPreferences/user_nickname.dart';
import 'package:stockapp/stock_api_service.dart';
import 'package:stockapp/investment/stock_list.dart';
import 'stock_detail_screen.dart'; // ???ÅÏÑ∏ ?îÎ©¥ import

class InvestmentScreen extends StatefulWidget {
  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<Map<String, dynamic>> stocks = [];
  List<Map<String, dynamic>> allStocks = [];
  List<Map<String, dynamic>> watchlistStocks = []; // ??Í¥Ä??Î™©Î°ù ?Ä??  List<Map<String, dynamic>> searchResults = []; // ??Í≤Ä??Í≤∞Í≥º ?∞Î°ú ?Ä??  bool isDropdownVisible = false;
  bool isLoading = true;
  String selectedSort = "?ÅÏäπÎ•†Ïàú";
  String selectedCategory = "?ÑÏ≤¥";
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
       final userId = await AuthService.getUserId(); // ???¨Ïö©??ID Í∞Ä?∏Ïò§Í∏?      if (selectedSort == "?ÅÏäπÎ•†Ïàú") {
        stockData = await fetchStockData("rise");
        overseasData = await fetchStockData("rise/overseas", period: "DAILY");
      } else if (selectedSort == "?òÎùΩÎ•†Ïàú") {
        stockData = await fetchStockData("fall");
        overseasData = await fetchStockData("fall/overseas", period: "DAILY");
      } else if (selectedSort == "Í±∞Îûò?âÏàú") {
        stockData = await fetchStockData("trade-volume");
        overseasData = await fetchStockData("trade-volume/overseas");
      }

// ??Í¥Ä??Î™©Î°ù Í∞Ä?∏Ïò§Í∏?      if (userId != null) {
        watchlistData = await fetchWatchlistData(userId);
      }

      setState(() {
        allStocks = [...stockData, ...overseasData];
        watchlistStocks = watchlistData; // ??Í¥Ä??Î™©Î°ù ?Ä??        _filterStocksByCategory(selectedCategory);
        isLoading = false;
      });

    } catch (e) {
      print("?∞Ïù¥??Î°úÎî© ?§Ìå®: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterStocksByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == "?ÑÏ≤¥") {
        stocks = allStocks;
      } else if (category == "Íµ?Ç¥") {
        stocks = allStocks.where((stock) => !stock.containsKey("excd")).toList();
      } else if (category == "?¥Ïô∏") {
        stocks = allStocks.where((stock) => stock.containsKey("excd")).toList();
      } else if (category == "Í¥Ä??) {
        stocks = watchlistStocks; // ??Í¥Ä??Î™©Î°ù ?úÏãú
      } else {
        stocks = [];
      }
      _sortStocks();
    });
  }

// ??null Î∞©Ïñ¥Î•?Ï∂îÍ????´Ïûê Î≥Ä???®Ïàò
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '')) ?? 0.0; // ???´Ïûê ?ºÌëú ?úÍ±∞ ??Î≥Ä??  }
  return 0.0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    return int.tryParse(value.replaceAll(',', '')) ?? 0; // ???´Ïûê ?ºÌëú ?úÍ±∞ ??Î≥Ä??  }
  return 0;
}

// ??Í¥Ä??Î™©Î°ù Í∞Ä?∏Ïò§Í∏?(UTF-8 ?îÏΩî??+ ?´ÏûêÎ°?Î≥Ä??+ null Î∞©Ïñ¥)
Future<List<Map<String, dynamic>>> fetchWatchlistData(String userId) async {
  final url = Uri.parse('http://withyou.me:8080/watchlist/$userId');
  final response = await http.get(url, headers: {'accept': '*/*'});

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(utf8.decode(response.bodyBytes)); // ??UTF-8 ?îÏΩî???ÅÏö©

    // ?îÎ≤ÑÍπÖÏö©: API?êÏÑú Î∞õÏ? ?∞Ïù¥??Ï∂úÎ†•
    print("?îπ Í¥Ä??Î™©Î°ù ?∞Ïù¥???òÏã†: ${json.encode(data)}");

    return data.map((item) {
      return {
        "stockCode": item["stockCode"] ?? "",
        "stockName": item["stockName"] ?? "?¥Î¶Ñ ?ÜÏùå",
        "stockCurrentPrice": _toDouble(item["stockCurrentPrice"]),
        "stockChange": _toDouble(item["stockChange"]),
        "stockChangePercent": _toDouble(item["stockChangePercent"]),
        "acml_vol": _toInt(item["acml_vol"]),
        "acml_tr_pbmn": _toDouble(item["acml_tr_pbmn"]),
      };
    }).toList();
  } else {
    print("??Í¥Ä??Î™©Î°ù Î∂àÎü¨?§Í∏∞ ?§Ìå®: ${response.statusCode}");
    return [];
  }
}

// ??Í¥Ä??Î™©Î°ù???¨Ìï®??Í≤ΩÏö∞ ?ïÎ†¨ Ï≤òÎ¶¨ Ï∂îÍ?
void _sortStocks() {
  setState(() {
    if (selectedCategory == "Í¥Ä??) {
      // ??Í¥Ä??Î™©Î°ù??Í≤ΩÏö∞ Î≥ÑÎèÑ ?ïÎ†¨ (Í∏∞Î≥∏?ÅÏúºÎ°?API ?∞Ïù¥?∞Îäî ?ïÎ†¨ ???òÏñ¥ ?àÏùå)
      if (selectedSort == "?ÅÏäπÎ•†Ïàú") {
        stocks.sort((a, b) => (_toDouble(b['stockChangePercent'])).compareTo(_toDouble(a['stockChangePercent'])));
      } else if (selectedSort == "?òÎùΩÎ•†Ïàú") {
        stocks.sort((a, b) => (_toDouble(a['stockChangePercent'])).compareTo(_toDouble(b['stockChangePercent'])));
      } else if (selectedSort == "Í±∞Îûò?âÏàú") {
        stocks.sort((a, b) => (_toInt(b['acml_vol'])).compareTo(_toInt(a['acml_vol'])));
      }
    }
  });
}



  // ?îπ Í≤Ä??Í∏∞Îä• (Î¶¨Ïä§?∏Ï? Î∂ÑÎ¶¨)
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

  // ?îπ Í≤Ä??Í≤∞Í≥º ?†ÌÉù ???ÅÏÑ∏ ?òÏù¥ÏßÄ ?¥Îèô
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
              _buildSortOption("?ÅÏäπÎ•†Ïàú"),
              _buildSortOption("?òÎùΩÎ•†Ïàú"),
              _buildSortOption("Í±∞Îûò?âÏàú")
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
        title: Text('Î™®Ïùò ?¨Ïûê', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ?îπ Í≤Ä?âÏ∞Ω (Î¶¨Ïä§?∏Ï? ?ÑÏ†Ñ???ÖÎ¶Ω)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: "Ï¢ÖÎ™© Í≤Ä??,
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
                
                // ?îπ ?ïÎ†¨ Î∞??ÑÌÑ∞ UI
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        children: ["?ÑÏ≤¥", "Íµ?Ç¥", "?¥Ïô∏", "Í¥Ä??].map((category) {
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

                // ?îπ Ï£ºÏãù Î¶¨Ïä§??(Í≤Ä?âÍ≥º ?ÑÏ†Ñ ?ÖÎ¶Ω)
                Expanded(
                  child: stocks.isEmpty
                      ? Center(child: Text("?∞Ïù¥???ÜÏùå", style: TextStyle(fontSize: 18, color: Colors.grey)))
                      : StockList(
                          stocks: List<Map<String, dynamic>>.from(stocks),
                          isTradeVolumeSelected: selectedSort == "Í±∞Îûò?âÏàú",
                        ),
                ),
              ],
            ),
    );
  }
}

