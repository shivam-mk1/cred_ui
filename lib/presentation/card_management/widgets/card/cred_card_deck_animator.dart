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

  const CredCardDeckAnimator({
    super.key,
    required this.cards,
    this.cardHeight,
    this.cardSpacing = 16.0,
    this.stackPeekHeight = 38.0,
    this.header,
    this.quickActions,
    this.detailsSheet,
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

    return Column(
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
                          final double tExpand = _expandDetailsAnimation.value;

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
                      _buildModalSheet(size),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(double cardBodyHeight) {
    final double revealProgress =
        (_horizontalDragX.abs() / kMaxLeftSlide.abs()).clamp(0.0, 1.0);

    return Positioned(
      top: 10,
      right: 20,
      width: 105,
      height: cardBodyHeight,
      child: IgnorePointer(
        ignoring: !_isLatchedOpen,
        child: Opacity(
          opacity: revealProgress,
          child: Transform.scale(
            scale: 0.8 + (0.2 * revealProgress),
            alignment: Alignment.centerRight,
            child: widget.quickActions ??
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDefaultActionChip(
                        Icons.check_circle_outline, 'Mark paid'),
                    _buildDefaultActionChip(Icons.receipt_long, 'Statement'),
                    _buildDefaultActionChip(Icons.history, 'History'),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultActionChip(IconData icon, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 36,
          height: 36,
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
      ],
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

    if (count == 0) return widgets;
    final double stackPeekBase = viewportHeight - 110.0;
    for (int i = count - 1; i >= 0; i--) {
      double deckY;
      double deckScale;

      if (i == 0) {
        deckY = 0.0;
        deckScale = 1.0;
      } else {
        final int rank = i - 1;
        deckY = stackPeekBase + (rank * 10.0).clamp(0.0, 30.0);
        deckScale = 1.0 - (rank * 0.025).clamp(0.0, 0.08);
      }

      final double listY = i * (effectiveCardHeight + widget.cardSpacing);
      const double listScale = 1.0;

      final double interpolatedY = lerpDouble(deckY, listY, tDeck)!;
      final double interpolatedScale = lerpDouble(deckScale, listScale, tDeck)!;
      double currentY = interpolatedY - (tDeck == 1.0 ? _scrollOffset : 0.0);
      if (tExpand > 0) {
        if (i == _selectedCardIndex) {
          currentY = currentY - (currentY * tExpand);
        } else {
          // All other cards exit downward
          currentY += (viewportHeight * 0.5) * tExpand;
        }
      }

      Matrix4 transformMatrix = Matrix4.identity();
      if (i == 0 && tDeck < 0.5 && tExpand == 0) {
        final double dragFraction =
            (_horizontalDragX.abs() / kMaxLeftSlide.abs()).clamp(0.0, 1.0);
        final double angleY = -dragFraction * (math.pi / 10.0);

        transformMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..translate(_horizontalDragX, 0.0, 0.0)
          ..rotateY(angleY);
      }

      final bool isActiveCard = i == 0;
      final bool canSwipeHorizontal =
          isActiveCard && tDeck < 0.5 && tExpand == 0;

      widgets.add(
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: Transform.translate(
            offset: Offset(0, currentY),
            child: Transform.scale(
              scale: interpolatedScale,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: canSwipeHorizontal
                    ? (details) {
                        setState(() {
                          _horizontalDragX =
                              (_horizontalDragX + details.delta.dx)
                                  .clamp(kMaxLeftSlide, 0.0);
                        });
                      }
                    : null,
                onHorizontalDragEnd: canSwipeHorizontal
                    ? (details) {
                        final double v = details.primaryVelocity ?? 0.0;
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
                  } else if (tExpand == 0 &&
                      !_expandDetailsController.isAnimating) {
                    setState(() => _selectedCardIndex = i);
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
      );
    }

    return widgets;
  }

  Widget _buildModalSheet(Size size) {
    return AnimatedBuilder(
      animation: _expandDetailsAnimation,
      builder: (context, child) {
        final double progress = _expandDetailsAnimation.value;
        if (progress == 0 && !_expandDetailsController.isAnimating) {
          return const SizedBox.shrink();
        }

        final double sheetHeight = size.height * 0.60;

        return Stack(
          children: [
            GestureDetector(
              onTap: () => _expandDetailsController.reverse(),
              child: Container(
                color: Colors.black
                    .withOpacity((0.45 * progress).clamp(0.0, 0.45)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: sheetHeight,
              child: Transform.translate(
                offset: Offset(0, (1.0 - progress) * sheetHeight),
                child: widget.detailsSheet ??
                    _DefaultDetailsSheet(
                      onDismiss: () => _expandDetailsController.reverse(),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DefaultDetailsSheet extends StatelessWidget {
  const _DefaultDetailsSheet({required this.onDismiss});

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
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'STATEMENT DETAILS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('₹50,000.00 bill generated on 28 Aug'),
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
