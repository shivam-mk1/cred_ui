import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class CardPose {
  const CardPose({
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
  });

  final Offset offset;
  final double scale;
  final double rotation;
  final double opacity;

  static const identity = CardPose();

  @override
  String toString() =>
      'CardPose(offset: $offset, scale: $scale, rot: $rotation, opacity: $opacity)';
}
