import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/section_entity.dart';
import '../../../domain/usecases/fetch_card_management_usecase.dart';
import 'card_management_state.dart';

class CardManagementCubit extends Cubit<CardManagementState> {
  CardManagementCubit(this._fetchUseCase)
      : super(CardManagementState.initial());

  final FetchCardManagementUseCase _fetchUseCase;

  Future<void> load() async {
    if (state.status == CardManagementStatus.loading) return;
    emit(state.copyWith(status: CardManagementStatus.loading, clearError: true));
    try {
      final sections = await _fetchUseCase();
      final cards = sections.whereType<CardInstrumentSection>().toList();
      emit(state.copyWith(
        status: CardManagementStatus.loaded,
        sections: sections,
        cards: cards,
        selectedCardIndex: 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CardManagementStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void selectCard(int index) {
    if (index < 0 || index >= state.cards.length) return;
    emit(state.copyWith(
      selectedCardIndex: index,
      layoutMode: CardLayoutMode.collapsedStack,
      isDetailPanelOpen: false,
    ));
  }

  void setLayoutMode(CardLayoutMode mode) {
    emit(state.copyWith(layoutMode: mode, isDetailPanelOpen: false));
  }

  void openDetail() {
    emit(state.copyWith(
      layoutMode: CardLayoutMode.detail,
      isDetailPanelOpen: false,
    ));
  }

  void openDetailPanel() {
    emit(state.copyWith(isDetailPanelOpen: true));
  }

  void closeDetailPanel() {
    emit(state.copyWith(isDetailPanelOpen: false));
  }

  void setActiveToggle(ActiveToggle toggle) {
    emit(state.copyWith(activeToggle: toggle));
  }

  void collapseStack() {
    emit(state.copyWith(
      layoutMode: CardLayoutMode.collapsedStack,
      isDetailPanelOpen: false,
    ));
  }
}
