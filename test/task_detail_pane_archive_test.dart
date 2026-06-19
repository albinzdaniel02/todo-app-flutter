import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/category/data/repositories/category_repository_provider.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/presentation/views/task_detail_pane.dart';
import 'package:todo_app/features/todo/presentation/controllers/todo_list_controller.dart';
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

  testWidgets('TaskDetailPane: Archive non-archived task and Undo', (
    WidgetTester tester,
  ) async {
    // Set widescreen size so TaskDetailPane is visible
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final task = Task(
      id: 'task-test-archive',
      title: 'Archive Me Task',
      description: 'Archive test description',
      priority: TaskPriority.medium,
      isArchived: false,
      createdAt: DateTime.now(),
    );
    await fakeTodoRepository.saveTask(task);

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

    // Select the task to open it in the details editor
    final cardGesture = find.byKey(
      const Key('task_card_gesture_task-test-archive'),
    );
    expect(cardGesture, findsOneWidget);
    await tester.tap(cardGesture);
    await tester.pumpAndSettle();

    // Verify detail pane is showing
    expect(find.byType(TaskDetailEditor), findsOneWidget);

    // Verify "Archive" button is shown, and "Restore" is NOT shown
    final archiveBtn = find.byKey(const Key('detailArchiveButton'));
    final restoreBtn = find.byKey(const Key('detailRestoreButton'));
    expect(archiveBtn, findsOneWidget);
    expect(restoreBtn, findsNothing);

    // Verify archive icon is archive_outlined
    final iconFinder = find.descendant(
      of: archiveBtn,
      matching: find.byIcon(Icons.archive_outlined),
    );
    expect(iconFinder, findsOneWidget);

    // Tap archive button
    await tester.tap(archiveBtn);
    await tester.pumpAndSettle();

    // Verify task is deselected (placeholder showing instead of TaskDetailEditor)
    expect(find.byType(TaskDetailEditor), findsNothing);
    expect(find.text('Select a task to view details'), findsOneWidget);

    // Verify Snack Bar text and duration (checked by checking if Snackbar is present)
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('"Archive Me Task" archived'), findsOneWidget);

    // Verify database state: task is now archived
    final updatedTask = await fakeTodoRepository.getTask('task-test-archive');
    expect(updatedTask!.isArchived, isTrue);

    // Tap Undo action on SnackBar
    final undoAction = find.text('Undo');
    expect(undoAction, findsOneWidget);
    await tester.tap(undoAction);
    await tester.pumpAndSettle();

    // Verify database state: task is unarchived (restored) again
    final undoneTask = await fakeTodoRepository.getTask('task-test-archive');
    expect(undoneTask!.isArchived, isFalse);
  });

  testWidgets('TaskDetailPane: Restore archived task and Undo', (
    WidgetTester tester,
  ) async {
    // Set widescreen size so TaskDetailPane is visible
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final task = Task(
      id: 'task-test-restore',
      title: 'Restore Me Task',
      description: 'Restore test description',
      priority: TaskPriority.medium,
      isArchived: true,
      createdAt: DateTime.now(),
    );
    await fakeTodoRepository.saveTask(task);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(fakeTodoRepository),
          categoryRepositoryProvider.overrideWithValue(fakeCategoryRepository),
          todoStatusFilterStateProvider.overrideWith(
            () => ArchivedStatusFilterState(),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Select the task to open it in the details editor
    final cardGesture = find.byKey(
      const Key('task_card_gesture_task-test-restore'),
    );
    expect(cardGesture, findsOneWidget);
    await tester.tap(cardGesture);
    await tester.pumpAndSettle();

    // Verify detail pane is showing
    expect(find.byType(TaskDetailEditor), findsOneWidget);

    // Verify "Restore" button is shown, and "Archive" is NOT shown
    final archiveBtn = find.byKey(const Key('detailArchiveButton'));
    final restoreBtn = find.byKey(const Key('detailRestoreButton'));
    expect(restoreBtn, findsOneWidget);
    expect(archiveBtn, findsNothing);

    // Verify restore icon is unarchive_outlined
    final iconFinder = find.descendant(
      of: restoreBtn,
      matching: find.byIcon(Icons.unarchive_outlined),
    );
    expect(iconFinder, findsOneWidget);

    // Tap restore button
    await tester.tap(restoreBtn);
    await tester.pumpAndSettle();

    // Verify task is deselected
    expect(find.byType(TaskDetailEditor), findsNothing);
    expect(find.text('Select a task to view details'), findsOneWidget);

    // Verify Snack Bar text
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('"Restore Me Task" restored to active list'),
      findsOneWidget,
    );

    // Verify database state: task is restored (isArchived = false)
    final updatedTask = await fakeTodoRepository.getTask('task-test-restore');
    expect(updatedTask!.isArchived, isFalse);

    // Tap Undo action on SnackBar
    final undoAction = find.text('Undo');
    expect(undoAction, findsOneWidget);
    await tester.tap(undoAction);
    await tester.pumpAndSettle();

    // Verify database state: task is archived again
    final undoneTask = await fakeTodoRepository.getTask('task-test-restore');
    expect(undoneTask!.isArchived, isTrue);
  });
}

class ArchivedStatusFilterState extends TodoStatusFilterState {
  @override
  TodoStatusFilter build() => TodoStatusFilter.archived;
}
