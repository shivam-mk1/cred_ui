import 'package:dio/dio.dart';
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
        clearError: true,
      ));
    } on AppFailure catch (failure) {
      emit(state.copyWith(
        status: CardManagementStatus.error,
        failure: failure,
        errorMessage: failure.message,
      ));
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || e.type == DioExceptionType.cancel) {
        return;
      }
      if (kDebugMode) {
        debugPrint('[CardManagementCubit] Unhandled DioException: ${e.type}');
      }
      emit(state.copyWith(
        status: CardManagementStatus.error,
        failure: const UnknownFailure(),
        errorMessage: const UnknownFailure().message,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CardManagementCubit] Unhandled error: ${e.runtimeType}');
      }
      emit(state.copyWith(
        status: CardManagementStatus.error,
        failure: const UnknownFailure(),
        errorMessage: const UnknownFailure().message,
      ));
    }
  }

  void setActiveToggle(ActiveToggle toggle) {
    emit(state.copyWith(activeToggle: toggle));
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}
