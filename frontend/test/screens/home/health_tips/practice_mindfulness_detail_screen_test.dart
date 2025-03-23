import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/home/health-tips/practice-mindfulness.dart';

void main() {
  group('PracticeMindfulnessDetailScreen Widget Tests', () {
    testWidgets('Renders correct app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PracticeMindfulnessDetailScreen()),
      );

      // Check app bar title
      expect(find.text('Get Rest'), findsOneWidget);

      // Check back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Renders image container', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PracticeMindfulnessDetailScreen()),
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
        const MaterialApp(home: PracticeMindfulnessDetailScreen()),
      );

      // Check for key text sections
      expect(find.text('Stress Management for Pain Relief'), findsOneWidget);
      expect(find.text('Expert Insight:'), findsOneWidget);
      expect(find.text('Effective Mindfulness Practices:'), findsOneWidget);
    });

    testWidgets('Renders expert quote', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PracticeMindfulnessDetailScreen()),
      );

      // Check for expert quote
      expect(
        find.text(
          '"When stress levels are high, the body releases cortisol, which can make period pain worse. Relaxation techniques help lower stress and reduce discomfort." – Dr. Jessica Shepherd, OB-GYN',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders mindfulness practices', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PracticeMindfulnessDetailScreen()),
      );

      // Check for specific mindfulness practices
      final practices = [
        'Deep breathing',
        'Practice Good Sleep Hygiene',
        'Take Short Breaks',
        'Use Comfortable Sleeping Positions',
      ];

      for (var practice in practices) {
        expect(find.text(practice), findsOneWidget);
      }
    });

    testWidgets('Back button navigation works', (WidgetTester tester) async {
      bool navigationCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PracticeMindfulnessDetailScreen(),
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
        const MaterialApp(home: PracticeMindfulnessDetailScreen()),
      );

      // Find SingleChildScrollView
      final scrollFinder = find.byType(SingleChildScrollView);
      expect(scrollFinder, findsOneWidget);

      // Attempt to scroll
      await tester.drag(scrollFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify scrolling works by checking if lower content is now visible
      expect(find.text('Use Comfortable Sleeping Positions'), findsOneWidget);

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
