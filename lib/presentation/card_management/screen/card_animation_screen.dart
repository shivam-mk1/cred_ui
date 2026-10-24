import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/cta_dispatcher.dart';
import '../../../../domain/entities/section_entity.dart';
import '../../../../domain/entities/statement_info_data.dart';
import '../cubit/card_management_cubit.dart';
import '../cubit/card_management_state.dart';
import '../widgets/card/card_face_widget.dart';
import '../widgets/card/card_pose.dart';
import '../widgets/card/cred_card_deck_animator.dart';
import '../widgets/detail_panel/card_detail_panel.dart';
import '../widgets/shared/tab_toggle_widget.dart';
import '../widgets/states/error_state_widget.dart';
import '../widgets/states/loading_state_widget.dart';
import '../widgets/templates/template_registry.dart';

class CardAnimationScreen extends StatelessWidget {
  const CardAnimationScreen({super.key, this.cubit});

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
        child: BlocBuilder<CardManagementCubit, CardManagementState>(
          builder: (context, state) {
            return switch (state.status) {
              CardManagementStatus.initial => const LoadingStateWidget(),
              CardManagementStatus.loading => state.failure != null
                  ? ErrorStateWidget(
                      message: state.failure?.message ??
                          state.errorMessage ??
                          'Failed to load card data',
                      failure: state.failure,
                      isLoading: true,
                      onRetry: () => context.read<CardManagementCubit>().load(),
                    )
                  : const LoadingStateWidget(),
              CardManagementStatus.error => ErrorStateWidget(
                  message: state.failure?.message ??
                      state.errorMessage ??
                      'Failed to load card data',
                  failure: state.failure,
                  isLoading: false,
                  onRetry: () => context.read<CardManagementCubit>().load(),
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

    // ── Bind to unbilled_statement_info_section_v2 dynamically ────────────────
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
        totalDueLabel: statementData?.title ?? 'TOTAL DUE',
        recentSpendsLabel: statementData?.unbilledTitle ?? 'RECENT SPENDS',
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

    final List<Widget> cardWidgets = state.cards.map((section) {
      return CardFaceWidget(
        card: section.body,
        pose: CardPose.identity,
        showStatementOverlay: true,
        showPill: true,
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
