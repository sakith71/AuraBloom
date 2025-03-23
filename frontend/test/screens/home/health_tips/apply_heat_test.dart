import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/home/health-tips/apply-heat.dart'; // Update this import path to match your project structure

void main() {
  testWidgets('ApplyHeatDetailScreen displays correct app bar', (
    WidgetTester tester,
  ) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(home: ApplyHeatDetailScreen()));

    // Verify app bar
    expect(find.text('Apply Heat'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('ApplyHeatDetailScreen displays all content sections', (
    WidgetTester tester,
  ) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(home: ApplyHeatDetailScreen()));

    // Verify main title and content
    expect(find.text('A Simple and Effective Remedy'), findsOneWidget);
    expect(
      find.text(
        'Applying heat to your lower abdomen can be as effective as over-the-counter painkillers in reducing period pain. The warmth increases blood flow to the uterus, which helps relax tight muscles and reduce the intensity of cramps. You can use a heating pad, hot water bottle, or a warm towel. Taking a warm bath can also provide relief by relaxing the entire body and reducing stress-related tension. ',
      ),
      findsOneWidget,
    );

    // Verify expert insight section
    expect(find.text('Expert Insight:'), findsOneWidget);
    expect(
      find.text(
        '"Heat therapy is a safe, non-invasive way to manage menstrual pain. Studies have shown it can be as effective as ibuprofen in reducing cramps." – Dr. Penelope Law, Consultant Gynecologist',
      ),
      findsOneWidget,
    );

    // Verify heat therapy section title
    expect(find.text('How to Use Heat Therapy:'), findsOneWidget);
  });

  testWidgets('ApplyHeatDetailScreen displays all heat therapy methods', (
    WidgetTester tester,
  ) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(home: ApplyHeatDetailScreen()));

    // Verify all heat therapy methods are displayed
    expect(find.text('Heating Pad or Hot Water Bottle'), findsOneWidget);
    expect(
      find.text(
        'Place a heating pad or hot water bottle on your lower abdomen for 15–20 minutes at a time to relax muscles and improve blood circulation, reducing cramps.',
      ),
      findsOneWidget,
    );

    expect(find.text('Warm Bath with Epsom Salts'), findsOneWidget);
    expect(
      find.text(
        'A warm bath infused with Epsom salts helps ease muscle tension and provides full-body relaxation, making cramps more manageable.',
      ),
      findsOneWidget,
    );

    expect(find.text('Adhesive Heat Patches'), findsOneWidget);
    expect(
      find.text(
        ' If you need relief while on the go, adhesive heat patches provide continuous warmth and help keep cramps under control throughout the day.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('ApplyHeatDetailScreen has correct bullet points', (
    WidgetTester tester,
  ) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(home: ApplyHeatDetailScreen()));

    // Verify bullet points (circles) are present for each heat therapy method
    expect(find.byIcon(Icons.circle), findsNWidgets(3));
  });

  testWidgets('ApplyHeatDetailScreen navigation works correctly', (
    WidgetTester tester,
  ) async {
    // Define a variable to track if navigation occurred
    var navigatorCalled = false;

    // Build the widget with a custom navigator observer
    await tester.pumpWidget(
      MaterialApp(
        home: ApplyHeatDetailScreen(),
        navigatorObservers: [
          TestNavigatorObserver(
            onPop: () {
              navigatorCalled = true;
            },
          ),
        ],
      ),
    );

    // Tap the back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify navigator was called
    expect(navigatorCalled, true);
  });

  testWidgets('ApplyHeatDetailScreen scrolls properly to show all content', (
    WidgetTester tester,
  ) async {
    // Build the widget with a constrained height to force scrolling
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 500, // Constrained height
          child: const ApplyHeatDetailScreen(),
        ),
      ),
    );

    // The adhesive heat patches section might not be visible initially
    // Let's find positions before scrolling
    final initialPosition = tester.getCenter(
      find.text('A Simple and Effective Remedy'),
    );

    // Scroll down
    await tester.dragFrom(
      tester.getCenter(find.byType(SingleChildScrollView)),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    // Verify we've scrolled by checking if position has changed
    final newPosition = tester.getCenter(
      find.text('A Simple and Effective Remedy'),
    );
    expect(initialPosition.dy != newPosition.dy, true);

    // Now adhesive heat patches should be visible
    expect(find.text('Adhesive Heat Patches'), findsOneWidget);
  });

  testWidgets('ApplyHeatDetailScreen has image container', (
    WidgetTester tester,
  ) async {
    // Build the widget
    await tester.pumpWidget(const MaterialApp(home: ApplyHeatDetailScreen()));

    // Find containers that might contain the image
    final containers = find.byType(Container);

    // There should be at least one container
    expect(containers, findsWidgets);

    print("Test passed successfully");
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
