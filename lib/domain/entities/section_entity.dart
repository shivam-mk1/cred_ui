import 'package:equatable/equatable.dart';
import 'top_bar_entity.dart';
import 'statement_info_entity.dart';
import 'card_instrument_entity.dart';
import 'offer_banner_entity.dart';

/// Sealed root entity representing a server-driven UI section template.
sealed class SectionEntity extends Equatable {
  const SectionEntity();
}

/// Section representing the `cm_top_bar` template.
final class TopBarSection extends SectionEntity {
  const TopBarSection({this.externalId, required this.body});

  final String? externalId;
  final TopBarEntity body;

  @override
  List<Object?> get props => [externalId, body];
}

/// Section representing the `unbilled_statement_info_section_v2` template.
final class StatementInfoSection extends SectionEntity {
  const StatementInfoSection({
    this.externalId,
    required this.body,
    this.childList = const [],
  });

  final String? externalId;
  final StatementInfoEntity body;
  final List<SectionEntity> childList;

  @override
  List<Object?> get props => [externalId, body, childList];
}

/// Section representing the `cm_card_instrument` template.
final class CardInstrumentSection extends SectionEntity {
  const CardInstrumentSection({
    this.externalId,
    required this.body,
  });

  final String? externalId;
  final CardInstrumentEntity body;

  @override
  List<Object?> get props => [externalId, body];
}

/// Section representing the `unbilled_statement_info_section_offer_2` template.
final class OfferBannerSection extends SectionEntity {
  const OfferBannerSection({this.externalId, required this.body});

  final String? externalId;
  final OfferBannerEntity body;

  @override
  List<Object?> get props => [externalId, body];
}

/// Fallback for unrecognized server templates rendered as empty space.
final class UnknownSection extends SectionEntity {
  const UnknownSection(this.templateName);

  final String templateName;

  @override
  List<Object?> get props => [templateName];
}
