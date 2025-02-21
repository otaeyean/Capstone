import 'dart:convert';
import 'package:http/http.dart' as http;
import 'stock_price.dart';

class ChartService {
  static const String baseUrl = "http://withyou.me:8080";

  Future<List<StockPrice>> fetchChartData(String stockCode, {String period = "D"}) async {
    final url = Uri.parse("$baseUrl/prices/$stockCode?period=$period"); // ✅ URL 수정
    print("Fetching data from: $url");  // ✅ 요청 URL 확인용 로그 추가

    try {
      final response = await http.get(url);
      print("Response status: ${response.statusCode}");  // ✅ 응답 코드 출력
      print("Response body: ${response.body}");  // ✅ 응답 내용 출력

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((data) => StockPrice.fromJson(data)).toList();
      } else {
        throw Exception("Failed to load stock prices: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching stock data: $e");  // ✅ 에러 출력
      throw Exception("Error fetching stock data: $e");
    }
  }
}
