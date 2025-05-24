// apicall.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:intl/intl.dart';

class StockInfoDTO {
  final String stockCode;
  final String pdpr, oppr, hypr, lopr, tvol, tamt, tomv, h52p, l52p, per, pbr, eps, bps;

  StockInfoDTO({
    required this.stockCode,
    required this.pdpr,
    required this.oppr,
    required this.hypr,
    required this.lopr,
    required this.tvol,
    required this.tamt,
    required this.tomv,
    required this.h52p,
    required this.l52p,
    required this.per,
    required this.pbr,
    required this.eps,
    required this.bps,
  });

  factory StockInfoDTO.fromJson(Map<String, dynamic> json) {
    return StockInfoDTO(
      stockCode: json['stockCode'],
      pdpr: json['pdpr'],
      oppr: json['oppr'],
      hypr: json['hypr'],
      lopr: json['lopr'],
      tvol: json['tvol'],
      tamt: json['tamt'],
      tomv: json['tomv'],
      h52p: json['h52p'],
      l52p: json['l52p'],
      per: json['per'],
      pbr: json['pbr'],
      eps: json['eps'],
      bps: json['bps'],
    );
  }
}

class StockPrice {
  final String date;
  final double openPrice, highPrice, lowPrice, closePrice;
  final int volume;

  StockPrice({
    required this.date,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.volume,
  });

  factory StockPrice.fromJson(Map<String, dynamic> json) {
    return StockPrice(
      date: json['date'],
      openPrice: json['openPrice'].toDouble(),
      highPrice: json['highPrice'].toDouble(),
      lowPrice: json['lowPrice'].toDouble(),
      closePrice: json['closePrice'].toDouble(),
      volume: json['volume'],
    );
  }
}

Future<Map<String, dynamic>?> fetchStockData(String stockCode) async {
  try {
    stockCode = stockCode.trim();

    final infoUrl = Uri.parse("http://withyou.me:8080/stock-info/$stockCode");
    final chartUrl = Uri.parse("http://withyou.me:8080/prices/$stockCode?period=D");

    final responses = await Future.wait([
      http.get(infoUrl),
      http.get(chartUrl),
    ]);

    if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
      final info = StockInfoDTO.fromJson(json.decode(responses[0].body));
      final List<StockPrice> prices = (json.decode(responses[1].body) as List)
          .map((e) => StockPrice.fromJson(e))
          .toList();
      return {'info': info, 'prices': prices};
    }
  } catch (e) {
    print("API 요청 실패: $e");
  }
  return null;
}

class StockLineChart extends StatelessWidget {
  final List<StockPrice> prices;
  const StockLineChart({super.key, required this.prices});

  @override
  Widget build(BuildContext context) {
    if (prices.length < 2) return const SizedBox();

    // 정렬 보장: 날짜 기준 오름차순 정렬
    final sortedPrices = List<StockPrice>.from(prices)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedPrices
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.closePrice))
        .toList();

    final minY = sortedPrices.map((p) => p.lowPrice).reduce(min);
    final maxY = sortedPrices.map((p) => p.highPrice).reduce(max);
    final dateLabels = sortedPrices.map((e) {
      final dt = DateTime.parse(e.date);
      return "${dt.month}/${dt.day}";
    }).toList();

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(right: 18, top: 8, bottom: 4, left: 28),
        child: LineChart(
          LineChartData(
            minY: (minY * 0.98),
            maxY: (maxY * 1.02),
            clipData: FlClipData.all(),
            lineTouchData: LineTouchData(enabled: false),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // 위 숫자 제거
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: _calcYInterval(minY, maxY),
                    getTitlesWidget: (value, meta) {
                      final range = meta.max - meta.min;
                      final shouldHideExtremes = range > 10;

                      if (shouldHideExtremes &&
                          (isRoughlyEqual(value, meta.min) || isRoughlyEqual(value, meta.max))) {
                        return const SizedBox();
                      }

                      return Text(
                        formatYAxisValue(value),
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: max((sortedPrices.length / 8).floorToDouble(), 1),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();

                    // 범위 초과 보호
                    if (index < 0 || index >= dateLabels.length) return const SizedBox();

                    // 시작과 끝은 생략 (ex: index == 0 또는 마지막 index)
                    if (index == 0 || index == dateLabels.length - 1) {
                      return const SizedBox();
                    }

                    return Text(
                      dateLabels[index],
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false, // 세로선 안 보이게
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(1.0), // 얇은 회색 선
                strokeWidth: 0.5,
                dashArray: [4, 2], // 점선으로 하려면 사용, 실선이면 제거 가능
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                preventCurveOverShooting: true,
                belowBarData: BarAreaData(show: false),
                dotData: FlDotData(show: false),
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calcYInterval(double minY, double maxY) {
    final range = maxY - minY;

    if (range < 5) {
      // 달러 같은 소수 데이터일 경우: 0.5 단위로
      return 0.5;
    } else if (range < 1000) {
      return (range / 4).ceilToDouble();
    } else {
      return (range / 5).ceilToDouble().clamp(100, 1000000);
    }
  }

  String formatYAxisValue(double value) {
    if (value < 1000) {
      return value.toStringAsFixed(2);
    } else {
      return value.round().toString();
    }
  }

  bool isRoughlyEqual(double a, double b, [double epsilon = 1e-2]) {
    return (a - b).abs() < epsilon;
  }
}

class StockInfoCard extends StatelessWidget {
  final StockInfoDTO stock;
  final String stockName;

  const StockInfoCard({
    super.key,
    required this.stock,
    required this.stockName,
  });

  String formatNumber(String raw, {int unitDivisor = 1, String? suffix, bool decimal = false}) {
    final number = double.tryParse(raw.replaceAll(',', '')) ?? 0;
    final divided = number / unitDivisor;
    final formatted = decimal
        ? divided.toStringAsFixed(1)
        : NumberFormat.decimalPattern().format(divided.floor());
    return "$formatted${suffix ?? ''}";
  }

  String formatToChoOk(String raw) {
    final totalEok = int.tryParse(raw.replaceAll(',', '')) ?? 0;
    final cho = totalEok ~/ 10000;
    final ok = totalEok % 10000;
    if (cho > 0) {
      return '${NumberFormat.decimalPattern().format(cho)}조 ${NumberFormat.decimalPattern().format(ok)}억';
    } else {
      return '${NumberFormat.decimalPattern().format(ok)}억';
    }
  }

  Text _labelValue(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.black54),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "📈 $stockName",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          _infoRow("전일가", stock.pdpr, "시가", stock.oppr),
          _infoRow("고가", stock.hypr, "저가", stock.lopr),
          _infoRow("거래량", formatNumber(stock.tvol), "거래대금", formatNumber(stock.tamt, unitDivisor: 1000000, suffix: " 백만")),
          _infoRow("시가총액", stock.tomv, "", ""),
          _infoRow("52주 최고", stock.h52p, "52주 최저", stock.l52p),
          _infoRow("PER", formatNumber(stock.per, decimal: true), "PBR", formatNumber(stock.pbr, decimal: true)),
          _infoRow("EPS", formatNumber(stock.eps, decimal: true), "BPS", formatNumber(stock.bps, decimal: true)),
        ],
      ),
    );
  }

  Widget _infoRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _labelValue(label1, value1)),
          if (label2.isNotEmpty)
            Expanded(child: _labelValue(label2, value2)),
        ],
      ),
    );
  }
}
