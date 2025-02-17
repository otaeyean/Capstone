import 'package:flutter/material.dart';
import 'package:stockapp/server/userInfo/portfolio_server.dart';

class PortfolioSummary extends StatefulWidget {
  final String userId;
  PortfolioSummary({required this.userId});

  @override
  _PortfolioSummaryState createState() => _PortfolioSummaryState();
}

class _PortfolioSummaryState extends State<PortfolioSummary> {
  late Future<Map<String, dynamic>> _portfolioData;

  @override
  void initState() {
    super.initState();
    print("✅ PortfolioSummary에서 받은 userId: ${widget.userId}");

  if (widget.userId.isEmpty) {
    print("❌ userId가 비어 있음! 기본값으로 대체해야 함.");
  }
    _portfolioData = PortfolioService.fetchPortfolioData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _portfolioData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        } else {
          final data = snapshot.data!;
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
                _buildTableRow("총매입", "${data['totalPurchase']} 원"),
                _buildTableRow("총평가", "${data['totalEvaluation']} 원"),
                _buildTableRow("총손익", "${data['totalProfit']} 원"),
                _buildTableRow("수익률", "${data['totalProfitRate']} %"),
                _buildTableRow("실현손익", "${data['realizedProfit']} 원"),
              ],
            ),
          );
        }
      },
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
