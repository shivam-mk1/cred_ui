import 'package:flutter/material.dart';
import '../../../../domain/entities/card_instrument_entity.dart';
import 'card_face_widget.dart';
import 'card_pose.dart';

class CardStackLayout extends StatelessWidget {
  const CardStackLayout({
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RepaintBoundary(
            child: CardFaceWidget(
              card: activeCard,
              pose: CardPose.identity,
              showStatementOverlay: true,
              showPill: true,
              onPayNowTap: onPayNowTap,
              onCardTap: onCardTap,
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (cards.length > 1)
          _PeekingDeck(
            cards: cards,
            activeIndex: safeIndex,
            onSelectCard: onSelectCard,
          ),
      ],
    );
  }
}

class _PeekingDeck extends StatelessWidget {
  const _PeekingDeck({
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

    final visibleCount = otherIndices.length.clamp(1, 3);
    final visibleIndices = otherIndices.take(visibleCount).toList();

    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          for (int layer = visibleIndices.length - 1; layer >= 0; layer--) ...[
            Builder(
              builder: (context) {
                final cardIndex = visibleIndices[layer];
                final card = cards[cardIndex];
                final verticalOffset = layer * 18.0;
                final scale = 1.0 - (layer * 0.04);
                final pose = CardPose(
                  offset: Offset(0, verticalOffset),
                  scale: scale,
                  opacity: 1.0 - (layer * 0.05),
                );

                return Positioned(
                  top: verticalOffset,
                  left: 16,
                  right: 16,
                  child: RepaintBoundary(
                    child: GestureDetector(
                      onTap: () => onSelectCard?.call(cardIndex),
                      child: CardFaceWidget(
                        card: card,
                        pose: pose,
                        showStatementOverlay: false,
                        showPill: false,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
