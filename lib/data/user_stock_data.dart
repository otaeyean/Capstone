import 'dart:convert';
import 'package:flutter/services.dart';

class UserStockData {
  String name;
  String ticker;
  double price;
  int quantity; 
  double totalValue;
  double risePercent;  // ?�승�?
  double fallPercent;  // ?�락�?
  double profitRate;   // ?�익 �?(�??��? ?��??�익�?

  UserStockData({
    required this.name,
    required this.ticker,
    required this.price,
    required this.quantity,
    required this.risePercent,
    required this.fallPercent,
  })  : totalValue = price * quantity,
        profitRate = (risePercent > 0 ? risePercent : -fallPercent); // ?�승률이 ?�으�??�수, ?�락률이 ?�으�??�수

  // JSON ?�이?��? 객체�?변?�하???�토�??�성??
  factory UserStockData.fromJson(Map<String, dynamic> json) {
    return UserStockData(
      name: json['name'],
      ticker: json['ticker'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      risePercent: (json['rise_percent'] ?? 0.0).toDouble(),
      fallPercent: (json['fall_percent'] ?? 0.0).toDouble(),
    );
  }
}

// JSON ?�이?��? 로드?�는 ?�수
Future<List<UserStockData>> loadUserStockData() async {
  // JSON ?�일 ?�기
  String jsonString = await rootBundle.loadString('assets/user_stock_data.json');
  final data = jsonDecode(jsonString);

  // JSON ?�이?��? UserStockData 객체 리스?�로 변??
  List<UserStockData> userStocks = (data['stocks'] as List)
      .map((stockJson) => UserStockData.fromJson(stockJson))
      .toList();

  return userStocks;
}

