// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/main.dart';

void main() {
  testWidgets('HomeView navigation and tabs test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the title of the first tab is displayed in the AppBar.
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('My Tasks')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Tags')),
      findsNothing,
    );

    // Verify search input field exists.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Search Tasks...'), findsOneWidget);

    // Tap on the 'Tags' tab in the bottom navigation bar.
    await tester.tap(find.byIcon(Icons.label_outline));
    await tester.pumpAndSettle();

    // Verify that the title changes to 'Tags'.
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Tags')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('My Tasks')),
      findsNothing,
    );

    // Tap on the 'Settings' tab in the bottom navigation bar.
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Verify that the title changes to 'Settings'.
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Settings')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Tags')),
      findsNothing,
    );
  });
}
