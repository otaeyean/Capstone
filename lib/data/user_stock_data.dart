import 'dart:convert';
import 'package:flutter/services.dart';

class UserStockData {
  String name;
  String ticker;
  double price;
  int quantity; 
  double totalValue;
  double risePercent;  // ?ìŠ¹ë¥?
  double fallPercent;  // ?˜ë½ë¥?
  double profitRate;   // ?˜ìµ ë¥?(ì´??‰ê? ?€ë¹??˜ìµë¥?

  UserStockData({
    required this.name,
    required this.ticker,
    required this.price,
    required this.quantity,
    required this.risePercent,
    required this.fallPercent,
  })  : totalValue = price * quantity,
        profitRate = (risePercent > 0 ? risePercent : -fallPercent); // ?ìŠ¹ë¥ ì´ ?ˆìœ¼ë©??‘ìˆ˜, ?˜ë½ë¥ ì´ ?ˆìœ¼ë©??Œìˆ˜

  // JSON ?°ì´?°ë? ê°ì²´ë¡?ë³€?˜í•˜???©í† ë¦??ì„±??
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

// JSON ?°ì´?°ë? ë¡œë“œ?˜ëŠ” ?¨ìˆ˜
Future<List<UserStockData>> loadUserStockData() async {
  // JSON ?Œì¼ ?½ê¸°
  String jsonString = await rootBundle.loadString('assets/user_stock_data.json');
  final data = jsonDecode(jsonString);

  // JSON ?°ì´?°ë? UserStockData ê°ì²´ ë¦¬ìŠ¤?¸ë¡œ ë³€??
  List<UserStockData> userStocks = (data['stocks'] as List)
      .map((stockJson) => UserStockData.fromJson(stockJson))
      .toList();

  return userStocks;
}

