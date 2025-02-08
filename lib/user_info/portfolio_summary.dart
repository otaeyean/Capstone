import 'package:flutter/material.dart';

class PortfolioSummary extends StatelessWidget {
  final double totalPurchase = 4500000;
  final double totalEvaluation = 4800000;
  final double totalProfit = 300000;
  final double profitRate = 5.0;
  final double realizedProfit = 200000;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
        },
        children: [
          _buildTableRow("총매입", "${totalPurchase.toStringAsFixed(0)} 원"),
          _buildTableRow("총평가", "${totalEvaluation.toStringAsFixed(0)} 원"),
          _buildTableRow("총손익", "${totalProfit.toStringAsFixed(0)} 원"),
          _buildTableRow("수익률", "${profitRate.toStringAsFixed(2)} %"),
          _buildTableRow("실현손익", "${realizedProfit.toStringAsFixed(0)} 원"),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(value, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
