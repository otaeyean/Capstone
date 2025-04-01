import 'package:flutter/material.dart';
import 'package:stockapp/investment/chart/stock_price.dart';
import 'package:stockapp/investment/chart/stock_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'moving_average_calculator.dart';
import 'package:intl/intl.dart';
import 'stock_chart_controls.dart';

class StockChartView extends StatefulWidget {
  final StockProvider stockProvider;
  final String stockCode;  // 종목 코드 추가

  const StockChartView({Key? key, required this.stockProvider, required this.stockCode}) : super(key: key);

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
  void initState() {
    super.initState();
    // 초기 차트 데이터 로드
    widget.stockProvider.loadStockData(widget.stockCode, period: widget.stockProvider.selectedPeriod);
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
        String dateFormatPattern = "MM-dd";  // 기본값
        if (isMinuteChart) {
          dateFormatPattern = 'HH:mm';  // ✅ 1분봉일 경우 "HH:mm" 형식 적용
        } else if (widget.stockProvider.selectedPeriod == "M") {
          dateFormatPattern = 'yyyy-MM';
        }

        List<String> tradingDays = filteredData.map((stock) {
          return DateFormat(dateFormatPattern).format(stock.date);
        }).toList();

        List<StockPrice> ma5 = calculateMovingAverage(filteredData, 5);
        List<StockPrice> ma10 = calculateMovingAverage(filteredData, 10);
        List<StockPrice> ma30 = calculateMovingAverage(filteredData, 30);

        return Column(
          children: [
            Container(
              height: 60, // 회색 배경 높이
              color: Colors.white, // ✅ 회색 배경 추가
              child: Center( // ✅ 버튼을 중앙에 배치
                child: StockChartControls(
                  selectedPeriod: widget.stockProvider.selectedPeriod,
                  onPeriodSelected: (period) {
                    // 사용자가 주기를 선택하면 해당 주식 데이터를 로드
                    widget.stockProvider.loadStockData(widget.stockCode, period: period);
                  },
                  onZoom: _updateZoom,
                ),
              ),
            ),
            Stack(
              children: [
                Container(height: 3, width: chartWidth, color: Colors.grey[300]),
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
                          primaryXAxis: CategoryAxis(
                            majorGridLines: MajorGridLines(
                              width: 1,
                              dashArray: [4, 4],
                              color: Colors.grey[300],
                            ),
                            majorTickLines: MajorTickLines(width: 0),
                            labelStyle: TextStyle(color: Colors.transparent),
                            axisLine: AxisLine(width: 0),
                          ),
                          primaryYAxis: NumericAxis(
                            opposedPosition: true,
                            minimum: isMinuteChart
                                ? filteredData.map((s) => s.low).reduce((a, b) => a < b ? a : b) * 0.98
                                : 0,
                            maximum: isMinuteChart
                                ? filteredData.map((s) => s.high).reduce((a, b) => a > b ? a : b) * 1.02
                                : maxPrice * 1.2,
                            majorGridLines: MajorGridLines(width: 0),
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
                              enableSolidCandles: true,
                            ),
                            LineSeries<StockPrice, dynamic>(
                              dataSource: ma5,
                              xValueMapper: (StockPrice stock, int index) =>
                                  isMinuteChart ? stock.date : tradingDays[index],
                              yValueMapper: (StockPrice stock, _) => stock.close,
                              color: Colors.yellow,
                              width: 1,
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


           // ✅ 거래량 차트 아래 여백을 회색으로 채우기 위해 Container 추가
Column(
  children: [
    // ✅ 거래량 차트
    SizedBox(
      width: chartWidth,
      height: 100 * _zoomLevel,
      child: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        primaryXAxis: isMinuteChart
            ? DateTimeAxis(
                dateFormat: DateFormat('HH:mm'),
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 1, color: Colors.grey[400]),
              )
            : CategoryAxis(
                majorGridLines: MajorGridLines(width: 0),
                majorTickLines: MajorTickLines(width: 0),
                labelStyle: TextStyle(fontSize: 10),
                axisLine: AxisLine(width: 1, color: Colors.grey[400]),
              ),
        primaryYAxis: NumericAxis(
          opposedPosition: true,
          minimum: 0,
          maximum: maxVolume * 1.2,
          axisLine: AxisLine(width: 0),
          majorTickLines: MajorTickLines(size: 0),
          majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey),
          labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
Container(height: 3, width: chartWidth, color: Colors.grey[300]),
    // ✅ 거래량 차트 아래에 회색 여백 추가
   SizedBox(
  height: MediaQuery.of(context).size.height * 0.1, // 화면 높이 20% 차지
  width: chartWidth,
  child: Container(
    color: Colors.white,  // ✅ 바닥 끝까지 흰색색 적용
  ),
),

  ],
),

            ],
          ),
        ),

        // ✅ 이동평균선 범례 (버튼 라인으로 이동)
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [Container(width: 8, height: 8, color: Colors.yellow), SizedBox(width: 4), Text("5", style: TextStyle(fontSize: 10))]),
                SizedBox(width: 10),
                Row(children: [Container(width: 8, height: 8, color: Colors.purple), SizedBox(width: 4), Text("10", style: TextStyle(fontSize: 10))]),
                SizedBox(width: 10),
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