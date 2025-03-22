import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stockapp/server/userInfo/portfolio_server.dart';

class PortfolioSummary extends StatefulWidget {
  final String userId;
  PortfolioSummary({required this.userId});

  @override
  _PortfolioSummaryState createState() => _PortfolioSummaryState();
}

class _PortfolioSummaryState extends State<PortfolioSummary> {
  String totalPurchase = "0 원";
  String totalEvaluation = "0 원";
  String totalProfit = "0 원";
  String totalProfitRate = "0 %";
  String errorMessage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchPortfolio(); 

    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchPortfolio();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  void _fetchPortfolio() async {
    try {
      final data = await PortfolioService.fetchPortfolioData(widget.userId);
      setState(() {
        totalPurchase = "${_formatInt(data['totalPurchase'])} 원";
        totalEvaluation = "${_formatInt(data['totalEvaluation'])} 원";
        totalProfit = "${_formatInt(data['totalProfit'])} 원";
        totalProfitRate = _formatProfitRate(data['totalProfitRate']); // 수익률만 다르게 처리
        errorMessage = '';
      });
    } catch (error) {
      setState(() {
        errorMessage = '데이터를 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  String _formatInt(dynamic value) {
    if (value is double) {
      return value.toInt().toString(); 
    } else if (value is int) {
      return value.toString();
    }
    return "0"; 
  }

  // 수익률을 double 형으로 처리하는 메소드
  String _formatProfitRate(dynamic value) {
    if (value is double) {
      return "${value.toStringAsFixed(2)} %"; // 소수점 2자리까지 출력
    } else if (value is int) {
      return "$value %";
    }
    return "0 %";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Table(
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: [
              _buildTableRow("총매입", totalPurchase),
              _buildTableRow("총평가", totalEvaluation),
              _buildTableRow("총손익", totalProfit),
              _buildTableRow("수익률", totalProfitRate),
            ],
          ),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
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
