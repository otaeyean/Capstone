import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show Rect, rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/recognition.dart';
import '../utils/image_utils.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class Classifier {
  static const String modelPath = 'assets/detect.tflite';
  static const String labelPath = 'assets/labelmap.txt';

  static const double _confThreshold = 0.6;   // threshold
  static const double _nmsIouThreshold = 0.5;

  late Interpreter _interpreter;
  late List<String> _labels;
  DateTime _lastInferenceTime = DateTime.now();

  Classifier._();

  static Future<Classifier> load() async {
    final classifier = Classifier._();
    classifier._interpreter = await Interpreter.fromAsset(modelPath);
    classifier._labels = (await rootBundle.loadString(labelPath)).split('\n');
    return classifier;
  }

  Future<List<Recognition>> predict(CameraImage image) async {
    // 프레임 제한 (300ms)
    if (DateTime.now().difference(_lastInferenceTime).inMilliseconds < 300) {
      return [];
    }
    _lastInferenceTime = DateTime.now();

    return compute(_runModelInference, {
      'image': image,
      'labels': _labels,
      'interpreterAddress': _interpreter.address,
    });
  }

  // Isolate에서 실행되는 추론 함수
  static Future<List<Recognition>> _runModelInference(Map<String, dynamic> data) async {
    final image = data['image'] as CameraImage;
    final labels = data['labels'] as List<String>;
    final interpreter = Interpreter.fromAddress(data['interpreterAddress']);

    // 1) 전처리
    const int inputSize = 320;
    final converted = ImageUtils.convertCameraImageToRgb(image);
    final resized = ImageUtils.resizeWithPadding(converted, inputSize);
    final input = ImageUtils.imageToByteListFloat32(resized, inputSize);

    // 2) 출력 텐서 shape 동적 추출
    final outputTensors = interpreter.getOutputTensors();
    final shape = outputTensors.first.shape;      // e.g. [1, numBoxes, numClasses+5]
    final numBoxes = shape[1];

    // 3) 버퍼 생성
    final totalLen = shape.reduce((a, b) => a * b);
    final output = List<double>.filled(totalLen, 0.0).reshape(shape);

    // 4) 추론 실행
    interpreter.runForMultipleInputs([input], {0: output});

    // 5) 결과 파싱
    final results = <Recognition>[];
    for (var i = 0; i < numBoxes; i++) {
      final row = output[0][i];
      final objectness = row[4];
      final classScores = row.sublist(5);
      final maxClassScore = findMax(classScores);
      final confidence = objectness * maxClassScore;

      if (confidence > _confThreshold) {
        final classIndex = classScores.indexOf(maxClassScore);
        final x = row[0], y = row[1], w = row[2], h = row[3];
        results.add(Recognition(
          labels[classIndex].hashCode,
          labels[classIndex],
          confidence,
          // 224 기준 픽셀이 아니라 [0~1] 범위로
          Rect.fromLTWH(
            x - w / 2,
            y - h / 2,
            w,
            h,
          ),
        ));
      }
    }

    final nmsResults = applyNms(results, _nmsIouThreshold);
    final finalResults = uniqueByLabel(nmsResults);
    return finalResults;
  }
}

double findMax(List<double> values) {
  return values.reduce((a, b) => a > b ? a : b);
}

double _iou(Rect a, Rect b) {
  final x1 = max(a.left, b.left);
  final y1 = max(a.top, b.top);
  final x2 = min(a.right, b.right);
  final y2 = min(a.bottom, b.bottom);

  final interWidth  = max(0.0, x2 - x1);
  final interHeight = max(0.0, y2 - y1);
  final interArea   = interWidth * interHeight;

  final unionArea = a.width * a.height + b.width * b.height - interArea;
  return interArea / unionArea;
}

/// Non-Max Suppression
List<Recognition> applyNms(List<Recognition> list, double iouThreshold) {
  // 점수 높은 순으로 정렬
  list.sort((a, b) => b.score.compareTo(a.score));

  final kept = <Recognition>[];
  for (var r in list) {
    // 기존에 남긴 박스들과 IoU가 모두 기준 미만일 때만 추가
    final shouldKeep = kept.every((k) => _iou(k.rect, r.rect) < iouThreshold);
    if (shouldKeep) kept.add(r);
  }
  return kept;
}

/// 레이블별 최고 점수만 남기는 필터
List<Recognition> uniqueByLabel(List<Recognition> list) {
  final Map<String, Recognition> bestMap = {};
  for (var r in list) {
    final label = r.label;
    if (!bestMap.containsKey(label) || r.score > bestMap[label]!.score) {
      bestMap[label] = r;
    }
  }
  return bestMap.values.toList();
}
