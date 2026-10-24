import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_assignment/domain/entities/card_instrument_entity.dart';
import 'package:cred_assignment/presentation/card_management/widgets/card/card_face_widget.dart';
import 'package:cred_assignment/presentation/card_management/widgets/card/card_pose.dart';
import 'package:cred_assignment/presentation/card_management/widgets/card/cred_card_deck_animator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CardInstrumentEntity sampleCard;

  setUp(() async {
    final file = File('test/fixtures/api_response.json');
    final jsonStr = await file.readAsString();
    final rawMap = jsonDecode(jsonStr) as Map<String, dynamic>;
    final items = rawMap['items'] as List<dynamic>;
    final firstCardItem = items[2] as Map<String, dynamic>;
    final body = (firstCardItem['template_properties'] as Map<String, dynamic>)['body'] as Map<String, dynamic>;
    sampleCard = CardInstrumentEntity.fromMap(body);
  });

  testWidgets('CardFaceWidget renders without bottom overflow on 360px device', (tester) async {
    // Set typical 360px width phone screen
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0; // 360 logical width
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: CardFaceWidget(
                card: sampleCard,
                pose: CardPose.identity,
                showStatementOverlay: true,
                showPill: true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify statement info is rendered
    expect(find.text('₹50,000.00'), findsOneWidget);
    expect(find.text('DUE ON 18 SEP'), findsOneWidget);
    // Verify pay now is rendered
    expect(find.text('Pay now'), findsOneWidget);

    // Verify no RenderFlex overflow error occurred
    expect(tester.takeException(), isNull);
  });

  testWidgets('CredCardDeckAnimator builds cards without overflow on 360px device', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0; // 360 logical width
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cards = List.generate(
      6,
      (i) => CardFaceWidget(
        card: sampleCard,
        pose: CardPose.identity,
        showStatementOverlay: true,
        showPill: true,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: CredCardDeckAnimator(
              cards: cards,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
