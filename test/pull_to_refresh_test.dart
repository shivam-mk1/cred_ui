import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/core/di/injection.dart';
import 'package:cred_assignment/core/error/failures.dart';
import 'package:cred_assignment/core/utils/cta_dispatcher.dart';
import 'package:cred_assignment/domain/entities/card_instrument_entity.dart';
import 'package:cred_assignment/domain/entities/section_entity.dart';
import 'package:cred_assignment/domain/repositories/card_management_repository.dart';
import 'package:cred_assignment/domain/usecases/fetch_card_management_usecase.dart';
import 'package:cred_assignment/presentation/card_management/cubit/card_management_cubit.dart';
import 'package:cred_assignment/presentation/card_management/cubit/card_management_state.dart';
import 'package:cred_assignment/presentation/card_management/screen/card_animation_screen.dart';
import 'package:cred_assignment/presentation/card_management/widgets/card/card_face_widget.dart';
import 'package:cred_assignment/presentation/card_management/widgets/states/empty_state_widget.dart';
import 'package:cred_assignment/presentation/card_management/widgets/states/error_state_widget.dart';
import 'package:cred_assignment/presentation/card_management/widgets/states/loading_state_widget.dart';

class _FakeRepository implements CardManagementRepository {
  _FakeRepository({this.sectionsToReturn});

  List<SectionEntity>? sectionsToReturn;
  AppFailure? errorToThrow;
  Completer<List<SectionEntity>>? completer;
  int callCount = 0;

  @override
  Future<List<SectionEntity>> fetchSections() async {
    callCount++;
    if (completer != null) {
      return completer!.future;
    }
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return sectionsToReturn ?? [];
  }

