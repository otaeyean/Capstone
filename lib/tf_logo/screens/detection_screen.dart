import 'package:flutter/material.dart';
import '../widgets/camera_view.dart';
import '../models/recognition.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({Key? key}) : super(key: key);

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final List<String> detectedStocks = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _firstButtonKey = GlobalKey();
  double _firstButtonWidth = 87; // 초기값 (fallback)

  void _handleNewStock(String label) {
    setState(() {
      detectedStocks.remove(label);
      detectedStocks.insert(0, label); // 최신 항목 맨 앞
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
    return Scaffold(
      backgroundColor: Colors.green[120],
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // 카메라: 화면 상단 영역만 차지하게
            Expanded(
              child: CameraView(
                resultsCallback: (List<Recognition> results) {},
                updateElapsedTimeCallback: (int elapsed) {},
                onNewStockDetected: _handleNewStock,
              ),
            ),

            // 버튼 영역: 하단에 고정된 높이
            Container(
              color: Colors.green[120],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "인식한 주식 목록",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 6),

                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: detectedStocks.length,
                      itemBuilder: (context, index) {
                        final stock = detectedStocks[index];

                        final isFirst = index == 0;
                        final paddingLeft = isFirst
                            ? MediaQuery.of(context).size.width / 2 - _firstButtonWidth / 2 - 10 // ← 보정값 추가
                            : 6.0;

                        return Padding(
                          padding: EdgeInsets.only(left: paddingLeft, right: 6),
                          child: ElevatedButton(
                            key: isFirst ? _firstButtonKey : null, // ✅ key 부여
                            onPressed: () {
                              print('Navigate to detail page for $stock');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              minimumSize: const Size(0, 48), // ← 높이만 높임
                            ),
                            child: Text(stock),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
