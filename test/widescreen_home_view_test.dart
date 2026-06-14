import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/category/data/repositories/category_repository_provider.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/main.dart';
import 'swipe_gesture_test.dart';

void main() {
  late FakeTodoRepository fakeTodoRepository;
  late FakeCategoryRepository fakeCategoryRepository;

  setUp(() {
    fakeTodoRepository = FakeTodoRepository();
    fakeCategoryRepository = FakeCategoryRepository();
  });

  tearDown(() {
    fakeTodoRepository.dispose();
    fakeCategoryRepository.dispose();
  });

  testWidgets('WidescreenHomeView layout and navigation rail test', (
    WidgetTester tester,
  ) async {
    // Set screen width to a widescreen resolution (e.g., 1024x768)
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(fakeTodoRepository),
          categoryRepositoryProvider.overrideWithValue(fakeCategoryRepository),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify NavigationRail is displayed
    expect(find.byKey(const Key('widescreenNavigationRail')), findsOneWidget);
    // Verify Mobile BottomNavigationBar is NOT displayed
    expect(find.byType(BottomNavigationBar), findsNothing);

    // Verify initial title is 'My Tasks'
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('My Tasks')),
      findsOneWidget,
    );

    // Tap on 'Tags' destination in the NavigationRail
    final tagsNavDestination = find.byKey(const Key('nav_tags_icon'));
    await tester.tap(tagsNavDestination);
    await tester.pumpAndSettle();

    // Verify that the title changed to 'Tags'
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Tags')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('My Tasks')),
      findsNothing,
    );

    // Tap on 'Settings' destination in the NavigationRail
    final settingsNavDestination = find.byKey(const Key('nav_settings_icon'));
    await tester.tap(settingsNavDestination);
    await tester.pumpAndSettle();

    // Verify that the title changed to 'Settings'
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
