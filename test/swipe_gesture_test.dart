import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/category/data/repositories/category_repository_provider.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/main.dart';
import 'fakes.dart';

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

  testWidgets('Swipe right to toggle completion status', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Seed repository with an incomplete task
    final task = Task(
      id: 'task-1',
      title: 'Swipe Right Task',
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    await fakeTodoRepository.saveTask(task);

    // 2. Build the app with overrides
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

    // Verify task is initially displayed and not completed
    expect(find.text('Swipe Right Task'), findsOneWidget);
    final checkboxFinder = find.byType(Checkbox);
    expect(tester.widget<Checkbox>(checkboxFinder).value, isFalse);

    // 3. Swipe the task card to the right (start to end)
    final taskCard = find.text('Swipe Right Task');
    await tester.drag(taskCard, const Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    // Verify task status in database was updated
    final updatedTask = await fakeTodoRepository.getTask('task-1');
    expect(updatedTask?.isCompleted, isTrue);

    // Verify UI updated
    expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue);
  });

  testWidgets('Swipe left to soft-delete task', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Seed repository with an active task
    final task = Task(
      id: 'task-2',
      title: 'Swipe Left Task',
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    await fakeTodoRepository.saveTask(task);

    // 2. Build the app with overrides
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

    // Verify task is displayed
    expect(find.text('Swipe Left Task'), findsOneWidget);

    // 3. Swipe the task card to the left (end to start)
    final taskCard = find.text('Swipe Left Task');
    await tester.drag(taskCard, const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    // Verify task is removed from active tasks list in DB (isDeleted = true)
    final updatedTask = await fakeTodoRepository.getTask('task-2');
    expect(updatedTask?.isDeleted, isTrue);

    // Verify UI has updated and card is gone
    expect(find.text('Swipe Left Task'), findsNothing);

    // Verify undo snackbar is shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('"Swipe Left Task" moved to trash'), findsOneWidget);

    // 4. Tap 'Undo' and verify task is restored
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    final restoredTask = await fakeTodoRepository.getTask('task-2');
    expect(restoredTask?.isDeleted, isFalse);

    // Verify task is back in the UI
    expect(find.text('Swipe Left Task'), findsOneWidget);
  });
}
