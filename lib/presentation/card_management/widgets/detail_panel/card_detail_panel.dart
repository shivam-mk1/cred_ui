import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/card_instrument_entity.dart';
import '../../local_models/card_detail_static_data.dart';
import '../card/card_face_widget.dart';
import '../card/card_pose.dart';
import 'detail_row_widget.dart';

class CardDetailPanel extends StatelessWidget {
  const CardDetailPanel({
    super.key,
    required this.card,
    this.onClose,
  });

  final CardInstrumentEntity card;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final String headerText = (card.statement?.text2 != null &&
            card.statement!.text2!.isNotEmpty)
        ? card.statement!.text2!.toUpperCase()
        : '${card.bankName}  ${card.text3 ?? ""}'.trim().toUpperCase();

    final bool hasStatement =
        card.statement?.text1 != null && card.statement!.text1!.isNotEmpty;
    final String statementSubtitle = hasStatement
        ? '${card.statement!.text1!} ${card.statement?.text2?.isNotEmpty == true ? '• ${card.statement!.text2!}' : 'bill generated'}'
        : 'no bill due • all payments completed';

    final pendingActionPill = card.flipperPill
        .where((p) =>
            p.type == 'pending_action' ||
            (p.cta1?.title?.contains('pending action') == true))
        .firstOrNull;
    final String pendingSubtitle = pendingActionPill != null
        ? (pendingActionPill.cta1?.title
                ?.replaceAll(RegExp(r'</?format>'), '')
                .trim() ??
            'pending actions')
        : 'no pending actions';

    final dynamicDetailRows = <DetailPanelRow>[
      DetailPanelRow(
        icon: Icons.description_outlined,
        title: 'latest statement',
        subtitle: statementSubtitle,
      ),
      DetailPanelRow(
        icon: Icons.credit_card_rounded,
        title: card.bankName,
        subtitle: card.text3 != null && card.text3!.isNotEmpty
            ? 'card number ${card.text3}'
            : 'active credit card',
      ),
      if (pendingActionPill != null)
        DetailPanelRow(
          icon: Icons.notification_important_outlined,
          title: 'pending actions',
          subtitle: pendingSubtitle,
        ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar: drag handle & close button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fully visible card in detail mode (not half-cut)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CardFaceWidget(
              card: card,
              pose: CardPose.identity,
              showStatementOverlay: true,
              showPill: false,
            ),
          ),
          const SizedBox(height: 16),

          // White details panel
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.detailPanelBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'mark as paid',
                        onTap: () {},
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: AppColors.detailRowDivider,
                    ),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.description_outlined,
                        label: 'payment history',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.detailRowDivider,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section date / bank header
                      Text(
                        headerText.isNotEmpty
                            ? headerText
                            : 'CARD DETAILS',
                        style: AppTextStyles.detailSectionDate,
                      ),
                      const SizedBox(height: 8),
                      // Detail rows bound to card data
                      ...dynamicDetailRows.map(
                        (row) => DetailRowWidget(
                          icon: row.icon,
                          title: row.title,
                          subtitle: row.subtitle,
                          onTap: row.onTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.tabActive,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
