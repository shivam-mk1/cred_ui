import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/cta_dispatcher.dart';
import '../../../../domain/entities/section_entity.dart';
import '../../../../domain/entities/statement_info_entity.dart';
import '../../cubit/card_management_state.dart';
import '../shared/server_image_widget.dart';
import 'template_registry.dart';

/// Renders template `unbilled_statement_info_section_v2`.
/// Displays total due or recent spends based on [activeToggle],
/// with celebratory background art and recursive child sections.
class StatementInfoTemplate extends StatelessWidget {
  const StatementInfoTemplate({
    super.key,
    required this.statementInfo,
    required this.childList,
    required this.activeToggle,
    required this.ctaDispatcher,
    required this.templateRegistry,
  });

  final StatementInfoEntity statementInfo;
  final List<SectionEntity> childList;
  final ActiveToggle activeToggle;
  final CtaDispatcher ctaDispatcher;
  final TemplateRegistry templateRegistry;

  @override
  Widget build(BuildContext context) {
    final isTotalDue = activeToggle == ActiveToggle.totalDue;
    final statement = statementInfo.statement;
    final unbilled = statementInfo.unbilled;

    final label = isTotalDue ? statement?.text1 : unbilled?.text1;
    final amount = isTotalDue ? statement?.text2 : unbilled?.text2;
    final ctaButton = isTotalDue ? statement?.cta2 : unbilled?.cta2;
    final flowCta = isTotalDue ? statement?.cta1 : null;
    final amountParts = amount?.split('.');
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: AppColors.shimmerHighlight,
            offset: Offset(0, 30),
            spreadRadius: 1,
            blurRadius: 30)
      ]),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ── Celebratory background gift boxes/confetti asset ─────────────────
          if (statementInfo.asset1?.hasUrl == true)
            Positioned(
              top: -14,
              left: 0,
              right: 0,
              height: 180,
              child: Opacity(
                opacity: 0.85,
                child: ServerImageWidget(
                  url: statementInfo.asset1!.url!,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // ── Main statement content ──────────────────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 14),

              // Due label
              if (label != null && label.isNotEmpty)
                Text(
                  label,
                  style: AppTextStyles.statementLabel,
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 4),

              // Amount + dropdown arrow
              if (amount != null && amount.isNotEmpty)
                GestureDetector(
                  onTap: () => ctaDispatcher.dispatch(context, flowCta),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.statementAmount,
                          children: [
                            TextSpan(
                              text: amountParts != null && amountParts.isNotEmpty
                                  ? amountParts[0]
                                  : amount,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (amountParts != null && amountParts.length > 1)
                              TextSpan(text: '.${amountParts[1]}'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // "Pay bill" / "View transactions" black pill button
              if (ctaButton?.title != null && ctaButton!.title!.isNotEmpty)
                GestureDetector(
                  onTap: () => ctaDispatcher.dispatch(context, ctaButton),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.ctaBgDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ctaButton.title!,
                      style: AppTextStyles.ctaButtonDark,
                    ),
                  ),
                ),

              // Bottom spacing reserve when childList is present
              if (childList.isNotEmpty) const SizedBox(height: 48),
            ],
          ),

          if (childList.isNotEmpty)
            Positioned(
              bottom: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: childList
                      .map((child) => templateRegistry.build(context, child))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
