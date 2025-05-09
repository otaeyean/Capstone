import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stockapp/investment/detail_widgets/realtime_line_chart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class RealTimePriceChart extends StatefulWidget {
  final String stockCode;
  RealTimePriceChart({required this.stockCode});

  @override
  _RealTimePriceChartState createState() => _RealTimePriceChartState();
}

class _RealTimePriceChartState extends State<RealTimePriceChart> {
  late IOWebSocketChannel channel;
  List<double> prices = [];

  @override
  void initState() {
    super.initState();
    print("📡 WebSocket 연결 시작: ${widget.stockCode}");

    channel = IOWebSocketChannel.connect('ws://withyou.me:8080/ws-client');

    final subscribeMessage = jsonEncode({
      "action": "subscribe",
      "stockCode": widget.stockCode,
    });
    print("📨 구독 요청 보냄: $subscribeMessage");
    channel.sink.add(subscribeMessage);

    channel.stream.listen((message) {
      print("💬 수신된 메시지: $message");

      try {
        final data = jsonDecode(message);
        if (data['stockCode'] == widget.stockCode) {
          double? price = double.tryParse(data['currentPrice'].toString());
          if (price != null) {
            setState(() {
              prices.add(price);
              if (prices.length > 20) prices.removeAt(0);
            });
          }
        }
      } catch (e) {
        print("❌ 메시지 파싱 오류: $e");
      }
    }, onError: (error) {
      print("❗ WebSocket 에러: $error");
    }, onDone: () {
      print("🔌 WebSocket 연결 종료");
    });
  }

  @override
  void dispose() {
    final unsubscribeMessage = jsonEncode({
      "action": "unsubscribe",
      "stockCode": widget.stockCode,
    });
    channel.sink.add(unsubscribeMessage);
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double chartHeight = constraints.maxHeight * 0.8; // ✅ 30% 비율

        return Center(
          child: SizedBox(
            height: chartHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: prices.length < 2
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "실시간 데이터를 기다리는 중...",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    )
                  : RealTimeLineChart(prices: prices),
            ),
          ),
        );
      },
    );
  }
}
