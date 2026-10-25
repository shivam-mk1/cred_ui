import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/section_entity.dart';
import '../../../domain/usecases/fetch_card_management_usecase.dart';
import 'card_management_state.dart';

/// Manages state for the Card Management feature.
///
/// State transitions:
/// - Initial: [CardManagementStatus.initial]
/// - Loading: [CardManagementStatus.loading] on initial fetch or user retry
/// - Loaded: [CardManagementStatus.loaded] with parsed sections and cards
/// - Error: [CardManagementStatus.error] containing a typed [AppFailure]
class CardManagementCubit extends Cubit<CardManagementState> {
  CardManagementCubit(this._fetchUseCase)
      : super(CardManagementState.initial());

  final FetchCardManagementUseCase _fetchUseCase;

  /// Loads card management sections from the remote repository.
  ///
  /// Cancels any active in-flight request before triggering a fresh load to
  /// prevent race conditions from rapid retry button taps. Emits
  /// [CardManagementStatus.loading], followed by [CardManagementStatus.loaded]
  /// on success or [CardManagementStatus.error] on failure.
  Future<void> load() async {
    // Abort prior in-flight request to prevent race conditions from rapid
    // retries.
    _fetchUseCase.cancel();
    emit(state.copyWith(status: CardManagementStatus.loading));
    try {
      final sections = await _fetchUseCase();
      // Guard against emitting state if the cubit closed while the future was
      // resolving.
      if (isClosed) return;
      final cards = sections.whereType<CardInstrumentSection>().toList();
      emit(state.copyWith(
        status: CardManagementStatus.loaded,
        sections: sections,
        cards: cards,
        clearError: true,
      ));
    } on CancelledFailure {
      // An intentional abort (from a superseded retry or screen disposal) must
      // not emit an error state; leaving state untouched avoids UI flicker.
      return;
    } on AppFailure catch (failure) {
      if (isClosed) return;
      emit(state.copyWith(
        status: CardManagementStatus.error,
        failure: failure,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CardManagementCubit] Unhandled error: ${e.runtimeType}');
      }
      if (isClosed) return;
      emit(state.copyWith(
        status: CardManagementStatus.error,
        failure: const UnknownFailure(),
      ));
    }
  }

  /// Refreshes card management sections in the background.
  ///
  /// Bypasses the full-screen [CardManagementStatus.loading] state so that
  /// existing cards remain visible during pull-to-refresh without UI flicker.
  ///
  /// Ignored if a request is already in-flight to prevent exhausting the API's
  /// strict 5-request rate limit.
  Future<void> refresh() async {
    // Rate-limit guard: ignore duplicate triggers while a request is in flight.
    if (state.status == CardManagementStatus.loading || state.isRefreshing) {
      return;
    }

    // When no data has been loaded yet (empty or error states), delegate to
    // load() so the full initial loading flow is triggered.
    if (state.status != CardManagementStatus.loaded) {
      return load();
    }

    emit(state.copyWith(isRefreshing: true, clearError: true));
    try {
      final sections = await _fetchUseCase();
      // Guard against emitting state if the cubit closed while resolving.
      if (isClosed) return;
      final cards = sections.whereType<CardInstrumentSection>().toList();
      emit(state.copyWith(
        status: CardManagementStatus.loaded,
        sections: sections,
        cards: cards,
        isRefreshing: false,
        clearError: true,
      ));
    } on CancelledFailure {
      // An intentional abort; reset refreshing flag without emitting error.
      if (isClosed) return;
      emit(state.copyWith(isRefreshing: false));
      return;
    } on AppFailure catch (failure) {
      if (isClosed) return;
      // Retain existing sections and cards while attaching the failure so the
      // presentation layer can display an error SnackBar.
      emit(state.copyWith(
        isRefreshing: false,
        failure: failure,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[CardManagementCubit] Unhandled refresh error: ${e.runtimeType}',
        );
      }
      if (isClosed) return;
      emit(state.copyWith(
        isRefreshing: false,
        failure: const UnknownFailure(),
      ));
    }
  }

  /// Sets the currently active segmented tab toggle ([ActiveToggle.totalDue]
  /// or [ActiveToggle.recentSpends]).
  void setActiveToggle(ActiveToggle toggle) {
    emit(state.copyWith(activeToggle: toggle));
  }

  @override
  Future<void> close() {
    // Abort active network requests when widget tree unmounts the cubit.
    _fetchUseCase.cancel();
    return super.close();
  }
}
