import 'package:flutter/material.dart';
import '../../../../domain/entities/card_instrument_entity.dart';
import 'card_face_widget.dart';
import 'card_pose.dart';

class CardListLayout extends StatelessWidget {
  const CardListLayout({
    super.key,
    required this.cards,
    required this.selectedCardIndex,
    this.onSelectCard,
    this.onPayNowTap,
  });

  final List<CardInstrumentEntity> cards;
  final int selectedCardIndex;
  final ValueChanged<int>? onSelectCard;
  final ValueChanged<int>? onPayNowTap;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: cards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final card = cards[index];
        return RepaintBoundary(
          child: GestureDetector(
            onTap: () => onSelectCard?.call(index),
            child: CardFaceWidget(
              card: card,
              pose: CardPose.identity,
              showStatementOverlay: true,
              showPill: true,
              onPayNowTap: () => onPayNowTap?.call(index),
            ),
          ),
        );
      },
    );
  }
}
