import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/card_management_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/cta_dispatcher.dart';
import '../../../domain/entities/section_entity.dart';
import '../../../domain/entities/statement_info_data.dart';
import '../cubit/card_management_cubit.dart';
import '../cubit/card_management_state.dart';
import '../widgets/card/card_face_widget.dart';
import '../widgets/card/card_pose.dart';
import '../widgets/card/cred_card_deck_animator.dart';
import '../widgets/detail_panel/card_detail_panel.dart';
import '../widgets/shared/tab_toggle_widget.dart';
import '../widgets/states/empty_state_widget.dart';
import '../widgets/states/error_state_widget.dart';
import '../widgets/states/loading_state_widget.dart';
import '../widgets/templates/template_registry.dart';

/// Top-level screen widget providing the [CardManagementCubit] and hosting the
/// animated deck.
class CardAnimationScreen extends StatelessWidget {
  const CardAnimationScreen({super.key, this.cubit});

  /// Optional test-injected cubit instance. If null, resolves from [sl].
  final CardManagementCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: const _CardAnimationView(),
      );
    }
    return BlocProvider(
      create: (_) => sl<CardManagementCubit>()..load(),
      child: const _CardAnimationView(),
    );
  }
}

class _CardAnimationView extends StatelessWidget {
  const _CardAnimationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F1EC), // AppColors.screenBg
      body: SafeArea(
        child: BlocConsumer<CardManagementCubit, CardManagementState>(
          listener: (context, state) {
            // Present background refresh failure via a floating SnackBar while
            // preserving existing card deck content.
            if (state.status == CardManagementStatus.loaded &&
                state.failure != null) {
              final messenger = ScaffoldMessenger.of(context);
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(state.failure!.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return switch (state.status) {
              CardManagementStatus.initial => const LoadingStateWidget(),
              CardManagementStatus.loading => state.failure != null
                  ? ErrorStateWidget(
                      failure: state.failure!,
                      isLoading: true,
                      onRetry: () => context.read<CardManagementCubit>().load(),
                    )
                  : const LoadingStateWidget(),
              // Pull-to-refresh is enabled on error state using scrollable
              // physics without conflicting with custom deck gesture arenas.
              CardManagementStatus.error => LayoutBuilder(
                  builder: (context, constraints) => RefreshIndicator(
                    onRefresh: () =>
                        context.read<CardManagementCubit>().refresh(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: ErrorStateWidget(
                          failure: state.failure ?? const UnknownFailure(),
                          isLoading: false,
                          onRetry: () =>
                              context.read<CardManagementCubit>().load(),
                        ),
                      ),
                    ),
                  ),
                ),
              CardManagementStatus.loaded => _buildLoaded(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, CardManagementState state) {
    final cubit = context.read<CardManagementCubit>();
    final ctaDispatcher = sl<CtaDispatcher>();

    // ── Bind to unbilled_statement_info_section_v2 dynamically ──────────
    final statementSection =
        state.sections.whereType<StatementInfoSection>().firstOrNull;
    final statementData = statementSection != null
        ? StatementInfoData.fromEntity(statementSection.body)
        : null;

    final registry = TemplateRegistry(
      ctaDispatcher: ctaDispatcher,
      activeToggle: state.activeToggle,
      topBarCenterWidget: TabToggleWidget(
        active: state.activeToggle,
        dueCount: statementData?.dueCount ?? 0,
        totalDueLabel:
            statementData?.title ?? CardManagementConstants.totalDueLabel,
        recentSpendsLabel: statementData?.unbilledTitle ??
            CardManagementConstants.recentSpendsLabel,
        onToggle: (toggle) => cubit.setActiveToggle(toggle),
      ),
    );

    final Widget header = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in state.sections)
          if (section is TopBarSection || section is StatementInfoSection)
            registry.build(context, section),
      ],
    );

    if (state.cards.isEmpty) {
      return Column(
        children: [
          header,
          // Pull-to-refresh is enabled on empty state using scrollable physics
          // without conflicting with custom deck gesture arenas.
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => RefreshIndicator(
                onRefresh: () =>
                    context.read<CardManagementCubit>().refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const EmptyStateWidget(
                      message: 'No cards available',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final List<Widget> cardWidgets = state.cards.map((section) {
      return CardFaceWidget(
        card: section.body,
        pose: CardPose.identity,
        showStatementOverlay: true,
        showPill: true,
        onPayNowTap: () => ctaDispatcher.dispatch(
          context,
          section.body.statement?.cta1,
        ),
      );
    }).toList();

    return CredCardDeckAnimator(
      cardSpacing: 16.0,
      stackPeekHeight: 38.0,
      cards: cardWidgets,
      header: header,
      detailsSheetBuilder: (context, selectedIndex, onClose) {
        if (state.cards.isEmpty) return const SizedBox.shrink();
        final safeIndex = selectedIndex.clamp(0, state.cards.length - 1);
        final cardSection = state.cards[safeIndex];
        return CardDetailPanel(
          card: cardSection.body,
          onClose: onClose,
        );
      },
    );
  }
}
