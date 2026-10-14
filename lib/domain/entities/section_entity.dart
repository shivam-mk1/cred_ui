import 'package:equatable/equatable.dart';
import 'top_bar_entity.dart';
import 'statement_info_entity.dart';
import 'card_instrument_entity.dart';
import 'offer_banner_entity.dart';

sealed class SectionEntity extends Equatable {
  const SectionEntity();
}

final class TopBarSection extends SectionEntity {
  const TopBarSection({this.externalId, required this.body});

  final String? externalId;
  final TopBarEntity body;

  @override
  List<Object?> get props => [externalId, body];
}

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

final class OfferBannerSection extends SectionEntity {
  const OfferBannerSection({this.externalId, required this.body});

  final String? externalId;
  final OfferBannerEntity body;

  @override
  List<Object?> get props => [externalId, body];
}

/// Fallback for any template_name not in this set — rendered as SizedBox.shrink().
final class UnknownSection extends SectionEntity {
  const UnknownSection(this.templateName);

  final String templateName;

  @override
  List<Object?> get props => [templateName];
}