  @override
  void cancel() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    if (!sl.isRegistered<CtaDispatcher>()) {
      sl.registerLazySingleton<CtaDispatcher>(CtaDispatcherImpl.new);
    }
  });

  final initialCardSection = CardInstrumentSection(
    externalId: 'card_1',
    body: const CardInstrumentEntity(
      text3: '•• 1111',
      provider: 'FIRST BANK',
    ),
  );

  final updatedCardSection = CardInstrumentSection(
    externalId: 'card_2',
    body: const CardInstrumentEntity(
      text3: '•• 2222',
      provider: 'SECOND BANK',
    ),
  );

  group('Pull-to-refresh (Feature 2)', () {
    testWidgets('refresh keeps cards visible while loading', (tester) async {
      final completer = Completer<List<SectionEntity>>();
      final repo = _FakeRepository()..completer = completer;
      final cubit = CardManagementCubit(FetchCardManagementUseCase(repo));

      // Seed loaded state with an existing card
      cubit.emit(CardManagementState(
        status: CardManagementStatus.loaded,
        sections: [initialCardSection],
        cards: [initialCardSection],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: CardAnimationScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      // Card is rendered
      expect(find.byType(CardFaceWidget), findsOneWidget);
      expect(find.text('•• 1111'), findsOneWidget);

      // Trigger background refresh
      final refreshFuture = cubit.refresh();
      await tester.pump();

      // Cards remain visible during refresh; full-screen loading spinner
      // is bypassed.
      expect(cubit.state.status, CardManagementStatus.loaded);
      expect(cubit.state.isRefreshing, isTrue);
      expect(find.byType(CardFaceWidget), findsOneWidget);
      expect(find.byType(LoadingStateWidget), findsNothing);

      // Complete refresh
      completer.complete([initialCardSection]);
      await refreshFuture;
      await tester.pumpAndSettle();

      expect(cubit.state.isRefreshing, isFalse);
    });

    testWidgets('success replaces data', (tester) async {
      final completer = Completer<List<SectionEntity>>();
      final repo = _FakeRepository()..completer = completer;
      final cubit = CardManagementCubit(FetchCardManagementUseCase(repo));

      cubit.emit(CardManagementState(
        status: CardManagementStatus.loaded,
        sections: [initialCardSection],
        cards: [initialCardSection],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: CardAnimationScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('•• 1111'), findsOneWidget);

      // Trigger refresh and complete with new data
      final refreshFuture = cubit.refresh();
      completer.complete([updatedCardSection]);
      await refreshFuture;
      await tester.pumpAndSettle();

      // State is updated with new card
      expect(cubit.state.status, CardManagementStatus.loaded);
      expect(cubit.state.isRefreshing, isFalse);
      expect(cubit.state.cards.first.body.text3, '•• 2222');
      expect(find.text('•• 2222'), findsOneWidget);
    });

    testWidgets('failure keeps old cards and shows floating SnackBar', (tester) async {
      final completer = Completer<List<SectionEntity>>();
      final repo = _FakeRepository()..completer = completer;
      final cubit = CardManagementCubit(FetchCardManagementUseCase(repo));

      cubit.emit(CardManagementState(
        status: CardManagementStatus.loaded,
        sections: [initialCardSection],
        cards: [initialCardSection],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: CardAnimationScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('•• 1111'), findsOneWidget);

      // Trigger refresh and fail with ServerFailure
      final refreshFuture = cubit.refresh();
      await tester.pump();

      completer.completeError(const ServerFailure('Service temporarily unavailable'));
      await refreshFuture;
      await tester.pump();

      // Old cards remain rendered
      expect(cubit.state.status, CardManagementStatus.loaded);
      expect(cubit.state.cards, [initialCardSection]);
      expect(find.byType(CardFaceWidget), findsOneWidget);
      expect(find.text('•• 1111'), findsOneWidget);

      // Error SnackBar is presented
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Service temporarily unavailable'), findsOneWidget);
    });

    test('a second refresh during an in-flight one is ignored', () async {
      final completer = Completer<List<SectionEntity>>();
      final repo = _FakeRepository()..completer = completer;
      final cubit = CardManagementCubit(FetchCardManagementUseCase(repo));

      cubit.emit(CardManagementState(
        status: CardManagementStatus.loaded,
        sections: [initialCardSection],
        cards: [initialCardSection],
      ));

      // First refresh in-flight
      final firstFuture = cubit.refresh();
      expect(repo.callCount, 1);
      expect(cubit.state.isRefreshing, isTrue);

      // Second refresh while first is in-flight: must be ignored by
      // rate-limit guard.
      final secondFuture = cubit.refresh();
      expect(repo.callCount, 1);

      // Complete the first request
      completer.complete([initialCardSection]);
      await firstFuture;
      await secondFuture;

      expect(cubit.state.isRefreshing, isFalse);
      expect(repo.callCount, 1);
    });

    testWidgets('pull-to-refresh on empty state triggers a reload', (tester) async {
      final repo = _FakeRepository(sectionsToReturn: [initialCardSection]);
      final cubit = CardManagementCubit(FetchCardManagementUseCase(repo));

      cubit.emit(const CardManagementState(
        status: CardManagementStatus.loaded,
        sections: [],
        cards: [],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: CardAnimationScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(repo.callCount, 0);

      // Pull down to trigger RefreshIndicator
      await tester.drag(find.byType(EmptyStateWidget), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Verify reload was triggered and cards loaded
      expect(repo.callCount, 1);
      expect(cubit.state.cards, [initialCardSection]);
      expect(find.byType(CardFaceWidget), findsOneWidget);
    });

    testWidgets('pull-to-refresh on error state triggers a reload', (tester) async {
      final repo = _FakeRepository(sectionsToReturn: [initialCardSection]);
      final cubit = CardManagementCubit(FetchCardManagementUseCase(repo));

      cubit.emit(const CardManagementState(
        status: CardManagementStatus.error,
        failure: NoInternetFailure(),
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: CardAnimationScreen(cubit: cubit),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(repo.callCount, 0);

      // Pull down to trigger RefreshIndicator
      await tester.drag(find.byType(ErrorStateWidget), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Verify reload was triggered and error state resolved
      expect(repo.callCount, 1);
      expect(cubit.state.status, CardManagementStatus.loaded);
      expect(cubit.state.cards, [initialCardSection]);
      expect(find.byType(CardFaceWidget), findsOneWidget);
    });
  });
}
