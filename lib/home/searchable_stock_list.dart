import 'package:flutter/material.dart';
import 'package:stockapp/investment/stock_detail_screen.dart';

class SearchableStockList extends StatefulWidget {
  final List<Map<String, dynamic>> stockList;

  SearchableStockList({required this.stockList});

  @override
  _SearchableStockListState createState() => _SearchableStockListState();
}

class _SearchableStockListState extends State<SearchableStockList> {
  List<Map<String, dynamic>> filteredStocks = [];  // 필터링된 주식 목록을 저장
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredStocks = [];  // 초기에는 빈 리스트로 설정하여 자동완성 목록을 숨깁니다.
  }

  void _filterStocks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStocks = [];  // 검색어가 없으면 빈 리스트로 설정하여 자동완성 목록을 숨깁니다.
      } else {
        filteredStocks = widget.stockList
            .where((stock) => stock['stockName']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색 입력창
        TextField(
          controller: _controller,
          onChanged: _filterStocks,  // 사용자가 입력할 때마다 _filterStocks 호출
          decoration: InputDecoration(
            hintText: '검색',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        // 자동완성 목록을 보여줄 때
        if (filteredStocks.isNotEmpty)  // 필터링된 결과가 있을 때만 리스트 표시
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            constraints: BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: filteredStocks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredStocks[index]['stockName']!,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDetailScreen(stock: filteredStocks[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
