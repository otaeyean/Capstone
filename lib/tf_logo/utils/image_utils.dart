import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;


class ImageUtils {
  // 카메라 이미지 → 흑백 img.Image로 변환 (Y 채널만 사용)
  static img.Image convertCameraImageToRgb(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final img.Image rgbImage = img.Image(width: width, height: height);

    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final int indexY = y * image.planes[0].bytesPerRow + x;

        final int yValue = image.planes[0].bytes[indexY];
        final int uValue = image.planes[1].bytes[uvIndex];
        final int vValue = image.planes[2].bytes[uvIndex];

        final int r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
        final int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).round().clamp(0, 255);
        final int b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);

        rgbImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return rgbImage;
  }


  static Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var bytes = Uint8List(1 * inputSize * inputSize * 3);
    int pixelIndex = 0;

    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y); // type: Pixel
        bytes[pixelIndex++] = pixel.r.toInt();
        bytes[pixelIndex++] = pixel.g.toInt();
        bytes[pixelIndex++] = pixel.b.toInt();
      }
    }

    return bytes;
  }

  static List<List<List<List<double>>>> imageToByteListFloat32(img.Image image, int inputSize) {
    return List.generate(1, (_) =>
        List.generate(inputSize, (y) =>
            List.generate(inputSize, (x) {
              final pixel = image.getPixel(x, y);
              final r = pixel.r.toDouble() / 255.0;
              final g = pixel.g.toDouble() / 255.0;
              final b = pixel.b.toDouble() / 255.0;
              return [r, g, b]; // NHWC: height, width, channel
            })
        )
    );
  }

  static img.Image resizeWithPadding(img.Image src, int targetSize) {
    final srcW = src.width;
    final srcH = src.height;
    final srcRatio = srcW / srcH;
    final targetRatio = 1.0;

    int newW, newH;
    if (srcRatio > targetRatio) {
      newW = targetSize;
      newH = (targetSize / srcRatio).round();
    } else {
      newH = targetSize;
      newW = (targetSize * srcRatio).round();
    }

    final resized = img.copyResize(src, width: newW, height: newH);

    // ColorRgb8로 배경색 지정
    final padded = img.Image(width: targetSize, height: targetSize);
    img.fill(padded, color: img.ColorRgb8(0, 0, 0)); // 검정색

    // 중앙에 복사
    final xOffset = ((targetSize - newW) / 2).round();
    final yOffset = ((targetSize - newH) / 2).round();
    copyInto(padded, resized, dstX: xOffset, dstY: yOffset);

    return padded;
  }

  static void copyInto(img.Image dst, img.Image src, {int dstX = 0, int dstY = 0}) {
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final dx = dstX + x;
        final dy = dstY + y;
        if (dx >= 0 && dx < dst.width && dy >= 0 && dy < dst.height) {
          dst.setPixel(dx, dy, pixel);
        }
      }
    }
  }
}