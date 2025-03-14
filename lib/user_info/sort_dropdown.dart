import 'package:flutter/material.dart';
import 'package:stockapp/data/user_stock_model.dart';  // ?òÏ†ï??Î™®Îç∏ ?åÏùº ?¨Ïö©
class SortDropdown extends StatefulWidget {
  final List<UserStockModel> stocks;
  final Function(List<UserStockModel>) onSortChanged;

  SortDropdown({required this.stocks, required this.onSortChanged});

  @override
  _SortDropdownState createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  String selectedSort = "?òÏùµÎ•???;

  void _sortStocks(List<UserStockModel> stocks) {
    if (selectedSort == "?òÏùµÎ•???) {
      stocks.sort((a, b) => b.profitRate.compareTo(a.profitRate)); // ?¥Î¶ºÏ∞®Ïàú?ºÎ°ú ?ïÎ†¨
    } else if (selectedSort == "Î≥¥Ïú† ?êÏÇ∞ ??) {
      stocks.sort((a, b) => b.totalValue.compareTo(a.totalValue)); // ?¥Î¶ºÏ∞®Ïàú?ºÎ°ú ?ïÎ†¨
    }

    widget.onSortChanged(stocks); // ?ïÎ†¨??Î¶¨Ïä§?∏Î? ?ÑÎã¨
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],  // Î∞∞Í≤Ω ?âÏÉÅ
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: DropdownButton<String>(
        value: selectedSort,
        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
        isExpanded: true,
        dropdownColor: Colors.white,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        items: ["?òÏùµÎ•???, "Î≥¥Ïú† ?êÏÇ∞ ??].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedSort = newValue!;
          });
          _sortStocks(widget.stocks); // ?ïÎ†¨ ?®Ïàò ?∏Ï∂ú
        },
      ),
    );
  }
}

