import '../../core/constants/card_management_constants.dart';
import 'statement_info_entity.dart';

class StatementInfoData {
  final String title; // statement.text_3 ("TOTAL DUE")
  final int dueCount; // statement.due_count (1)
  final String subtitle; // statement.text_1 ("STATEMENT DUE FOR 1 CARD")
  final String amount; // statement.text_2 ("₹50,000.00")
  final String? ctaTitle; // statement.cta_2.title ("Pay bill") or null if omitted
  final String unbilledTitle; // unbilled.text_3 ("RECENT SPENDS")

  StatementInfoData({
    required this.title,
    required this.dueCount,
    required this.subtitle,
    required this.amount,
    this.ctaTitle,
    required this.unbilledTitle,
  });

  factory StatementInfoData.fromJson(Map<String, dynamic> json) {
    final body = json['template_properties']?['body'] ?? {};
    final statement = body['statement'] ?? {};
    final unbilled = body['unbilled'] ?? {};

    return StatementInfoData(
      title: statement['text_3'] ?? CardManagementConstants.totalDueLabel,
      dueCount: statement['due_count'] ?? 0,
      subtitle: statement['text_1'] ?? '',
      amount: statement['text_2'] ?? '',
      ctaTitle: statement['cta_2']?['title'] as String?,
      unbilledTitle: unbilled['text_3'] ?? CardManagementConstants.recentSpendsLabel,
    );
  }

  factory StatementInfoData.fromEntity(StatementInfoEntity entity) {
    return StatementInfoData(
      title: entity.statement?.text3 ?? CardManagementConstants.totalDueLabel,
      dueCount: entity.statement?.dueCount ?? 0,
      subtitle: entity.statement?.text1 ?? '',
      amount: entity.statement?.text2 ?? '',
      ctaTitle: entity.statement?.cta2?.title,
      unbilledTitle: entity.unbilled?.text3 ?? CardManagementConstants.recentSpendsLabel,
    );
  }
}
