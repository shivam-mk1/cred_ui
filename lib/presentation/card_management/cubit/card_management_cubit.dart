import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/section_entity.dart';
import '../../../domain/usecases/fetch_card_management_usecase.dart';
import 'card_management_state.dart';

class CardManagementCubit extends Cubit<CardManagementState> {
  CardManagementCubit(this._fetchUseCase)
      : super(CardManagementState.initial());

  final FetchCardManagementUseCase _fetchUseCase;
  CancelToken? _cancelToken;

  Future<void> load() async {
    if (state.status == CardManagementStatus.loading) return;
    _cancelToken?.cancel();
    final token = CancelToken();
    _cancelToken = token;

    emit(state.copyWith(status: CardManagementStatus.loading));
    try {
      final sections = await _fetchUseCase(cancelToken: token);
      final cards = sections.whereType<CardInstrumentSection>().toList();
      emit(state.copyWith(
        status: CardManagementStatus.loaded,
        sections: sections,
        cards: cards,
        selectedCardIndex: 0,
        clearError: true,
      ));
    } on AppFailure catch (failure) {
      emit(state.copyWith(
        status: CardManagementStatus.error,
        failure: failure,
        errorMessage: failure.message,
      ));
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return;
      }
      emit(state.copyWith(
        status: CardManagementStatus.error,
        failure: UnknownFailure(e.toString()),
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
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
