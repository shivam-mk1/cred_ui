import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/core/utils/cta_dispatcher.dart';
import 'package:cred_assignment/domain/entities/card_instrument_entity.dart';
import 'package:cred_assignment/domain/entities/cta_entity.dart';
import 'package:cred_assignment/presentation/card_management/cubit/card_management_state.dart';
import 'package:cred_assignment/presentation/card_management/widgets/card/cred_card_deck_animator.dart';
import 'package:cred_assignment/presentation/card_management/widgets/detail_panel/card_detail_panel.dart';
import 'package:cred_assignment/presentation/card_management/widgets/shared/tab_toggle_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Unimplemented CTA Feedback (Feature 1)', () {
    testWidgets('tapping an unimplemented CTA shows floating SnackBar with message', (tester) async {
      const card = CardInstrumentEntity(
        text3: '•• 1234',
        provider: 'AXIS BANK',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CardDetailPanel(card: card),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "mark as paid" quick action in detail panel
      final markAsPaidFinder = find.text('mark as paid');
      expect(markAsPaidFinder, findsOneWidget);
      await tester.tap(markAsPaidFinder);
      await tester.pump();

      // Verify SnackBar appears with floating behavior and non-success copy
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Mark as paid is not available in this demo'),
        findsOneWidget,
      );

      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.behavior, SnackBarBehavior.floating);
    });

    testWidgets('tapping a quick-action chip shows floating SnackBar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0; // 360 x 800 logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(size: Size(360, 800)),
              child: CredCardDeckAnimator(
                cards: [
                  Container(
                    key: const ValueKey('card_0'),
                    color: Colors.blue,
                    height: 200,
                  ),
                  Container(
                    key: const ValueKey('card_1'),
                    color: Colors.red,
                    height: 200,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Swipe card 0 left by 150px to reveal quick actions and latch open
      await tester.drag(find.byKey(const ValueKey('card_0')), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // Tap "smart statement" chip
      final smartStatementFinder = find.text('smart statement');
      expect(smartStatementFinder, findsOneWidget);
      await tester.tap(smartStatementFinder);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Smart statement is not available in this demo'),
        findsOneWidget,
      );
    });

    testWidgets('tapping an unimplemented CtaEntity shows fallback floating SnackBar', (tester) async {
      const dispatcher = CtaDispatcherImpl();
      const deeplinkCta = CtaEntity(
        type: CtaType.deeplink,
        title: 'Pay bill',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => dispatcher.dispatch(context, deeplinkCta),
                child: const Text('Trigger CTA'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trigger CTA'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Pay bill is not available in this demo'),
        findsOneWidget,
      );
    });

    testWidgets('tapping twice quickly shows only one SnackBar at a time', (tester) async {
      const card = CardInstrumentEntity(
        text3: '•• 1234',
        provider: 'AXIS BANK',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CardDetailPanel(card: card),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final markAsPaidFinder = find.text('mark as paid');
      final paymentHistoryFinder = find.text('payment history');

      // Tap mark as paid, then immediately tap payment history without waiting
      // for dismiss.
      await tester.tap(markAsPaidFinder);
      await tester.pump();
      await tester.tap(paymentHistoryFinder);
      await tester.pump();

      // Only one SnackBar should be currently active
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Payment history is not available in this demo'),
        findsOneWidget,
      );
      expect(
        find.text('Mark as paid is not available in this demo'),
        findsNothing,
      );
    });

    testWidgets('tapping an implemented control shows NO SnackBar', (tester) async {
      var activeToggle = ActiveToggle.totalDue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => TabToggleWidget(
                active: activeToggle,
                dueCount: 1,
                totalDueLabel: 'TOTAL DUE',
                recentSpendsLabel: 'RECENT SPENDS',
                onToggle: (toggle) => setState(() => activeToggle = toggle),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap implemented toggle button
      await tester.tap(find.text('RECENT SPENDS'));
      await tester.pumpAndSettle();

      // Verify toggle switched and NO SnackBar was presented
      expect(activeToggle, ActiveToggle.recentSpends);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('tapping implemented info dialog CTA opens dialog and shows NO SnackBar', (tester) async {
      const dispatcher = CtaDispatcherImpl();
      const flowCta = CtaEntity(
        type: CtaType.flow,
        flow: FlowEntity(type: 'unbilled_statement_info_dialog'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => dispatcher.dispatch(context, flowCta),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Statement Info'), findsOneWidget);

      // No SnackBar should be displayed
      expect(find.byType(SnackBar), findsNothing);

      // Dismiss dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
