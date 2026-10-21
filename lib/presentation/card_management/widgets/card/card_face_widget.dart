import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/card_instrument_entity.dart';
import '../shared/server_image_widget.dart';
import '../shared/flipper_pill_widget.dart';
import 'card_pose.dart';

class CardFaceWidget extends StatelessWidget {
  const CardFaceWidget({
    super.key,
    required this.card,
    required this.pose,
    this.showStatementOverlay = true,
    this.showPill = true,
    this.onPayNowTap,
    this.onCardTap,
  });

  final CardInstrumentEntity card;
  final CardPose pose;

  /// When false (e.g. in peek/stack positions) hides statement info overlay.
  final bool showStatementOverlay;

  /// When false hides the flipper pill row below the card.
  final bool showPill;

  final VoidCallback? onPayNowTap;
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Transform(
        transform:
            Matrix4.translationValues(pose.offset.dx, pose.offset.dy, 0.0)
              ..rotateZ(pose.rotation)
              ..multiply(Matrix4.diagonal3Values(pose.scale, pose.scale, 1.0)),
        alignment: Alignment.topCenter,
        child: Opacity(
          opacity: pose.opacity.clamp(0.0, 1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardBody(
                card: card,
                showStatementOverlay: showStatementOverlay,
                onPayNowTap: onPayNowTap,
                onCardTap: onCardTap,
              ),
              if (showPill && card.flipperPill.isNotEmpty) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: FlipperPillWidget(
                    pills: card.flipperPill,
                    isLight: card.isLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.card,
    required this.showStatementOverlay,
    this.onPayNowTap,
    this.onCardTap,
  });

  final CardInstrumentEntity card;
  final bool showStatementOverlay;
  final VoidCallback? onPayNowTap;
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: AspectRatio(
        aspectRatio: 1.586,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background ─────────────────────────────────────────────
              if (card.asset1?.hasUrl == true)
                ServerImageWidget(url: card.asset1!.url!)
              else
                Container(color: AppColors.cardBg),

              // ── Content overlay ────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: mini bank logo (left) + statement (right)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        // Statement info (top-right) — conditional
                        if (showStatementOverlay &&
                            card.statement?.text1 != null &&
                            card.statement!.text1!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                card.statement!.text1!,
                                style: AppTextStyles.cardDueAmount,
                              ),
                              if (card.statement?.text2 != null &&
                                  card.statement!.text2!.isNotEmpty)
                                Text(
                                  card.statement!.text2!,
                                  style: AppTextStyles.cardDueDate,
                                ),
                            ],
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Last-4 masked number
                    if (card.text3 != null && card.text3!.isNotEmpty)
                      Text(card.text3!, style: AppTextStyles.cardLastFour),

                    const SizedBox(height: 30),

                    const Spacer(),

                    // Bottom row: cardholder name + Pay now CTA
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (card.text4 != null && card.text4!.isNotEmpty)
                          Text(
                            card.text4!.toUpperCase(),
                            style: AppTextStyles.cardHolderName,
                          ),
                        const Spacer(),
                        if (card.statement?.cta1?.title != null &&
                            card.statement!.cta1!.title!.isNotEmpty)
                          _PayNowButton(
                            label: card.statement!.cta1!.title!,
                            onTap: onPayNowTap,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── RuPay badge (top-right over statement) ──────────────
              if (card.rupaySupported && card.asset2?.hasUrl == true)
                Positioned(
                  right: 12,
                  bottom: 14,
                  child: ServerImageWidget(
                    url: card.asset2!.url!,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                ),

              // ── Alert indicator ─────────────────────────────────────
              if (card.showAlert)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          card.alertColor != null && card.alertColor!.isNotEmpty
                              ? _hexColor(card.alertColor!)
                              : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    final v = int.tryParse(clean, radix: 16);
    if (v == null) return AppColors.error;
    return clean.length == 6 ? Color(0xFF000000 | v) : Color(v);
  }
}

class _PayNowButton extends StatelessWidget {
  const _PayNowButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.ctaBgLight,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label, style: AppTextStyles.ctaButtonLight),
      ),
    );
  }
}
