import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/investment/chart/stock_price.dart';
import 'package:stockapp/investment/chart/stock_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'moving_average_calculator.dart';

class StockChartView extends StatelessWidget {
  final StockProvider stockProvider;

  const StockChartView({Key? key, required this.stockProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<StockPrice> filteredData =
        stockProvider.stockPrices.where((stock) => stock.volume > 0).toList();

    double maxPrice = filteredData.map((s) => s.high).reduce((a, b) => a > b ? a : b);
    double maxVolume = filteredData.map((s) => s.volume.toDouble()).reduce((a, b) => a > b ? a : b);

    // 이동평균선 데이터 생성
    List<StockPrice> movingAverage5Days = calculateMovingAverage(filteredData, 5);

    return Column(
      children: [
        // ✅ 시세 차트 (캔들 + 이동평균선)
        SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat('MM-dd'),
              intervalType: DateTimeIntervalType.days,
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              rangePadding: ChartRangePadding.none,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
              minorGridLines: const MinorGridLines(width: 1, color: Colors.grey),
            ),
            primaryYAxis: NumericAxis(
              opposedPosition: true,
              minimum: 0,
              maximum: maxPrice * 1.2,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
            ),
            series: <CartesianSeries>[
              CandleSeries<StockPrice, DateTime>(
                dataSource: filteredData,
                xValueMapper: (StockPrice stock, _) => stock.date,
                lowValueMapper: (StockPrice stock, _) => stock.low,
                highValueMapper: (StockPrice stock, _) => stock.high,
                openValueMapper: (StockPrice stock, _) => stock.open,
                closeValueMapper: (StockPrice stock, _) => stock.close,
                bearColor: Colors.blue.withOpacity(0.8),
                bullColor: Colors.red.withOpacity(0.8),
              ),
              LineSeries<StockPrice, DateTime>(
                dataSource: movingAverage5Days,
                xValueMapper: (StockPrice stock, _) => stock.date,
                yValueMapper: (StockPrice stock, _) => stock.close,
                color: Colors.yellow,
                width: 3,
                opacity: 0.9,
              ),
            ],
          ),
        ),

        // ✅ 거래량 차트 추가 (막대그래프)
        SizedBox(
          height: 150,
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat('MM-dd'),
              intervalType: DateTimeIntervalType.days,
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              rangePadding: ChartRangePadding.none,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
              minorGridLines: const MinorGridLines(width: 1, color: Colors.grey),
            ),
            primaryYAxis: NumericAxis(
              opposedPosition: true,
              minimum: 0,
              maximum: maxVolume * 1.2,
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
              labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              numberFormat: NumberFormat.compact(),
            ),
            series: <CartesianSeries>[
              ColumnSeries<StockPrice, DateTime>(
                dataSource: filteredData,
                xValueMapper: (StockPrice stock, _) => stock.date,
                yValueMapper: (StockPrice stock, _) => stock.volume.toDouble(),
                pointColorMapper: (StockPrice stock, _) =>
                    stock.close > stock.open ? Colors.red : Colors.blue,
                width: 0.6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
