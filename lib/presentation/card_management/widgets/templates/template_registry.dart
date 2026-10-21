import 'package:flutter/widgets.dart';
import '../../../../core/utils/cta_dispatcher.dart';
import '../../../../domain/entities/section_entity.dart';
import '../../cubit/card_management_state.dart';
import 'cm_top_bar_template.dart';
import 'offer_banner_template.dart';
import 'statement_info_template.dart';
import 'unknown_template.dart';

typedef TemplateBuilder = Widget Function(
  BuildContext context,
  SectionEntity section,
  TemplateRegistry registry,
);

/// Registry for Server-Driven UI sections.
/// Maps sealed [SectionEntity] variants to widget builders.
/// Unknown templates are safely skipped with [UnknownTemplate].
/// Recursive [child_list] items are routed through this same registry.
class TemplateRegistry {
  TemplateRegistry({
    required this.ctaDispatcher,
    this.activeToggle = ActiveToggle.totalDue,
    this.topBarCenterWidget,
  });

  final CtaDispatcher ctaDispatcher;
  final ActiveToggle activeToggle;
  final Widget? topBarCenterWidget;

  Widget build(BuildContext context, SectionEntity section) {
    return switch (section) {
      TopBarSection s => CmTopBarTemplate(
          topBar: s.body,
          ctaDispatcher: ctaDispatcher,
          centerWidget: topBarCenterWidget,
        ),
      StatementInfoSection s => StatementInfoTemplate(
          statementInfo: s.body,
          childList: s.childList,
          activeToggle: activeToggle,
          ctaDispatcher: ctaDispatcher,
          templateRegistry: this,
        ),
      OfferBannerSection s => OfferBannerTemplate(
          offer: s.body,
          ctaDispatcher: ctaDispatcher,
        ),
      CardInstrumentSection _ => const SizedBox.shrink(),
      UnknownSection s => UnknownTemplate(templateName: s.templateName),
    };
  }
}
