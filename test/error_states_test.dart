import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/core/error/failures.dart';
import 'package:cred_assignment/domain/entities/section_entity.dart';
import 'package:cred_assignment/domain/repositories/card_management_repository.dart';
import 'package:cred_assignment/domain/usecases/fetch_card_management_usecase.dart';
import 'package:cred_assignment/presentation/card_management/cubit/card_management_cubit.dart';
import 'package:cred_assignment/presentation/card_management/cubit/card_management_state.dart';
import 'package:cred_assignment/presentation/card_management/screen/card_animation_screen.dart';
import 'package:cred_assignment/presentation/card_management/widgets/card/card_face_widget.dart';
import 'package:cred_assignment/presentation/card_management/widgets/states/error_state_widget.dart';

class _FailingRepository implements CardManagementRepository {
  _FailingRepository(this.failure);

  final AppFailure failure;

  @override
  Future<List<SectionEntity>> fetchSections() async {
    throw failure;
  }

  @override
  void cancel() {}
}

class _CancellingRepository implements CardManagementRepository {
  @override
  Future<List<SectionEntity>> fetchSections() async {
    throw const CancelledFailure();
  }

  @override
  void cancel() {}
}

class _DeferredRepository implements CardManagementRepository {
  _DeferredRepository(this.future);

  final Future<List<SectionEntity>> future;

  @override
  Future<List<SectionEntity>> fetchSections() => future;

  @override
  void cancel() {}
}

class _SequentialRepository implements CardManagementRepository {
  int callCount = 0;
  bool firstCancelled = false;

  @override
  Future<List<SectionEntity>> fetchSections() async {
    callCount++;
    if (callCount == 1) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (firstCancelled) {
        throw const CancelledFailure();
      }
      return [];
    } else {
      return [];
    }
  }

  @override
  void cancel() {
    firstCancelled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildScreenWithFailure(AppFailure failure) {
    final useCase = FetchCardManagementUseCase(_FailingRepository(failure));
    final cubit = CardManagementCubit(useCase)..load();

    return MaterialApp(
      home: CardAnimationScreen(cubit: cubit),
    );
  }

  // Protects typed error UI presentation, retry button disablement, and unhandled cancel exceptions.
  group('Error & Offline State Verification (Requirement 8)', () {
    testWidgets('renders NoInternet UI and no card data when offline', (tester) async {
      await tester.pumpWidget(buildScreenWithFailure(const NoInternetFailure()));
      await tester.pumpAndSettle();

      // Verify ErrorStateWidget is rendered
      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('No internet connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Verify NO card data appears
      expect(find.byType(CardFaceWidget), findsNothing);
      expect(find.text('AXIS BANK'), findsNothing);
      expect(find.text('₹50,000.00'), findsNothing);
    });

    testWidgets('renders Timeout UI and no card data on connection timeout', (tester) async {
      await tester.pumpWidget(buildScreenWithFailure(const TimeoutFailure()));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.textContaining('timed out'), findsOneWidget);

      // Verify NO card data appears
      expect(find.byType(CardFaceWidget), findsNothing);
      expect(find.text('AXIS BANK'), findsNothing);
    });

    testWidgets('renders RateLimit (429) UI and no card data when rate limited', (tester) async {
      await tester.pumpWidget(buildScreenWithFailure(const RateLimitFailure()));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
      expect(find.textContaining('API rate limit reached'), findsOneWidget);

      // Verify NO card data appears
      expect(find.byType(CardFaceWidget), findsNothing);
      expect(find.text('AXIS BANK'), findsNothing);
    });

    testWidgets('renders Server Error (500) UI and no card data on server failure', (tester) async {
      await tester.pumpWidget(buildScreenWithFailure(const ServerFailure()));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateWidget), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.textContaining('Server error occurred'), findsOneWidget);

      // Verify NO card data appears
      expect(find.byType(CardFaceWidget), findsNothing);
      expect(find.text('AXIS BANK'), findsNothing);
    });

    testWidgets('disables the Retry button while a request is in flight', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: ErrorStateWidget(
            failure: const ServerFailure(),
            isLoading: true,
            onRetry: () {},
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      // Find the ElevatedButton
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final ElevatedButton button = tester.widget<ElevatedButton>(buttonFinder);
      // Button must be disabled (onPressed is null)
      expect(button.onPressed, isNull);
      // Loading spinner shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    test('cubit emits no error state when request is cancelled via CancelToken', () async {
      final repository = _CancellingRepository();
      final useCase = FetchCardManagementUseCase(repository);
      final cubit = CardManagementCubit(useCase);

      expect(cubit.state.status, CardManagementStatus.initial);

      // Trigger load which throws CancelledFailure
      await cubit.load();

      // State must not transition to error
      expect(cubit.state.status, isNot(CardManagementStatus.error));
      expect(cubit.state.failure, isNull);
    });

    test('two load() calls in quick succession end in success, never stuck on loading', () async {
      final repository = _SequentialRepository();
      final useCase = FetchCardManagementUseCase(repository);
      final cubit = CardManagementCubit(useCase);

      expect(cubit.state.status, CardManagementStatus.initial);

      // Trigger two load calls in quick succession
      final firstLoad = cubit.load();
      final secondLoad = cubit.load();

      await Future.wait([firstLoad, secondLoad]);

      // Must end in loaded, NEVER stuck on loading
      expect(cubit.state.status, CardManagementStatus.loaded);
      expect(repository.callCount, 2);
      expect(repository.firstCancelled, true);
    });

    test('closes the cubit mid-request without throwing StateError on success or error', () async {
      final completer = Completer<List<SectionEntity>>();
      final repository = _DeferredRepository(completer.future);
      final useCase = FetchCardManagementUseCase(repository);
      final cubit = CardManagementCubit(useCase);

      // Start load (waiting on completer)
      final loadFuture = cubit.load();
      expect(cubit.state.status, CardManagementStatus.loading);

      // Close cubit mid-request
      await cubit.close();
      expect(cubit.isClosed, isTrue);

      // Complete future after close: guarded emit must return safely without throwing
      completer.complete([]);
      await expectLater(loadFuture, completes);

      // Test with error completion when closed
      final completerError = Completer<List<SectionEntity>>();
      final cubitError = CardManagementCubit(FetchCardManagementUseCase(_DeferredRepository(completerError.future)));
      final errorLoadFuture = cubitError.load();
      await cubitError.close();

      completerError.completeError(const ServerFailure());
      await expectLater(errorLoadFuture, completes);
    });
  });
}
