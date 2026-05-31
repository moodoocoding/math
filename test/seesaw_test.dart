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
    expect(find.text('도형 조각'), findsOneWidget);

    // Verify initial torques
    expect(find.text('왼쪽 기울기: 0'), findsOneWidget);
    expect(find.text('오른쪽 기울기: 0'), findsOneWidget);

    // Let's drag 'I자' card onto the left grid (e.g. distance 3, row 1)
    // Find the 'I자' card draggable
    final iCardFinder = find.text('I자');
    expect(iCardFinder, findsOneWidget);

    // Find a target cell. In our grid, row 1 left cells are DragTargets.
    // Find all DragTarget<_CardDef> widgets using runtimeType matching
    final dragTargetFinder = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().startsWith('DragTarget'));
    expect(dragTargetFinder, findsWidgets);

    // The first DragTarget is row 1 left, distance 5.
    // Let's drag to row 1 left, distance 3 (index 2 in the drag targets list)
    final target = dragTargetFinder.at(2);

    // Perform drag and drop
    final dragGesture = await tester.startGesture(tester.getCenter(iCardFinder));
    await tester.pump();
    
    // Move to the target drag target
    await dragGesture.moveTo(tester.getCenter(target));
    await tester.pump();
    
    // Release the drag
    await dragGesture.up();
    await tester.pumpAndSettle();

    // After dropping, the animation starts. Let's pump for a while to let the timer complete.
    // 150ms per cell, I-shape has 4 cells, so 600ms + buffer.
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // The 'I자' card torque:
    // LeftPreset: I-shape 가로 has 4 cells. At distance 3, cells are at 3, 4, 5, 6?
    // Wait, the horizontal I-shape has cells at offset (0, 0), (1, 0), (2, 0), (3, 0).
    // Placed at distance d=3, the cells are at 3, 4, 5, 6.
    // Wait! Distance must satisfy: d + maxCol <= 5.
    // For I-shape, maxCol is 3. So d + 3 <= 5 -> d can be 1 or 2.
    // If d = 3, then 3 + 3 = 6 > 5. So isValidAt(0, 3) is false!
    // Since it is invalid, the drag should be rejected. Let's check:
    // Left torque should still be 0.
    expect(find.text('왼쪽 기울기: 0'), findsOneWidget);

    // Let's drag to a valid distance, e.g. distance 2 (index 3 in row 1: distance 2)
    final validTarget = dragTargetFinder.at(3); // distance 2

    final dragGesture2 = await tester.startGesture(tester.getCenter(iCardFinder));
    await tester.pump();
    await dragGesture2.moveTo(tester.getCenter(validTarget));
    await tester.pump();
    await dragGesture2.up();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Since it is valid, the left torque should be calculated based on cells at 2, 3, 4, 5.
    // Torque = 2 + 3 + 4 + 5 = 14.
    expect(find.text('왼쪽 기울기: 14'), findsOneWidget);
    
    // Now let's test the out-of-range fix.
    // The left card has rotation index 0 (which is valid for I-shape, max rotation is 2).
    // Now let's try to drag 'L자' (which has 4 rotations) to the right side, rotate it to index 3,
    // and then drag another card with fewer rotations to see if any range errors happen.
    final lCardFinder = find.text('L자');
    expect(lCardFinder, findsOneWidget);

    // Find a drag target on the right side.
    // Right side target in row 1 starts after 5 left cells, so index 5 is right distance 1.
    // Let's drop L-shape (rotations: 4) at right distance 2 (index 6: row 1, right distance 2)
    // L-shape horizontal rotations max col is 1 or 2. At d=2, it's valid.
    final rightTarget = dragTargetFinder.at(6);
    
    final dragGesture3 = await tester.startGesture(tester.getCenter(lCardFinder));
    await tester.pump();
    await dragGesture3.moveTo(tester.getCenter(rightTarget));
    await tester.pump();
    await dragGesture3.up();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // L-shape is placed. Right torque is computed.
    // Let's rotate L-shape on the right side to index 3.
    // Click on the placed cell to trigger _rotateRight.
    // The placed cell is at rightTarget.
    await tester.tap(rightTarget); // rot = 1
    await tester.pumpAndSettle();
    await tester.tap(rightTarget); // rot = 2
    await tester.pumpAndSettle();
    await tester.tap(rightTarget); // rot = 3
    await tester.pumpAndSettle();

    // Now right rotation is 3.
    // Let's drag 'S자' (rotations: 2) or another card to the right side.
    // Wait, L-shape is already placed on the right side, so it is occupied.
    // But we can drag another card like 'S자' (rotations: 2) and hover over the right side.
    // S-shape has rotCount = 2 (valid rotations 0 and 1).
    // Hovering over the right side will trigger `onWillAcceptWithDetails` which calls `card.isValidAt(_rightRot, d)`.
    // Since _rightRot is 3, this would have thrown RangeError prior to our fix because S-shape rotations only go up to index 1.
    // With our fix, it uses drag rotation (0 for new card), so it will not crash!
    final sCardFinder = find.text('S자');
    expect(sCardFinder, findsOneWidget);

    final dragGesture4 = await tester.startGesture(tester.getCenter(sCardFinder));
    await tester.pump();
    // Hover over rightTarget (where L-shape is placed, or another right target like index 7: distance 3)
    final rightTarget3 = dragTargetFinder.at(7);
    await dragGesture4.moveTo(tester.getCenter(rightTarget3));
    await tester.pump();
    
    // If there was a RangeError, it would have crashed the gesture system here.
    // We cancel the drag.
    await dragGesture4.up();
    await tester.pumpAndSettle();

    // The test completes successfully without any crashes!
  });
}
