import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/card_instrument_entity.dart';
import '../../local_models/card_detail_static_data.dart';
import 'card_face_widget.dart';
import 'card_pose.dart';

class CardDetailLayout extends StatelessWidget {
  const CardDetailLayout({
    super.key,
    required this.cards,
    required this.selectedCardIndex,
    this.onSelectCard,
    this.onPayNowTap,
    this.onCardTap,
  });

  final List<CardInstrumentEntity> cards;
  final int selectedCardIndex;
  final ValueChanged<int>? onSelectCard;
  final VoidCallback? onPayNowTap;
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    final safeIndex = selectedCardIndex.clamp(0, cards.length - 1);
    final activeCard = cards[safeIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Card + 6-item Action Grid row ──────────────────────────────────
        SizedBox(
          height: 240,
          child: Stack(
            children: [
              // Card shifted left
              Positioned(
                left: -145,
                top: 0,
                width: MediaQuery.of(context).size.width - 32,
                child: RepaintBoundary(
                  child: CardFaceWidget(
                    card: activeCard,
                    pose: const CardPose(offset: Offset.zero),
                    showStatementOverlay: true,
                    showPill: false,
                    onPayNowTap: onPayNowTap,
                    onCardTap: onCardTap,
                  ),
                ),
              ),

              // 6-item Action Grid on right
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                width: 175,
                child: const _ActionGrid(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Bottom peek deck ──────────────────────────────────────────────
        if (cards.length > 1)
          _BottomPeekDeck(
            cards: cards,
            activeIndex: safeIndex,
            onSelectCard: onSelectCard,
          ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    final items = CardDetailStaticData.actionGridItems;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ActionGridItemWidget(item: item);
      },
    );
  }
}

class _ActionGridItemWidget extends StatelessWidget {
  const _ActionGridItemWidget({required this.item});

  final ActionGridItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceCard,
              border: Border.all(color: const Color(0xFFE5E5E0), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: AppTextStyles.actionGridLabel,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _BottomPeekDeck extends StatelessWidget {
  const _BottomPeekDeck({
    required this.cards,
    required this.activeIndex,
    this.onSelectCard,
  });

  final List<CardInstrumentEntity> cards;
  final int activeIndex;
  final ValueChanged<int>? onSelectCard;

  @override
  Widget build(BuildContext context) {
    final otherIndices = <int>[];
    for (int i = 0; i < cards.length; i++) {
      if (i != activeIndex) otherIndices.add(i);
    }
    if (otherIndices.isEmpty) return const SizedBox.shrink();

    final nextIndex = otherIndices.first;
    final peekCard = cards[nextIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () => onSelectCard?.call(nextIndex),
          child: CardFaceWidget(
            card: peekCard,
            pose: const CardPose(scale: 0.96),
            showStatementOverlay: false,
            showPill: false,
          ),
        ),
      ),
    );
  }
}
