import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/section_entity.dart';
import '../../../domain/usecases/fetch_card_management_usecase.dart';
import 'card_management_state.dart';

class CardManagementCubit extends Cubit<CardManagementState> {
  CardManagementCubit(this._fetchUseCase)
      : super(CardManagementState.initial());

  final FetchCardManagementUseCase _fetchUseCase;

  Future<void> load() async {
    _fetchUseCase.cancel();
    emit(state.copyWith(status: CardManagementStatus.loading));
    try {
      final sections = await _fetchUseCase();
      final cards = sections.whereType<CardInstrumentSection>().toList();
      emit(state.copyWith(
        status: CardManagementStatus.loaded,
        sections: sections,
        cards: cards,
        clearError: true,
      ));
    } on CancelledFailure {
      // Request was cancelled; emit NO error state
      return;
    } on AppFailure catch (failure) {
      emit(state.copyWith(
        status: CardManagementStatus.error,
        failure: failure,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CardManagementCubit] Unhandled error: ${e.runtimeType}');
      }
      emit(state.copyWith(
        status: CardManagementStatus.error,
        failure: const UnknownFailure(),
      ));
    }
  }

  void setActiveToggle(ActiveToggle toggle) {
    emit(state.copyWith(activeToggle: toggle));
  }

  @override
  Future<void> close() {
    _fetchUseCase.cancel();
    return super.close();
  }
}
