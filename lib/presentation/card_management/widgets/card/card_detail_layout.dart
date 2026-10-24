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
        LayoutBuilder(
          builder: (context, constraints) {
            // Reserve ~48% of available width for the action grid
            final totalWidth = constraints.maxWidth;
            final gridWidth = totalWidth * 0.48;
            final cardVisibleWidth = totalWidth - gridWidth;
            // Card aspect ratio 1.586 → derive rendered height from visible width
            const cardAspectRatio = 1.586;
            final rowHeight = (cardVisibleWidth / cardAspectRatio) * 1.45;

            return SizedBox(
              height: rowHeight,
              child: Stack(
                children: [
                  // Card: bleeds left off-screen; only right portion is visible
                  Positioned(
                    left: -(totalWidth - cardVisibleWidth - 32),
                    top: 0,
                    width: totalWidth - 32,
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

                  // 6-item Action Grid — right-aligned, fills full row height
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: gridWidth,
                    child: const _ActionGrid(),
                  ),
                ],
              ),
            );
          },
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
    // Split into rows of 2
    final rows = <List<ActionGridItem>>[];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(items.sublist(i, (i + 2).clamp(0, items.length)));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rows.map((rowItems) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: rowItems
                  .map((item) => Expanded(child: _ActionGridItemWidget(item: item)))
                  .toList(),
            );
          }).toList(),
        );
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
