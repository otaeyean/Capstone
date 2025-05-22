import 'dart:ui';

class Recognition {
  final int id;
  final String label;
  final double score;
  final Rect rect;

  Recognition(this.id, this.label, this.score, this.rect);
}