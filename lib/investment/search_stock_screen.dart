import 'package:flutter/material.dart';

class SearchStockScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allStocks;

  const SearchStockScreen({required this.allStocks});

  @override
  _SearchStockScreenState createState() => _SearchStockScreenState();
}

class _SearchStockScreenState extends State<SearchStockScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredStocks = [];

  @override
  void initState() {
    super.initState();
    filteredStocks = widget.allStocks; // 초기에는 전체 리스트 표시
  }

  // 🔹 검색 필터 적용
  void _filterStocks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStocks = widget.allStocks;
      } else {
        filteredStocks = widget.allStocks
            .where((stock) => stock['stockName'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 검색창 UI
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterStocks,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              hintText: "종목 검색",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),

        // 🔹 검색 결과 리스트
        Expanded(
          child: ListView.builder(
            itemCount: filteredStocks.length,
            itemBuilder: (context, index) {
              var stock = filteredStocks[index];

              return ListTile(
                title: Text(stock['stockName']),
                subtitle: Text("현재가: ${stock['currentPrice']}"),
                onTap: () {
                  Navigator.pop(context, stock);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
