import 'package:equatable/equatable.dart';
import 'cta_entity.dart';
import 'asset_entity.dart';
import 'statement_info_data.dart';

export 'statement_info_data.dart';

/// Domain model for statement summary details (total due amount and actions).
class StatementSummaryEntity extends Equatable {
  const StatementSummaryEntity({
    this.amount,
    this.text1,
    this.text2,
    this.text3,
    this.dueCount,
    this.cta1,
    this.cta2,
    this.asset4,
  });

  final double? amount;
  final String? text1; // e.g. "STATEMENT DUE FOR 1 CARD"
  final String? text2; // e.g. "₹50,000.00"
  final String? text3; // e.g. "TOTAL DUE"
  final int? dueCount;
  final CtaEntity? cta1; // flow
  final CtaEntity? cta2; // "Pay bill"
  final AssetEntity? asset4;

  static StatementSummaryEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StatementSummaryEntity();
    return StatementSummaryEntity(
      amount: (map['amount'] as num?)?.toDouble(),
      text1: map['text_1'] as String?,
      text2: map['text_2'] as String?,
      text3: map['text_3'] as String?,
      dueCount: (map['due_count'] as num?)?.toInt(),
      cta1: CtaEntity.fromMap(map['cta_1'] as Map<String, dynamic>?),
      cta2: CtaEntity.fromMap(map['cta_2'] as Map<String, dynamic>?),
      asset4: AssetEntity.fromMap(map['asset_4'] as Map<String, dynamic>?),
    );
  }

  @override
  List<Object?> get props =>
      [amount, text1, text2, text3, dueCount, cta1, cta2, asset4];
}

/// Domain model for unbilled card activity summaries.
class UnbilledSummaryEntity extends Equatable {
  const UnbilledSummaryEntity({
    this.amount,
    this.text1,
    this.text2,
    this.text3,
    this.cta2,
  });

  final double? amount;
  final String? text1; // "RECENT SPENDS"
  final String? text2; // "₹0.00"
  final String? text3; // "RECENT SPENDS"
  final CtaEntity? cta2; // "View transactions"

  static UnbilledSummaryEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UnbilledSummaryEntity();
    return UnbilledSummaryEntity(
      amount: (map['amount'] as num?)?.toDouble(),
      text1: map['text_1'] as String?,
      text2: map['text_2'] as String?,
      text3: map['text_3'] as String?,
      cta2: CtaEntity.fromMap(map['cta_2'] as Map<String, dynamic>?),
    );
  }

  @override
  List<Object?> get props => [amount, text1, text2, text3, cta2];
}

/// Domain model for `unbilled_statement_info_section_v2`.
///
/// Encapsulates celebratory background media along with both billed and unbilled summaries.
class StatementInfoEntity extends Equatable {
  const StatementInfoEntity({
    this.statement,
    this.unbilled,
    this.cta1,
    this.cta2,
    this.asset1,
  });

  final StatementSummaryEntity? statement;
  final UnbilledSummaryEntity? unbilled;

  final CtaEntity? cta1;

  final CtaEntity? cta2;

  final AssetEntity? asset1;

  StatementInfoData get data => StatementInfoData.fromEntity(this);

  static StatementInfoEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StatementInfoEntity();
    return StatementInfoEntity(
      statement: StatementSummaryEntity.fromMap(
          map['statement'] as Map<String, dynamic>?),
      unbilled: UnbilledSummaryEntity.fromMap(
          map['unbilled'] as Map<String, dynamic>?),
      cta1: CtaEntity.fromMap(map['cta_1'] as Map<String, dynamic>?),
      cta2: CtaEntity.fromMap(map['cta_2'] as Map<String, dynamic>?),
      asset1: AssetEntity.fromMap(map['asset_1'] as Map<String, dynamic>?),
    );
  }

  @override
  List<Object?> get props => [statement, unbilled, cta1, cta2, asset1];
}
