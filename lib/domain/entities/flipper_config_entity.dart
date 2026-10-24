import 'package:equatable/equatable.dart';
import 'cta_entity.dart';

/// Configuration for individual slides within an offer flipper widget.
class FlipperConfigEntity extends Equatable {
  const FlipperConfigEntity({
    this.text1,
    this.cta,
    this.shouldShowTimer = false,
  });

  final String? text1; 
  final CtaEntity? cta;
  final bool shouldShowTimer;

  static FlipperConfigEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const FlipperConfigEntity();
    return FlipperConfigEntity(
      text1: map['text_1'] as String?,
      cta: CtaEntity.fromMap(map['cta'] as Map<String, dynamic>?),
      shouldShowTimer: (map['should_show_timer'] as bool?) ?? false,
    );
  }

  @override
  List<Object?> get props => [text1, cta, shouldShowTimer];
}
