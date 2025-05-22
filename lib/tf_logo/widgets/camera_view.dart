import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/TimedRecognition.dart';
import '../services/classifier.dart';
import '../models/recognition.dart';
import './apicall.dart';

class CameraView extends StatefulWidget {
  final Function(List<Recognition>) resultsCallback;
  final Function(int) updateElapsedTimeCallback;

  final Function(String)? onNewStockDetected;

  const CameraView({
    super.key,
    required this.resultsCallback,
    required this.updateElapsedTimeCallback,
    this.onNewStockDetected,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static const double inThreshold = 0.2;
  static const double outThreshold = 0.1;
  static const int removalDelayMs = 2400;

  CameraController? _cameraController;
  late Classifier _classifier;
  bool _isDetecting = false;
  bool _isClassifierReady = false;
  List<TimedRecognition> _activeRecognitions = [];
  Map<String, Map<String, dynamic>> _stockCache = {};
  String? _lastRequestedLabel;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_processCameraImage);

    _classifier = await Classifier.load();
    _isClassifierReady = true;
    setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    if (!_isClassifierReady || _isDetecting) return;
    _isDetecting = true;

    final results = await _classifier.predict(image);
    final now = DateTime.now();

    // 결과 업데이트
    for (var result in results) {
      if (result.score < inThreshold) continue;
      final existing = _activeRecognitions.firstWhere(
            (r) => r.recognition.id == result.id,
        orElse: () => TimedRecognition(result, now),
      );
      if (result.score > outThreshold) {
        existing.lastSeen = now;
      }
      existing.recognition = result;
      if (!_activeRecognitions.contains(existing)) {
        _activeRecognitions.add(existing);
      }
    }

    if (_activeRecognitions.isNotEmpty) {
      final label = _activeRecognitions.first.recognition.label;

      // ✅ 외부에 주식 이름 알림
      if (widget.onNewStockDetected != null) {
        widget.onNewStockDetected!(label);
      }

      if (!_stockCache.containsKey(label) && label != _lastRequestedLabel) {
        _lastRequestedLabel = label;
        final data = await fetchStockData(label);
        if (data != null && data.containsKey('info') && data.containsKey('prices')) {
          setState(() {
            _stockCache[label] = data;
          });
        }
      }
    }

    _activeRecognitions.removeWhere(
          (r) => now.difference(r.lastSeen).inMilliseconds > removalDelayMs,
    );

    setState(() {});
    _isDetecting = false;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = _cameraController!.value.previewSize!;
        final screenRatio = constraints.maxWidth / constraints.maxHeight;
        final previewRatio = previewSize.height / previewSize.width;

        return Stack(
          children: [
            ClipRect(
              child: OverflowBox(
                alignment: Alignment.center,
                maxHeight: screenRatio > previewRatio
                    ? constraints.maxWidth / previewRatio
                    : constraints.maxHeight,
                maxWidth: screenRatio > previewRatio
                    ? constraints.maxWidth
                    : constraints.maxHeight * previewRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),
            if (_activeRecognitions.isNotEmpty)
              ..._buildOverlayWidgets(), // ✅ 여기에 있어야 표시됨
          ],
        );
      },
    );
  }

  List<Widget> _buildOverlayWidgets() {
    final label = _activeRecognitions.first.recognition.label;
    final stockData = _stockCache[label];

    if (stockData == null || stockData['info'] == null || stockData['prices'] == null) {
      return [];
    }

    return [
      Positioned(
        top: 20,
        left: 0,
        right: 0,
        child: Center(
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: StockInfoCard(stock: stockData['info']),
            ),
          ),
        ),
      ),
      Positioned(
        left: 10,
        right: 10,
        bottom: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: StockLineChart(prices: stockData['prices']),
        ),
      )
    ];
  }
}
