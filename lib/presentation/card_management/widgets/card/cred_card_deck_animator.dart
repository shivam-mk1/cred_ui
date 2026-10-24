// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class CredCardDeckAnimator extends StatefulWidget {
  final List<Widget> cards;
  final double? cardHeight;
  final double cardSpacing;

  final double stackPeekHeight;

  final Widget? header;

  final Widget? quickActions;

  final Widget? detailsSheet;
  final Widget Function(
    BuildContext context,
    int selectedIndex,
    VoidCallback onClose,
  )? detailsSheetBuilder;

  const CredCardDeckAnimator({
    super.key,
    required this.cards,
    this.cardHeight,
    this.cardSpacing = 16.0,
    this.stackPeekHeight = 38.0,
    this.header,
    this.quickActions,
    this.detailsSheet,
    this.detailsSheetBuilder,
  });

  @override
  State<CredCardDeckAnimator> createState() => _CredCardDeckAnimatorState();
}

class _CredCardDeckAnimatorState extends State<CredCardDeckAnimator>
    with TickerProviderStateMixin {
  static const double kMaxLeftSlide = -115.0;

  late AnimationController _deckToListController;
  late Animation<double> _deckToListAnimation;
  bool _isListExpanded = false;
  double _scrollOffset = 0.0;
  double _maxScroll = 0.0;
  bool _dragStartedAtTop = false;
  double _cumulativeVerticalDrag = 0.0;

  // Momentum fling controller
  late AnimationController _flingController;
  late Animation<double> _flingAnimation;

  double _horizontalDragX = 0.0;
  bool _isLatchedOpen = false;
  late AnimationController _horizontalSnapController;
  late Animation<double> _horizontalSnapAnim;

  late AnimationController _expandDetailsController;
  late Animation<double> _expandDetailsAnimation;
  int _selectedCardIndex = 0;

  @override
  void initState() {
    super.initState();

    _deckToListController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _deckToListAnimation = CurvedAnimation(
      parent: _deckToListController,
      curve: Curves.fastOutSlowIn,
    );

    _flingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _horizontalSnapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _expandDetailsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _expandDetailsAnimation = CurvedAnimation(
      parent: _expandDetailsController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _deckToListController.dispose();
    _flingController.dispose();
    _horizontalSnapController.dispose();
    _expandDetailsController.dispose();
    super.dispose();
  }

  void _expandToList() {
    if (_deckToListController.isAnimating || _isListExpanded) return;
    _flingController.stop();
    if (_isLatchedOpen) _closeHorizontalSlide();

    setState(() {
      _scrollOffset = 0.0;
      _isListExpanded = true;
    });
    _deckToListController.forward(from: 0.0);
  }

  void _collapseToDeck() {
    if (_deckToListController.isAnimating || !_isListExpanded) return;
    _flingController.stop();

    setState(() {
      _scrollOffset = 0.0;
      _isListExpanded = false;
    });
    _deckToListController.reverse(from: 1.0);
  }

  void _performFling(double velocity) {
    if (!_isListExpanded || velocity.abs() < 100) return;

    final double distance = -velocity * 0.22;
    final double target = (_scrollOffset + distance).clamp(0.0, _maxScroll);

    if (target == _scrollOffset) return;

    _flingAnimation = Tween<double>(begin: _scrollOffset, end: target).animate(
      CurvedAnimation(parent: _flingController, curve: Curves.decelerate),
    )..addListener(() {
        setState(() {
          _scrollOffset = _flingAnimation.value;
        });
      });

    _flingController.forward(from: 0.0);
  }

  void _animateHorizontalTo(double target) {
    final double start = _horizontalDragX;
    _horizontalSnapAnim = Tween<double>(begin: start, end: target).animate(
      CurvedAnimation(
        parent: _horizontalSnapController,
        curve: Curves.easeOutCubic,
      ),
    )..addListener(() {
        setState(() {
          _horizontalDragX = _horizontalSnapAnim.value;
        });
      });

    _horizontalSnapController.forward(from: 0.0).then((_) {
      _isLatchedOpen = (target == kMaxLeftSlide);
    });
  }

  void _closeHorizontalSlide() {
    _animateHorizontalTo(0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _expandDetailsController,
      builder: (context, child) {
        final bool isDetailOpen = _expandDetailsController.value > 0 ||
            _expandDetailsController.isAnimating;

        return PopScope(
          canPop: !isDetailOpen,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (isDetailOpen) {
              _expandDetailsController.reverse();
            }
          },
          child: child!,
        );
      },
      child: Column(
        children: [
          if (widget.header != null) widget.header!,
          Expanded(
            child: ClipRect(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double viewportHeight = constraints.maxHeight;
                  final double viewportWidth = constraints.maxWidth;
                  final double cardWidth = math.max(0.0, viewportWidth - 32.0);
                  final double cardBodyHeight = cardWidth / 1.586;
                  final double effectiveCardHeight =
                      widget.cardHeight ?? (cardBodyHeight + 46.0);

                  // Compute max scroll extent for list mode
                  final double totalListHeight = (widget.cards.length *
                          (effectiveCardHeight + widget.cardSpacing)) -
                      widget.cardSpacing +
                      24.0;
                  _maxScroll = math.max(0.0, totalListHeight - viewportHeight);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragStart: (details) {
                      if (_expandDetailsController.value > 0) return;
                      _flingController.stop();
                      _dragStartedAtTop = (_scrollOffset <= 0.5);
                      _cumulativeVerticalDrag = 0.0;
                    },
                    onVerticalDragUpdate: (details) {
                      if (_expandDetailsController.value > 0 ||
                          _deckToListController.isAnimating ||
                          _isLatchedOpen) {
                        return;
                      }

                      _cumulativeVerticalDrag += details.delta.dy;

                      if (!_isListExpanded) return;

                      final double newOffset = _scrollOffset - details.delta.dy;
                      if (newOffset >= 0.0) {
                        setState(() {
                          _scrollOffset = newOffset.clamp(0.0, _maxScroll);
                        });
                      } else {
                        setState(() {
                          _scrollOffset = 0.0;
                        });
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (_expandDetailsController.value > 0 ||
                          _deckToListController.isAnimating ||
                          _isLatchedOpen) {
                        return;
                      }

                      final double velocity = details.primaryVelocity ?? 0.0;

                      if (!_isListExpanded) {
                        // Swipe up → expand into list
                        if (velocity < -180 || _cumulativeVerticalDrag < -40) {
                          _expandToList();
                        }
                      } else {
                        // Double swipe-down guard: only collapse when at top
                        if (_dragStartedAtTop &&
                            _scrollOffset <= 0.5 &&
                            (velocity > 180 || _cumulativeVerticalDrag > 40)) {
                          _collapseToDeck();
                        } else {
                          _performFling(velocity);
                        }
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.hardEdge,
                      children: [
                        _buildQuickActions(cardBodyHeight),
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _deckToListAnimation,
                            _expandDetailsAnimation,
                          ]),
                          builder: (context, child) {
                            final double tDeck = _deckToListAnimation.value;
                            final double tExpand =
                                _expandDetailsAnimation.value;

                            return Stack(
                              fit: StackFit.expand,
                              clipBehavior: Clip.none,
                              children: _buildCards(
                                viewportHeight,
                                viewportWidth,
                                effectiveCardHeight,
                                tDeck,
                                tExpand,
                              ),
                            );
                          },
                        ),
                        _buildModalSheet(size, viewportHeight),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(double cardBodyHeight) {
    final double revealProgress =
        (_horizontalDragX.abs() / kMaxLeftSlide.abs()).clamp(0.0, 1.0);

    // The quick-action panel sits to the right of the swiped card.
    // Width matches the exposed gap when fully swiped (kMaxLeftSlide.abs()).
    final double panelWidth = kMaxLeftSlide.abs() - 8;

    return Positioned(
      top: 40,
      right: 0,
      width: panelWidth,
      height: cardBodyHeight,
      child: IgnorePointer(
        ignoring: !_isLatchedOpen,
        child: Opacity(
          opacity: revealProgress,
          child: Transform.scale(
            scale: 0.85 + (0.15 * revealProgress),
            alignment: Alignment.centerRight,
            child: widget.quickActions ?? const _DefaultActionGrid(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCards(
    double viewportHeight,
    double viewportWidth,
    double effectiveCardHeight,
    double tDeck,
    double tExpand,
  ) {
    final List<Widget> widgets = [];
    final int count = widget.cards.length;

    // Front card of the bottom deck (Card index 1) sits ~115px above viewport bottom
    final double frontCardY = viewportHeight - 115.0;

    // Pre-calculate resting Deck coordinates and scales
    final List<double> deckY = List<double>.filled(count, 0.0);
    final List<double> deckScale = List<double>.filled(count, 1.0);

    // Card 0 (Active card at top)
    deckY[0] = 40.0;
    deckScale[0] = 1.0;

    // Bottom stack cards (Card 1, 2, 3...)
    for (int i = 1; i < count; i++) {
      if (i == 1) {
        // Front-most card of the bottom stack
        deckY[i] = frontCardY;
        deckScale[i] = 1.0;
      } else if (i == 2) {
        // Immediately behind Card 1: peeks 46px above Card 1 so header & logo are visible
        deckY[i] = frontCardY - 46.0;
        deckScale[i] = 0.94;
      } else {
        // Cards further back peek an additional 22px higher each, with smaller scale
        deckY[i] = frontCardY - 46.0 - ((i - 2) * 22.0);
        deckScale[i] = math.max(0.80, 0.94 - ((i - 2) * 0.05));
      }
    }

    // Paint from deepest bottom card (count - 1) down to Card 1, then Card 0 on top
    final List<int> paintOrder = [];
    for (int i = count - 1; i >= 1; i--) {
      paintOrder.add(i);
    }
    paintOrder.add(0);

    for (final int i in paintOrder) {
      // List Mode coordinates (sequential linear list)
      final double listY = i * (effectiveCardHeight + widget.cardSpacing);
      const double listScale = 1.0;

      // Smooth GPU interpolation from Deck to List
      final double interpolatedY = lerpDouble(deckY[i], listY, tDeck)!;
      final double interpolatedScale =
          lerpDouble(deckScale[i], listScale, tDeck)!;
      double currentY = interpolatedY - (tDeck == 1.0 ? _scrollOffset : 0.0);

      // Modal Expand adjustment
      if (tExpand > 0) {
        if (i == _selectedCardIndex) {
          currentY = currentY - (currentY * tExpand);
        } else {
          currentY += (viewportHeight * 0.5) * tExpand;
        }
      }

      // Horizontal 3D Perspective Matrix (Active top card in deck mode)
      Matrix4 transformMatrix = Matrix4.identity();
      if (i == 0 && tDeck < 0.5) {
        final dragFraction =
            (_horizontalDragX.abs() / kMaxLeftSlide.abs()).clamp(0.0, 1.0);
        final angleY = -dragFraction * (math.pi / 10.0);

        transformMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..translate(_horizontalDragX, 0.0, 0.0)
          ..rotateY(angleY);
      }

      widgets.add(Positioned(
          top: 0,
          left: 16,
          right: 16,
          height: effectiveCardHeight,
          child: Transform.translate(
            offset: Offset(0, currentY),
            child: Transform.scale(
              scale: interpolatedScale,
              alignment: Alignment.topCenter,
              child: IgnorePointer(
                ignoring: tExpand > 0,
                child: Opacity(
                  opacity: (1.0 - tExpand).clamp(0.0, 1.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate:
                        (i == 0 && tDeck < 0.5 && tExpand == 0)
                            ? (details) {
                                setState(() {
                                  _horizontalDragX =
                                      (_horizontalDragX + details.delta.dx)
                                          .clamp(kMaxLeftSlide, 0.0);
                                });
                              }
                            : null,
                    onHorizontalDragEnd: (i == 0 && tDeck < 0.5 && tExpand == 0)
                        ? (details) {
                            final v = details.primaryVelocity ?? 0.0;
                            if (!_isLatchedOpen) {
                              if (_horizontalDragX < kMaxLeftSlide * 0.35 ||
                                  v < -250) {
                                _animateHorizontalTo(kMaxLeftSlide);
                              } else {
                                _animateHorizontalTo(0.0);
                              }
                            } else {
                              if (_horizontalDragX > kMaxLeftSlide * 0.65 ||
                                  v > 250) {
                                _animateHorizontalTo(0.0);
                              } else {
                                _animateHorizontalTo(kMaxLeftSlide);
                              }
                            }
                          }
                        : null,
                    onTap: () {
                      if (_isLatchedOpen) {
                        _closeHorizontalSlide();
                      } else if (tExpand == 0) {
                        setState(() {
                          _selectedCardIndex = i;
                        });
                        _expandDetailsController.forward();
                      }
                    },
                    child: Transform(
                      alignment: Alignment.centerLeft,
                      transform: transformMatrix,
                      child: RepaintBoundary(
                        child: widget.cards[i],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )));
    }

    return widgets;
  }

  Widget _buildModalSheet(Size size, double viewportHeight) {
    return AnimatedBuilder(
      animation: _expandDetailsAnimation,
      builder: (context, child) {
        final double progress = _expandDetailsAnimation.value;
        if (progress == 0 && !_expandDetailsController.isAnimating) {
          return const SizedBox.shrink();
        }

        final double sheetHeight = math.min(viewportHeight, size.height * 0.88);
        void closeAction() => _expandDetailsController.reverse();

        final Widget sheetWidget;
        if (widget.detailsSheetBuilder != null) {
          sheetWidget = widget.detailsSheetBuilder!(
            context,
            _selectedCardIndex,
            closeAction,
          );
        } else if (widget.detailsSheet != null) {
          sheetWidget = widget.detailsSheet!;
        } else {
          sheetWidget = _DefaultDetailsSheet(
            selectedIndex: _selectedCardIndex,
            onDismiss: closeAction,
          );
        }

        return Stack(
          children: [
            // Darkened backdrop scrim: tapping closes the detail view
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: closeAction,
              child: Container(
                color: Colors.black
                    .withOpacity((0.55 * progress).clamp(0.0, 0.55)),
              ),
            ),
            // Sliding modal sheet with drag down to dismiss
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: sheetHeight,
              child: Transform.translate(
                offset: Offset(0, (1.0 - progress) * sheetHeight),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragEnd: (details) {
                    if ((details.primaryVelocity ?? 0.0) > 200) {
                      closeAction();
                    }
                  },
                  child: sheetWidget,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A 2-column × 3-row grid of action chips that fills its parent's height
/// using spaceEvenly — no fixed childAspectRatio, no clipping.
class _DefaultActionGrid extends StatelessWidget {
  static const _items = [
    (icon: Icons.check_circle_outline, label: 'mark as paid'),
    (icon: Icons.summarize_outlined, label: 'smart statement'),
    (icon: Icons.history, label: 'payment history'),
    (icon: Icons.percent_outlined, label: 'card offers'),
    (icon: Icons.receipt_long, label: 'recent spends'),
    (icon: Icons.more_horiz_sharp, label: 'more actions'),
  ];

  const _DefaultActionGrid();

  @override
  Widget build(BuildContext context) {
    // Build rows of 2
    final rows = <List<({IconData icon, String label})>>[];
    for (int i = 0; i < _items.length; i += 2) {
      rows.add(_items.sublist(i, (i + 2).clamp(0, _items.length)));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row
              .map(
                (item) => Expanded(
                  child: _ActionChip(icon: item.icon, label: item.label),
                ),
              )
              .toList(),
        );
      }).toList(),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}

class _DefaultDetailsSheet extends StatelessWidget {
  const _DefaultDetailsSheet({
    this.selectedIndex = 0,
    required this.onDismiss,
  });

  final int selectedIndex;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 24),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with drag handle and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 32),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'CARD ${selectedIndex + 1} DETAILS',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Viewing statement details for card #${selectedIndex + 1}'),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onDismiss,
            child: const Text(
              'Dismiss',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
