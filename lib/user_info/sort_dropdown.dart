import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart';  // ?�정??모델 ?�일 ?�용
class SortDropdown extends StatefulWidget {
  final List<UserStockModel> stocks;
  final Function(List<UserStockModel>) onSortChanged;

  SortDropdown({required this.stocks, required this.onSortChanged});

  @override
  _SortDropdownState createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  String selectedSort = "?�익�???;

  void _sortStocks(List<UserStockModel> stocks) {
    if (selectedSort == "?�익�???) {
      stocks.sort((a, b) => b.profitRate.compareTo(a.profitRate)); // ?�림차순?�로 ?�렬
    } else if (selectedSort == "보유 ?�산 ??) {
      stocks.sort((a, b) => b.totalValue.compareTo(a.totalValue)); // ?�림차순?�로 ?�렬
    }

    widget.onSortChanged(stocks); // ?�렬??리스?��? ?�달
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],  // 배경 ?�상
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: DropdownButton<String>(
        value: selectedSort,
        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
        isExpanded: true,
        dropdownColor: Colors.white,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        items: ["?�익�???, "보유 ?�산 ??].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedSort = newValue!;
          });
          _sortStocks(widget.stocks); // ?�렬 ?�수 ?�출
        },
      ),
    );
  }
}

