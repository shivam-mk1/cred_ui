import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Immutable 2D/3D transformation state for animating cards in the deck stack.
@immutable
class CardPose {
  const CardPose({
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
  });

  /// Translation offset applied to the card.
  final Offset offset;

  /// Scale multiplier applied to the card.
  final double scale;

  /// Rotation angle in radians applied along the z-axis.
  final double rotation;

  /// Visual opacity of the card face.
  final double opacity;

  /// Default pose with zero transformation and full opacity.
  static const identity = CardPose();

  @override
  String toString() =>
      'CardPose(offset: $offset, scale: $scale, rot: $rotation, opacity: $opacity)';
}
