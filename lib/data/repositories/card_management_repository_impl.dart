import '../../domain/entities/section_entity.dart';
import '../../domain/entities/top_bar_entity.dart';
import '../../domain/entities/statement_info_entity.dart';
import '../../domain/entities/card_instrument_entity.dart';
import '../../domain/entities/offer_banner_entity.dart';
import '../../domain/repositories/card_management_repository.dart';
import '../datasources/card_management_remote_datasource.dart';

class CardManagementRepositoryImpl implements CardManagementRepository {
  const CardManagementRepositoryImpl(this._datasource);

  final CardManagementRemoteDatasource _datasource;

  @override
  Future<List<SectionEntity>> fetchSections() async {
    final raw = await _datasource.fetchRaw();
    final items = raw['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => _parseSection(e as Map<String, dynamic>? ?? {}))
        .toList();
  }

  SectionEntity _parseSection(Map<String, dynamic> map) {
    final templateName = (map['template_name'] as String?) ?? '';
    final externalId = map['external_id'] as String?;
    final props = map['template_properties'] as Map<String, dynamic>? ?? {};
    final body = props['body'] as Map<String, dynamic>? ?? {};
    final rawChildList = props['child_list'] as List<dynamic>? ?? [];
    final childList = rawChildList
        .map((e) => _parseSection(e as Map<String, dynamic>? ?? {}))
        .toList();

    return switch (templateName) {
      'cm_top_bar' => TopBarSection(
          externalId: externalId,
          body: TopBarEntity.fromMap(body),
        ),
      'unbilled_statement_info_section_v2' => StatementInfoSection(
          externalId: externalId,
          body: StatementInfoEntity.fromMap(body),
          childList: childList,
        ),
      'cm_card_instrument' => CardInstrumentSection(
          externalId: externalId,
          body: CardInstrumentEntity.fromMap(body),
        ),
      'unbilled_statement_info_section_offer_2' => OfferBannerSection(
          externalId: externalId,
          body: OfferBannerEntity.fromMap(body),
        ),
      _ => UnknownSection(templateName),
    };
  }
}
