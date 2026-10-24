import 'package:equatable/equatable.dart';
import 'cta_entity.dart';

/// Domain entity representing top app bar actions and navigation icons.
class TopBarEntity extends Equatable {
  const TopBarEntity({this.cta1, this.cta2, this.cta3});

  /// Center: amount/wallet display
  final CtaEntity? cta1;

  /// Left icon
  final CtaEntity? cta2;

  /// Right icon/settings
  final CtaEntity? cta3;

  static TopBarEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const TopBarEntity();
    return TopBarEntity(
      cta1: CtaEntity.fromMap(map['cta_1'] as Map<String, dynamic>?),
      cta2: CtaEntity.fromMap(map['cta_2'] as Map<String, dynamic>?),
      cta3: CtaEntity.fromMap(map['cta_3'] as Map<String, dynamic>?),
    );
  }

  @override
  List<Object?> get props => [cta1, cta2, cta3];
}
