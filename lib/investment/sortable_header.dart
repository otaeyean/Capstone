import 'package:flutter/material.dart';

class SortableHeader extends StatelessWidget {
  final Function() onPriceSort;
  final Function() onVolumeSort;
  final bool isRise;  // 상승률/하락률을 토글하는 상태
  final Function() toggleChangePercentage;  // 상승률과 하락률을 토글하는 함수

  const SortableHeader({
    required this.onPriceSort,
    required this.onVolumeSort,
    required this.isRise,
    required this.toggleChangePercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderCell('회사명'),
          _buildHeaderCellWithSort('현재가', onPriceSort),
          _buildHeaderCellWithSort(isRise ? '상승률' : '하락률', toggleChangePercentage),  // 상승률/하락률을 토글하는 버튼
          _buildHeaderCellWithSort('거래량', onVolumeSort),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeaderCellWithSort(String text, Function() onSort) {
    return Expanded(
      child: GestureDetector(
        onTap: onSort,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
