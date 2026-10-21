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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 90,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: 220,
                child: CardFaceWidget(
                  card: card,
                  pose: CardPose.identity,
                  showStatementOverlay: false,
                  showPill: false,
                ),
              ),
            ),
          ),
        ),
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
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section date header
                    const Text(
                      CardDetailStaticData.detailSectionDate,
                      style: AppTextStyles.detailSectionDate,
                    ),
                    const SizedBox(height: 8),
                    // Detail rows
                    ...CardDetailStaticData.detailRows.map(
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
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.tabActive,
            ),
          ],
        ),
      ),
    );
  }
}
