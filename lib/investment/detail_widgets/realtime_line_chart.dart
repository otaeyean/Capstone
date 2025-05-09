import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RealTimeLineChart extends StatelessWidget {
  final List<double> prices;
  const RealTimeLineChart({super.key, required this.prices});

  @override
  Widget build(BuildContext context) {
    if (prices.length < 2) {
      return Center(
        child: Text(
          "실시간 데이터를 기다리는 중...",
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      );
    }

    // 가격 범위 처리
    double min = prices.reduce((a, b) => a < b ? a : b);
    double max = prices.reduce((a, b) => a > b ? a : b);
    double diff = max - min;
    double minRange = 100;
    double range = diff < minRange ? minRange : diff;
    double buffer = range * 0.15;

    // 고정 색상
    final Color mainLineColor = Color(0xFF4FC3F7);
    final Color shadowColor = Color(0xFF81D4FA);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1, bottom:1),
          child: Center(
            child: Text(
              "📈 실시간 체결가: ${prices.last.toStringAsFixed(0)}원",
              style: TextStyle(
                fontSize: 22, // ✅ 폰트 더 키움
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1B2A), // ✅ 딥 네이비
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Color(0xFF141E30), Color(0xFF243B55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: LineChart(
              LineChartData(
                minY: min - buffer,
                maxY: max + buffer,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: range / 4,
                      getTitlesWidget: (value, _) => Text(
                        value.toStringAsFixed(0),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0.5, 0.5),
                              blurRadius: 3,
                              color: Colors.black45,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: TextStyle(color: Colors.white38, fontSize: 9),
                      ),
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: range / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white10,
                    strokeWidth: 0.5,
                  ),
                  getDrawingVerticalLine: (_) => FlLine(
                    color: Colors.white10,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      prices.length,
                      (i) => FlSpot(i.toDouble(), prices[i]),
                    ),
                    isCurved: true,
                    barWidth: 2.5,
                    gradient: LinearGradient(
                      colors: [mainLineColor, mainLineColor.withOpacity(0.8)],
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          shadowColor.withOpacity(0.25),
                          Colors.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
