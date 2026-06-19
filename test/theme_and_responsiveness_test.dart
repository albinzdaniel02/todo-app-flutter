import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/category/data/repositories/category_repository_provider.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/core/theme/theme_controller.dart';
import 'package:todo_app/features/todo/presentation/views/task_detail_pane.dart';
import 'package:todo_app/main.dart';
import 'fakes.dart';

class FakeThemeController extends ThemeController {
  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
  }

  @override
  Future<void> toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

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

  testWidgets(
    'ThemeController toggles light and dark modes correctly via SettingsTab',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoRepositoryProvider.overrideWithValue(fakeTodoRepository),
            categoryRepositoryProvider.overrideWithValue(
              fakeCategoryRepository,
            ),
            themeControllerProvider.overrideWith(() => FakeThemeController()),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial theme mode is system
      var app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, equals(ThemeMode.system));

      // Navigate to Settings tab
      final settingsTabIcon = find.byIcon(Icons.settings_outlined);
      expect(settingsTabIcon, findsOneWidget);
      await tester.tap(settingsTabIcon);
      await tester.pumpAndSettle();

      // Find the Theme Mode popup menu button
      final themeMenuButton = find.byType(PopupMenuButton<ThemeMode>);
      expect(themeMenuButton, findsOneWidget);
      await tester.tap(themeMenuButton);
      await tester.pumpAndSettle();

      // Select Dark Mode
      final darkModeItem = find.text('Dark Mode');
      expect(darkModeItem, findsOneWidget);
      await tester.tap(darkModeItem);
      await tester.pumpAndSettle();

      // Verify that MaterialApp now has dark theme mode
      app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, equals(ThemeMode.dark));

      // Re-open and select Light Mode
      await tester.tap(themeMenuButton);
      await tester.pumpAndSettle();

      final lightModeItem = find.text('Light Mode');
      expect(lightModeItem, findsOneWidget);
      await tester.tap(lightModeItem);
      await tester.pumpAndSettle();

      // Verify that MaterialApp now has light theme mode
      app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, equals(ThemeMode.light));

      // Re-open and select System Default
      await tester.tap(themeMenuButton);
      await tester.pumpAndSettle();

      final systemModeItem = find.text('System Default');
      expect(systemModeItem, findsOneWidget);
      await tester.tap(systemModeItem);
      await tester.pumpAndSettle();

      // Verify that MaterialApp now has system theme mode
      app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, equals(ThemeMode.system));
    },
  );

  testWidgets(
    'Layout correctly adapts dynamically when screen width changes across 768px threshold',
    (WidgetTester tester) async {
      // 1. Start with Mobile screen width (below 768px)
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoRepositoryProvider.overrideWithValue(fakeTodoRepository),
            categoryRepositoryProvider.overrideWithValue(
              fakeCategoryRepository,
            ),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Mobile Navigation (BottomNavigationBar is visible)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byKey(const Key('widescreenNavigationRail')), findsNothing);
      expect(find.byType(TaskDetailPane), findsNothing);

      // 2. Resize to Widescreen width (above 768px)
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpAndSettle();

      // Verify Widescreen Navigation (NavigationRail is visible, BottomNavigationBar is hidden)
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.byKey(const Key('widescreenNavigationRail')), findsOneWidget);

      // Verify Split-pane layout (TaskDetailPane is visible on widescreen TodoTab)
      expect(find.byType(TaskDetailPane), findsOneWidget);

      // 3. Resize back to Mobile screen width (below 768px)
      tester.view.physicalSize = const Size(500, 800);
      await tester.pumpAndSettle();

      // Verify it switches back to Mobile navigation dynamically
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byKey(const Key('widescreenNavigationRail')), findsNothing);
      expect(find.byType(TaskDetailPane), findsNothing);
    },
  );
}
