import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/chapter2_seesaw_puzzle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Mock the audioplayers method channel to avoid errors in tests
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  testWidgets('Seesaw Puzzle drag and drop simulation test', (WidgetTester tester) async {
    // Set screen size to a standard landscape tablet layout (1280x800) to ensure plenty of vertical space
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Build the SeesawPuzzleScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: SeesawPuzzleScreen(completedRouteName: '/success'),
      ),
    );
    await tester.pumpAndSettle();

    // Verify screen title is displayed correctly
    expect(find.text('문제: 시소가 균형을 이루도록 도형을 움직여 보세요'), findsOneWidget);

    // Verify initial torques
    expect(find.text('왼쪽 기울기: 0'), findsOneWidget);
    expect(find.text('오른쪽 기울기: 0'), findsOneWidget);

    // Find all Draggable card widgets using runtimeType matching
    final draggablesFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().startsWith('Draggable'));
    expect(draggablesFinder, findsWidgets);

    // Find a target cell. In our grid, row 1 left cells are DragTargets.
    // Find all DragTarget<_CardDef> widgets using runtimeType matching
    final dragTargetFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().startsWith('DragTarget'));
    expect(dragTargetFinder, findsWidgets);

    // 1. Drag the first card in storage (I자, index 0) to an invalid target (row 1 left, distance 3: index 2 in drag targets list)
    final iCardFinder = draggablesFinder.at(0);
    final invalidTarget = dragTargetFinder.at(2);

    final dragGesture = await tester.startGesture(tester.getCenter(iCardFinder));
    await tester.pump();
    await dragGesture.moveTo(tester.getCenter(invalidTarget));
    await tester.pump();
    await dragGesture.up();
    await tester.pumpAndSettle();

    // Left torque should still be 0 because it was invalid
    expect(find.text('왼쪽 기울기: 0'), findsOneWidget);

    // 2. Drag the first card in storage (I자, index 0) to a valid target (distance 2: index 3 in row 1)
    final validTarget = dragTargetFinder.at(3); // distance 2

    final dragGesture2 = await tester.startGesture(tester.getCenter(iCardFinder));
    await tester.pump();
    await dragGesture2.moveTo(tester.getCenter(validTarget));
    await tester.pump();
    await dragGesture2.up();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Left torque should be 14
    expect(find.text('왼쪽 기울기: 14'), findsOneWidget);

    // 3. Drag L자 card to the right side.
    // Since I자 is placed, the first Draggable in the storage is now L자 (index 0 of remaining draggables).
    final lCardFinder = draggablesFinder.at(0);
    final rightTarget = dragTargetFinder.at(6); // right side distance 2

    final dragGesture3 = await tester.startGesture(tester.getCenter(lCardFinder));
    await tester.pump();
    await dragGesture3.moveTo(tester.getCenter(rightTarget));
    await tester.pump();
    await dragGesture3.up();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Rotate the right card to index 3
    await tester.tap(rightTarget); // rot = 1
    await tester.pumpAndSettle();
    await tester.tap(rightTarget); // rot = 2
    await tester.pumpAndSettle();
    await tester.tap(rightTarget); // rot = 3
    await tester.pumpAndSettle();

    // Now right rotation is 3. Drag S자 (the first remaining draggable card in storage: index 0) to test out-of-range bug.
    final sCardFinder = draggablesFinder.at(0);
    final rightTarget3 = dragTargetFinder.at(7);

    final dragGesture4 = await tester.startGesture(tester.getCenter(sCardFinder));
    await tester.pump();
    await dragGesture4.moveTo(tester.getCenter(rightTarget3));
    await tester.pump();
    await dragGesture4.up();
    await tester.pumpAndSettle();

    // The test completes successfully without any crashes!
  });
}
