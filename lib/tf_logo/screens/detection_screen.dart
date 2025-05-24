import 'package:flutter/material.dart';
import 'package:stockapp/investment/stock_detail_screen.dart';
import '../widgets/camera_view.dart';
import '../models/recognition.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({Key? key}) : super(key: key);

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final List<Map<String, String>> detectedStocks = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _firstButtonKey = GlobalKey();
  double _firstButtonWidth = 87;
// 주식목록
  final Map<String, String> _stockCodeToName = {
    '000660': 'SK하이닉스',
    '005380': '현대차',
    '005930': '삼성전자',
    '035420': 'NAVER',
    'AAPL': '애플',
    'AMZN': '아마존',
    'MSFT': '마이크로소프트',
    'NFLX': '넷플릭스',
    'NVDA': '엔비디아',
    'PEP': '펩시코',
    'TSLA': '테슬라',
  };

  String _getStockNameFromCode(String code) {
    return _stockCodeToName[code] ?? '이름 없음';
  }

  void _handleNewStock(String code) {
    final name = _getStockNameFromCode(code);
    setState(() {
      detectedStocks.removeWhere((stock) => stock['stockCode'] == code);
      detectedStocks.insert(0, {'stockCode': code, 'stockName': name});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_firstButtonKey.currentContext != null) {
        final box = _firstButtonKey.currentContext!.findRenderObject() as RenderBox;
        setState(() {
          _firstButtonWidth = box.size.width;
        });
      }

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color mainGreen = const Color(0xFF67CA98);
    final Color lightGreen = const Color(0xFFE4F5EC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  CameraView(
                    resultsCallback: (List<Recognition> results) {},
                    updateElapsedTimeCallback: (int elapsed) {},
                    onNewStockDetected: _handleNewStock,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: lightGreen,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "주식 상세페이지",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 46,
                    child: detectedStocks.isEmpty
                        ? Center(
                            child: Text(
                              "아직 인식된 주식이 없습니다",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: detectedStocks.length,
                            itemBuilder: (context, index) {
                              final stock = detectedStocks[index];
                              final isFirst = index == 0;
                              final paddingLeft = isFirst
                                  ? MediaQuery.of(context).size.width / 2 - _firstButtonWidth / 2 - 10
                                  : 8.0;

                              return Padding(
                                padding: EdgeInsets.only(left: paddingLeft, right: 8),
                                child: ElevatedButton(
                                  key: isFirst ? _firstButtonKey : null,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StockDetailScreen(stock: stock),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  child: Text(
                                    stock['stockName'] ?? '',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
