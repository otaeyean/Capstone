import 'package:flutter/material.dart';

class SortableHeader extends StatelessWidget {
  final Function() onPriceSort;
  final Function() onVolumeSort;
  final Function() onChangeSort;
  final bool isRise;
  final Function() toggleChangePercentage;

  const SortableHeader({
    required this.onPriceSort,
    required this.onVolumeSort,
    required this.onChangeSort,
    required this.isRise,
    required this.toggleChangePercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderCell("자산명", flex: 3),
          _buildHeaderCellWithSort("현재가", onPriceSort, flex: 2),
          _buildHeaderCellWithSort(isRise ? "상승률" : "하락률", () {
            toggleChangePercentage();
            onChangeSort();
          }, flex: 2),
          _buildHeaderCellWithSort("거래량", onVolumeSort, flex: 2),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildHeaderCellWithSort(String text, Function() onSort, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onSort,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
