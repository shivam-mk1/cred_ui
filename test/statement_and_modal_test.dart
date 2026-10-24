import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/domain/entities/statement_info_data.dart';
import 'package:cred_assignment/domain/entities/asset_entity.dart';
import 'package:cred_assignment/domain/entities/card_instrument_entity.dart';
import 'package:cred_assignment/presentation/card_management/widgets/shared/tab_toggle_widget.dart';
import 'package:cred_assignment/presentation/card_management/widgets/detail_panel/card_detail_panel.dart';
import 'package:cred_assignment/presentation/card_management/widgets/card/cred_card_deck_animator.dart';
import 'package:cred_assignment/presentation/card_management/cubit/card_management_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StatementInfoData JSON parsing', () {
    test('parses StatementInfoData accurately from assessment api_response.json', () async {
      final file = File('test/fixtures/api_response.json');
      final jsonStr = await file.readAsString();
      final rawMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final items = rawMap['items'] as List<dynamic>;

      final statementJson = items.firstWhere(
        (e) => e['template_name'] == 'unbilled_statement_info_section_v2',
      ) as Map<String, dynamic>;

      final data = StatementInfoData.fromJson(statementJson);

      expect(data.title, 'TOTAL DUE');
      expect(data.dueCount, 1);
      expect(data.subtitle, 'STATEMENT DUE FOR 1 CARD');
      expect(data.amount, '₹50,000.00');
      expect(data.ctaTitle, 'Pay bill');
      expect(data.unbilledTitle, 'RECENT SPENDS');
    });

    test('StatementInfoData handles empty / null fallback gracefully', () {
      final data = StatementInfoData.fromJson({});
      expect(data.title, 'TOTAL DUE');
      expect(data.dueCount, 0);
      expect(data.subtitle, '');
      expect(data.amount, '');
      expect(data.ctaTitle, 'Pay bill');
      expect(data.unbilledTitle, 'RECENT SPENDS');
    });
  });

  group('TabToggleWidget due count badge', () {
    testWidgets('shows badge when dueCount > 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabToggleWidget(
              active: ActiveToggle.totalDue,
              dueCount: 2,
              totalDueLabel: 'TOTAL DUE',
              recentSpendsLabel: 'RECENT SPENDS',
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('TOTAL DUE'), findsOneWidget);
      expect(find.text('RECENT SPENDS'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('hides badge when dueCount is 0 or null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabToggleWidget(
              active: ActiveToggle.totalDue,
              dueCount: 0,
              totalDueLabel: 'TOTAL DUE',
              recentSpendsLabel: 'RECENT SPENDS',
              onToggle: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('TOTAL DUE'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });

  group('Dynamic CardDetailPanel', () {
    test('extracts bankName dynamically from asset3 URL and fallbacks', () {
      const cardAxis = CardInstrumentEntity(
        asset3: AssetEntity(
          url: 'https://d1sofudel0ufia.cloudfront.net/mesh/card-art/AXIS%20BANK%20MINI%20CARD.png',
        ),
        text3: '•• 1234',
      );
      const cardYes = CardInstrumentEntity(
        asset3: AssetEntity(
          url: 'https://d1sofudel0ufia.cloudfront.net/mesh/card-art/YES%20BANK%20MINI%20CARD.png',
        ),
        text3: '•• 7722',
      );
      const cardFallback = CardInstrumentEntity(
        provider: 'RUPAY',
        text3: '•• 9999',
      );

      expect(cardAxis.bankName, 'AXIS BANK');
      expect(cardYes.bankName, 'YES BANK');
      expect(cardFallback.bankName, 'RUPAY');
    });

    testWidgets('displays distinct card data for different cards', (tester) async {
      const axisCard = CardInstrumentEntity(
        text3: '•• 1234',
        provider: 'AXIS BANK',
        statement: CardStatementEntity(
          text1: '₹50,000.00',
          text2: 'DUE ON 18 SEP',
        ),
      );
      const yesCard = CardInstrumentEntity(
        text3: '•• 7722',
        provider: 'YES BANK',
      );

      // Test Axis Card Detail Panel
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CardDetailPanel(card: axisCard),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('AXIS BANK'), findsWidgets);
      expect(find.textContaining('•• 1234'), findsWidgets);
      expect(find.textContaining('₹50,000.00'), findsWidgets);

      // Test Yes Bank Card Detail Panel
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CardDetailPanel(card: yesCard),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('YES BANK'), findsWidgets);
      expect(find.textContaining('•• 7722'), findsWidgets);
      expect(find.text('no bill due • all payments completed'), findsOneWidget);
    });

    testWidgets('tapping close button calls onClose callback', (tester) async {
      bool closed = false;
      const card = CardInstrumentEntity(
        text3: '•• 1234',
        provider: 'AXIS BANK',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardDetailPanel(
              card: card,
              onClose: () => closed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      final closeButton = find.byIcon(Icons.close_rounded);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pump();

      expect(closed, true);
    });

    testWidgets('CardDetailPanel renders without overflow on compact 360x600 device', (tester) async {
      tester.view.physicalSize = const Size(1080, 1800);
      tester.view.devicePixelRatio = 3.0; // 360 x 600 logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const card = CardInstrumentEntity(
        text3: '•• 1234',
        provider: 'AXIS BANK',
        statement: CardStatementEntity(
          text1: '₹50,000.00',
          text2: 'DUE ON 18 SEP',
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardDetailPanel(card: card),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('CredCardDeckAnimator detailsSheetBuilder', () {
    testWidgets('calls detailsSheetBuilder with tapped card index and can close via back button', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CredCardDeckAnimator(
              cardHeight: 200,
              cards: [
                Container(key: const ValueKey('card_0'), height: 200, color: Colors.blue),
                Container(key: const ValueKey('card_1'), height: 200, color: Colors.green),
              ],
              detailsSheetBuilder: (context, selectedIndex, onClose) {
                tappedIndex = selectedIndex;
                return Container(
                  key: ValueKey('sheet_$selectedIndex'),
                  child: Column(
                    children: [
                      Text('Sheet for card $selectedIndex'),
                      IconButton(
                        key: const ValueKey('close_btn'),
                        icon: const Icon(Icons.close),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap card 0 to open detail
      await tester.tap(find.byKey(const ValueKey('card_0')));
      await tester.pumpAndSettle();

      expect(tappedIndex, 0);
      expect(find.text('Sheet for card 0'), findsOneWidget);

      // Simulate phone back button press via handlePopRoute
      final popHandled = await tester.binding.handlePopRoute();
      expect(popHandled, true); // PopScope intercepted the back button

      await tester.pumpAndSettle();

      // Detail view should now be closed
      expect(find.text('Sheet for card 0'), findsNothing);
    });
  });
}
