import 'package:flutter/material.dart';
import 'package:stockapp/investment/chart/stock_price.dart';
import 'package:stockapp/investment/chart/stock_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'moving_average_calculator.dart';
import 'package:intl/intl.dart';
import 'stock_chart_controls.dart';

class StockChartView extends StatefulWidget {
  final StockProvider stockProvider;

  const StockChartView({Key? key, required this.stockProvider}) : super(key: key);

  @override
  _StockChartViewState createState() => _StockChartViewState();
}

class _StockChartViewState extends State<StockChartView> {
  double _zoomLevel = 1.0;
  final ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
    enablePinching: true,
    enablePanning: true,
    zoomMode: ZoomMode.x,
  );

  void _updateZoom(bool zoomIn) {
    setState(() {
      if (zoomIn) {
        _zoomLevel = (_zoomLevel * 1.2).clamp(1.0, 3.0);
      } else {
        _zoomLevel = (_zoomLevel / 1.2).clamp(1.0, 3.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double chartWidth = constraints.maxWidth * _zoomLevel;
        double chartHeight = 260 * _zoomLevel;

        List<StockPrice> filteredData =
            widget.stockProvider.stockPrices.where((stock) => stock.volume > 0).toList();

        filteredData = filteredData.reversed.toList();

        double maxPrice = filteredData.map((s) => s.high).reduce((a, b) => a > b ? a : b);
        double maxVolume = filteredData.map((s) => s.volume.toDouble()).reduce((a, b) => a > b ? a : b);

        bool isMinuteChart = widget.stockProvider.selectedPeriod == "1m";
        String dateFormatPattern = isMinuteChart ? 'HH:mm' : (widget.stockProvider.selectedPeriod == "M" ? 'yyyy-MM' : 'MM-dd');

        List<String> tradingDays = filteredData.map((stock) {
          return DateFormat(dateFormatPattern).format(stock.date);
        }).toList();

        List<StockPrice> ma5 = calculateMovingAverage(filteredData, 5);
        List<StockPrice> ma10 = calculateMovingAverage(filteredData, 10);
        List<StockPrice> ma30 = calculateMovingAverage(filteredData, 30);

        return Column(
          children: [
            StockChartControls(
              selectedPeriod: widget.stockProvider.selectedPeriod,
              onPeriodSelected: (period) {
                widget.stockProvider.loadStockData("005930", period: period);
              },
              onZoom: _updateZoom,
            ),
            Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      SizedBox(
                        width: chartWidth,
                        height: chartHeight,
                        child: SfCartesianChart(
                          zoomPanBehavior: _zoomPanBehavior,
                          margin: EdgeInsets.zero,
                          plotAreaBorderWidth: 0,
                          primaryXAxis: isMinuteChart
                              ? DateTimeAxis(
                                  isVisible: false,
                                  dateFormat: DateFormat('HH:mm'),
                                  intervalType: DateTimeIntervalType.minutes,
                                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                                )
                              : CategoryAxis(
                                  isVisible: false,
                                  labelPlacement: LabelPlacement.onTicks,
                                ),
                          primaryYAxis: NumericAxis(
                            opposedPosition: true,
                            minimum: 0,
                            maximum: maxPrice * 1.2,
                            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
                          ),
                          series: <CartesianSeries>[
                            CandleSeries<StockPrice, dynamic>(
                              dataSource: filteredData,
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              lowValueMapper: (StockPrice stock, _) => stock.low,
                              highValueMapper: (StockPrice stock, _) => stock.high,
                              openValueMapper: (StockPrice stock, _) => stock.open,
                              closeValueMapper: (StockPrice stock, _) => stock.close,
                              bearColor: Colors.blue.withOpacity(0.8),
                              bullColor: Colors.red.withOpacity(0.8),
                            ),
                            LineSeries<StockPrice, dynamic>(
                              dataSource: ma5,
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              yValueMapper: (StockPrice stock, _) => stock.close,
                              color: Colors.yellow,
                              width: 1.5,
                            ),
                            LineSeries<StockPrice, dynamic>(
                              dataSource: ma10,
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              yValueMapper: (StockPrice stock, _) => stock.close,
                              color: Colors.purple,
                              width: 1.5,
                            ),
                            LineSeries<StockPrice, dynamic>(
                              dataSource: ma30,
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              yValueMapper: (StockPrice stock, _) => stock.close,
                              color: Colors.green,
                              width: 1.5,
                            ),
                          ],
                        ),
                      ),

                      // ✅ 거래량 차트 추가
                      SizedBox(
                        width: chartWidth,
                        height: 100 * _zoomLevel,
                        child: SfCartesianChart(
                          margin: EdgeInsets.zero,
                          plotAreaBorderWidth: 0,
                          primaryXAxis: CategoryAxis(
                            labelPlacement: LabelPlacement.onTicks,
                          ),
                          primaryYAxis: NumericAxis(
                            opposedPosition: true,
                            minimum: 0,
                            maximum: maxVolume * 1.2,
                            axisLine: const AxisLine(width: 0),
                            majorTickLines: const MajorTickLines(size: 0),
                            majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
                            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          series: <CartesianSeries>[
                            ColumnSeries<StockPrice, dynamic>(
                              dataSource: filteredData,
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              yValueMapper: (StockPrice stock, _) => stock.volume.toDouble(),
                              pointColorMapper: (StockPrice stock, _) =>
                                  stock.close > stock.open ? Colors.red : Colors.blue,
                              width: 0.6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ 이동평균선 범례 (왼쪽 상단으로 이동)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [Container(width: 8, height: 8, color: Colors.yellow), SizedBox(width: 4), Text("5", style: TextStyle(fontSize: 10))]),
                        Row(children: [Container(width: 8, height: 8, color: Colors.purple), SizedBox(width: 4), Text("10", style: TextStyle(fontSize: 10))]),
                        Row(children: [Container(width: 8, height: 8, color: Colors.green), SizedBox(width: 4), Text("30", style: TextStyle(fontSize: 10))]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
