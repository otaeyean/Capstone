import 'package:flutter/material.dart';

class StockSortHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(),

        // 🔹 테이블 헤더
        Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderCell("자산명", flex: 3),
              _buildHeaderCell("현재가", flex: 2),
              _buildHeaderCell("등락률", flex: 2),
              _buildHeaderCell("거래량", flex: 2),
            ],
          ),
        ),
      ],
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
}
