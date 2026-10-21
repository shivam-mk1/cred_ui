import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/cta_dispatcher.dart';
import '../../../../domain/entities/section_entity.dart';
import '../cubit/card_management_cubit.dart';
import '../cubit/card_management_state.dart';
import '../widgets/shared/tab_toggle_widget.dart';
import '../widgets/states/error_state_widget.dart';
import '../widgets/states/loading_state_widget.dart';
import '../widgets/templates/template_registry.dart';

/// Root Card Management screen.

class CardManagementScreen extends StatelessWidget {
  const CardManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CardManagementCubit>()..load(),
      child: const _CardManagementView(),
    );
  }
}

class _CardManagementView extends StatelessWidget {
  const _CardManagementView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<CardManagementCubit, CardManagementState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.errorMessage != current.errorMessage,
          builder: (context, state) {
            return switch (state.status) {
              CardManagementStatus.initial ||
              CardManagementStatus.loading =>
                const LoadingStateWidget(),
              CardManagementStatus.error => ErrorStateWidget(
                  message: state.errorMessage ?? 'Failed to load card data',
                  onRetry: () => context.read<CardManagementCubit>().load(),
                ),
              CardManagementStatus.loaded => const _LoadedContent(),
            };
          },
        ),
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  const _LoadedContent();

  @override
  Widget build(BuildContext context) {
    final ctaDispatcher = sl<CtaDispatcher>();

    return BlocBuilder<CardManagementCubit, CardManagementState>(
      buildWhen: (previous, current) =>
          previous.sections != current.sections ||
          previous.activeToggle != current.activeToggle ||
          previous.layoutMode != current.layoutMode ||
          previous.selectedCardIndex != current.selectedCardIndex ||
          previous.isDetailPanelOpen != current.isDetailPanelOpen,
      builder: (context, state) {
        final cubit = context.read<CardManagementCubit>();
        // final cards = state.cards.map((e) => e.body).toList();

        final registry = TemplateRegistry(
          ctaDispatcher: ctaDispatcher,
          activeToggle: state.activeToggle,
          topBarCenterWidget: TabToggleWidget(
            active: state.activeToggle,
            dueCount: 1,
            onToggle: (toggle) => cubit.setActiveToggle(toggle),
          ),
        );

        return Stack(
          children: [
            // ── Scrollable body ─────────────────────────────────────────────
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 1. Top bar (cm_top_bar) ─────────────────────────────
                  for (final section in state.sections)
                    if (section is TopBarSection)
                      registry.build(context, section),

                  // ── 2. Statement info ───────────────────────────────────
                  for (final section in state.sections)
                    if (section is StatementInfoSection)
                      registry.build(context, section),
                  // ── 3. Card area ────────────────────────────────────────
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
