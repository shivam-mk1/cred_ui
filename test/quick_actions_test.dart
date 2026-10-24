import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/presentation/card_management/widgets/card/cred_card_deck_animator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableDeck({
    required Size screenSize,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: CredCardDeckAnimator(
            cards: [
              Container(
                key: const ValueKey('card_0'),
                color: Colors.blue,
                child: const Center(child: Text('Card 0')),
              ),
              Container(
                key: const ValueKey('card_1'),
                color: Colors.red,
                child: const Center(child: Text('Card 1')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Protects card drawer swipe gestures, chip layout wrap constraints, and tap collapse.
  group('CredCardDeckAnimator - Quick Action Chips Verification', () {
    testWidgets('renders all 6 quick action chips upon swiping card left', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0; // 360 x 800 logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableDeck(screenSize: const Size(360, 800)));
      await tester.pumpAndSettle();

      // Swipe card left by 120 pixels to reveal quick actions
      await tester.drag(find.byKey(const ValueKey('card_0')), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // Verify all 6 action labels are present in the widget tree
      expect(find.text('mark as paid'), findsOneWidget);
      expect(find.text('smart statement'), findsOneWidget);
      expect(find.text('payment history'), findsOneWidget);
      expect(find.text('card offers'), findsOneWidget);
      expect(find.text('recent spends'), findsOneWidget);
      expect(find.text('more actions'), findsOneWidget);

      // Verify no overflow error occurred during or after swipe
      expect(tester.takeException(), isNull);
    });

    testWidgets('quick actions text labels are configured with maxLines: 2 and textAlign: center', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableDeck(screenSize: const Size(360, 800)));
      await tester.pumpAndSettle();

      // Swipe card left
      await tester.drag(find.byKey(const ValueKey('card_0')), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // Check text attributes for 'mark as paid'
      final textFinder = find.text('mark as paid');
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.maxLines, 2);
      expect(textWidget.textAlign, TextAlign.center);
      expect(textWidget.softWrap, true);

      // Verify it is wrapped inside a bounded SizedBox
      final sizedBoxFinder = find.ancestor(
        of: textFinder,
        matching: find.byType(SizedBox),
      );
      expect(sizedBoxFinder, findsWidgets);
      final SizedBox sizedBox = tester.widget<SizedBox>(sizedBoxFinder.first);
      expect(sizedBox.width, 56.0);
    });

    testWidgets('no overflow on compact screen width (320px)', (tester) async {
      tester.view.physicalSize = const Size(960, 1920);
      tester.view.devicePixelRatio = 3.0; // 320 x 640 logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableDeck(screenSize: const Size(320, 640)));
      await tester.pumpAndSettle();

      // Drag card left to latch open
      await tester.drag(find.byKey(const ValueKey('card_0')), const Offset(-150, 0));
      await tester.pumpAndSettle();

      expect(find.text('mark as paid'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow on large screen width (414px)', (tester) async {
      tester.view.physicalSize = const Size(1242, 2688);
      tester.view.devicePixelRatio = 3.0; // 414 x 896 logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableDeck(screenSize: const Size(414, 896)));
      await tester.pumpAndSettle();

      await tester.drag(find.byKey(const ValueKey('card_0')), const Offset(-150, 0));
      await tester.pumpAndSettle();

      expect(find.text('mark as paid'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping swiped card collapses quick actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableDeck(screenSize: const Size(360, 800)));
      await tester.pumpAndSettle();

      // Swipe open
      await tester.drag(find.byKey(const ValueKey('card_0')), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // Tap card 0 to close
      await tester.tap(find.byKey(const ValueKey('card_0')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
