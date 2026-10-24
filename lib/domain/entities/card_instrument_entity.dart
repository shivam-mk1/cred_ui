import 'package:equatable/equatable.dart';
import 'cta_entity.dart';
import 'asset_entity.dart';
import 'flipper_pill_entity.dart';

/// Statement due information associated with an individual payment card.
class CardStatementEntity extends Equatable {
  const CardStatementEntity({
    this.text1,
    this.text2,
    this.cta1,
    this.asset4,
  });

  final String? text1; // due amount string
  final String? text2; // due date string
  final CtaEntity? cta1; // "Pay now" button
  final AssetEntity? asset4;

  static CardStatementEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CardStatementEntity();
    return CardStatementEntity(
      text1: map['text_1'] as String?,
      text2: map['text_2'] as String?,
      cta1: CtaEntity.fromMap(map['cta_1'] as Map<String, dynamic>?),
      asset4: AssetEntity.fromMap(map['asset_4'] as Map<String, dynamic>?),
    );
  }

  @override
  List<Object?> get props => [text1, text2, cta1, asset4];
}

/// Domain entity representing a user card instrument from `cm_card_instrument`.
class CardInstrumentEntity extends Equatable {
  const CardInstrumentEntity({
    this.instrumentId,
    this.showAlert = false,
    this.isLight = false,
    this.rupaySupported = false,
    this.provider,
    this.isCredCard = false,
    this.tapAndPaySupported = false,
    this.text3,
    this.text4,
    this.text5,
    this.alertColor,
    this.asset1,
    this.asset2,
    this.asset3,
    this.statement,
    this.flipperPill = const [],
  });

  final String? instrumentId;

  final bool showAlert;

  final bool isLight;

  final bool rupaySupported;
  final String? provider; //"RUPAY"
  final bool isCredCard;
  final bool tapAndPaySupported;

  final String? text3;

  final String? text4;

  final String? text5;
  final String? alertColor;

  /// Card background image
  final AssetEntity? asset1;

  /// Secondary logo (e.g. RuPay badge)
  final AssetEntity? asset2;

  /// Bank mini-card art
  final AssetEntity? asset3;

  final CardStatementEntity? statement;

  /// Sorted by priority ascending on parse
  final List<FlipperPillEntity> flipperPill;

  /// Extracts bank name from mini-card asset url (e.g. "AXIS BANK MINI
  /// CARD.png" -> "AXIS BANK") or falls back to provider / credit card.
  String get bankName {
    if (asset3?.url != null && asset3!.url!.isNotEmpty) {
      final uri = Uri.tryParse(asset3!.url!);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final last = Uri.decodeComponent(uri.pathSegments.last);
        final clean = last
            .replaceAll(RegExp(r'\s*MINI\s*CARD.*', caseSensitive: false), '')
            .replaceAll(RegExp(r'\.png$|\.jpg$|\.webp$', caseSensitive: false), '')
            .trim();
        if (clean.isNotEmpty) return clean;
      }
    }
    if (provider != null && provider!.isNotEmpty) {
      return provider!;
    }
    return 'CREDIT CARD';
  }

  static CardInstrumentEntity fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CardInstrumentEntity();

    final rawPills = map['flipper_pill'] as List<dynamic>? ?? [];
    final pills = rawPills
        .map((e) => FlipperPillEntity.fromMap(e as Map<String, dynamic>?))
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    return CardInstrumentEntity(
      instrumentId: map['instrument_id'] as String?,
      showAlert: (map['show_alert'] as bool?) ?? false,
      isLight: (map['is_light'] as bool?) ?? false,
      rupaySupported: (map['rupay_supported'] as bool?) ?? false,
      provider: map['provider'] as String?,
      isCredCard: (map['is_cred_card'] as bool?) ?? false,
      tapAndPaySupported: (map['tap_and_pay_supported'] as bool?) ?? false,
      text3: map['text_3'] as String?,
      text4: map['text_4'] as String?,
      text5: map['text_5'] as String?,
      alertColor: map['alert_color'] as String?,
      asset1: AssetEntity.fromMap(map['asset_1'] as Map<String, dynamic>?),
      asset2: AssetEntity.fromMap(map['asset_2'] as Map<String, dynamic>?),
      asset3: AssetEntity.fromMap(map['asset_3'] as Map<String, dynamic>?),
      statement: CardStatementEntity.fromMap(
          map['statement'] as Map<String, dynamic>?),
      flipperPill: pills,
    );
  }

  @override
  List<Object?> get props => [
        instrumentId,
        showAlert,
        isLight,
        rupaySupported,
        provider,
        isCredCard,
        tapAndPaySupported,
        text3,
        text4,
        text5,
        alertColor,
        asset1,
        asset2,
        asset3,
        statement,
        flipperPill,
      ];
}
