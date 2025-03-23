import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/home/health-tips/stay-active-detail.dart';

void main() {
  group('StayActiveDetailScreen Widget Tests', () {
    testWidgets('Renders correct app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StayActiveDetailScreen()),
      );

      // Check app bar title
      expect(find.text('Stay Active'), findsOneWidget);

      // Check back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Renders image container', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StayActiveDetailScreen()),
      );

      // Find image container
      final imageFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).image != null,
      );
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('Renders main sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StayActiveDetailScreen()),
      );

      // Check for key text sections
      expect(find.text('Exercise Helps Relieve Pain'), findsOneWidget);
      expect(find.text('Expert Insight:'), findsOneWidget);
      expect(find.text('Recommended Exercises'), findsOneWidget);
    });

    testWidgets('Renders expert quote', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StayActiveDetailScreen()),
      );

      // Check for expert quote
      expect(
        find.text(
          '"Even light exercises like stretching or gentle yoga can improve blood flow and help reduce menstrual cramps by relaxing the pelvic muscles." – Dr. Lisa Masterson, OB-GYN',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders recommended exercises', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StayActiveDetailScreen()),
      );

      // Check for specific exercises
      final exercises = ['Walking', 'Yoga', 'Swimming', 'Stretching'];

      for (var exercise in exercises) {
        expect(find.text(exercise), findsOneWidget);
      }

      // Check exercise descriptions
      final descriptions = [
        '20-30 minutes daily',
        'Focus on hip-opening poses',
        'Gentle laps, 15-20 minutes',
        'Pelvic and lower back focus',
      ];

      for (var description in descriptions) {
        expect(find.text(description), findsOneWidget);
      }
    });

    testWidgets('Back button navigation works', (WidgetTester tester) async {
      bool navigationCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StayActiveDetailScreen(),
          navigatorObservers: [
            TestNavigatorObserver(
              onPop: () {
                navigationCalled = true;
              },
            ),
          ],
        ),
      );

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(navigationCalled, true);
    });

    testWidgets('Scrollable content works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StayActiveDetailScreen()),
      );

      // Find SingleChildScrollView
      final scrollFinder = find.byType(SingleChildScrollView);
      expect(scrollFinder, findsOneWidget);

      // Attempt to scroll
      await tester.drag(scrollFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify scrolling works by checking if lower content is now visible
      expect(find.text('Stretching'), findsOneWidget);
      expect(find.text('Pelvic and lower back focus'), findsOneWidget);
    });

    testWidgets('Exercise tiles have correct styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: StayActiveDetailScreen()),
      );

      // Check for bullet point icons
      final bulletPoints = tester
          .widgetList(find.byIcon(Icons.circle))
          .where(
            (icon) =>
                icon is Icon &&
                icon.size == 8 &&
                icon.color == Colors.pink[300],
          );

      expect(bulletPoints.length, 4); // One for each exercise

      print("Tested Successfully");
    });
  });
}

// Helper class to track navigation
class TestNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPop;

  TestNavigatorObserver({required this.onPop});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop();
    super.didPop(route, previousRoute);
  }
}
