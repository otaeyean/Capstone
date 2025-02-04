import 'dart:convert';
import 'package:flutter/services.dart';

class UserStockData {
  String name;
  String ticker;
  double price;
  int quantity;
  double totalValue;

  UserStockData({
    required this.name,
    required this.ticker,
    required this.price,
    required this.quantity,
  }) : totalValue = price * quantity;

  // JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory UserStockData.fromJson(Map<String, dynamic> json) {
    return UserStockData(
      name: json['name'],
      ticker: json['ticker'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
    );
  }
}

Future<List<UserStockData>> loadUserStockData() async {
  // JSON 파일 읽기
  String jsonString = await rootBundle.loadString('assets/user_stock_data.json');
  final data = jsonDecode(jsonString);

  // JSON 데이터를 UserStockData 객체 리스트로 변환
  List<UserStockData> userStocks = (data['stocks'] as List)
      .map((stockJson) => UserStockData.fromJson(stockJson))
      .toList();

  return userStocks;
}
