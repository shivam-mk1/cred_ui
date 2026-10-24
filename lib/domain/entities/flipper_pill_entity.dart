import 'package:equatable/equatable.dart';
import 'cta_entity.dart';

/// Presentation pill badge displayed across the top face of a card.
class FlipperPillEntity extends Equatable {
  const FlipperPillEntity({
    required this.priority,
    required this.duration,
    this.type,
    this.cta1,
  });

  /// Sorting priority for resolving badge display order (lower values render first).
  final int priority;

  /// Display interval duration in milliseconds when cycling pills.
  final int duration;

  final String? type; // "pending_action"
  final CtaEntity? cta1;

  static FlipperPillEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const FlipperPillEntity(priority: 0, duration: 1000);
    }
    return FlipperPillEntity(
      priority: (map['priority'] as num?)?.toInt() ?? 0,
      duration: (map['duration'] as num?)?.toInt() ?? 1000,
      type: map['type'] as String?,
      cta1: CtaEntity.fromMap(map['cta_1'] as Map<String, dynamic>?),
    );
  }

  @override
  List<Object?> get props => [priority, duration, type, cta1];
}
