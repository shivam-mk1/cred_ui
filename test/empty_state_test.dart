import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/core/di/injection.dart';
import 'package:cred_assignment/core/utils/cta_dispatcher.dart';
import 'package:cred_assignment/domain/entities/section_entity.dart';
import 'package:cred_assignment/domain/entities/top_bar_entity.dart';
import 'package:cred_assignment/domain/repositories/card_management_repository.dart';
import 'package:cred_assignment/domain/usecases/fetch_card_management_usecase.dart';
import 'package:cred_assignment/presentation/card_management/cubit/card_management_cubit.dart';
import 'package:cred_assignment/presentation/card_management/screen/card_animation_screen.dart';
import 'package:cred_assignment/presentation/card_management/widgets/card/card_face_widget.dart';
import 'package:cred_assignment/presentation/card_management/widgets/states/empty_state_widget.dart';

class _EmptyCardsRepository implements CardManagementRepository {
  @override
  Future<List<SectionEntity>> fetchSections() async {
    return const [
      TopBarSection(
        body: TopBarEntity(),
      ),
    ];
  }

  @override
  void cancel() {}
}

void main() {
  setUp(() {
    if (!sl.isRegistered<CtaDispatcher>()) {
      sl.registerLazySingleton<CtaDispatcher>(CtaDispatcherImpl.new);
    }
  });

  group('Empty State Verification', () {
    testWidgets('EmptyStateWidget renders message and empty icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(message: 'No cards available'),
          ),
        ),
      );

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No cards available'), findsOneWidget);
      expect(find.byIcon(Icons.credit_card_off_rounded), findsOneWidget);
    });

    testWidgets('CardAnimationScreen renders EmptyStateWidget when API returns zero cards', (tester) async {
      final repository = _EmptyCardsRepository();
      final useCase = FetchCardManagementUseCase(repository);
      final cubit = CardManagementCubit(useCase);
      await cubit.load();

      await tester.pumpWidget(
        MaterialApp(
          home: CardAnimationScreen(cubit: cubit),
        ),
      );

      await tester.pumpAndSettle();

      // Verify EmptyStateWidget is displayed
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No cards available'), findsOneWidget);

      // Verify no CardFaceWidget is rendered
      expect(find.byType(CardFaceWidget), findsNothing);
    });
  });
}
