import 'package:flutter/material.dart';
import 'chart_server.dart';
import 'stock_price.dart';

class StockProvider with ChangeNotifier {
  final ChartService _chartService = ChartService();
  List<StockPrice> _stockPrices = [];
  bool _isLoading = false;
  String _errorMessage = "";  // ✅ 에러 메시지 추가

  List<StockPrice> get stockPrices => _stockPrices;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;  // ✅ Getter 추가

  Future<void> loadStockData(String stockCode, {String period = "D"}) async {
    _isLoading = true;
    _errorMessage = "";  // ✅ 기존 에러 초기화
    notifyListeners();

    try {
      _stockPrices = await _chartService.fetchChartData(stockCode, period: period);
    } catch (error) {
      print("Error fetching stock data: $error");
      _errorMessage = "주식 데이터를 불러오는 데 실패했습니다.";  // ✅ 에러 메시지 설정
    }

    _isLoading = false;
    notifyListeners();
  }
}
