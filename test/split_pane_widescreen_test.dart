import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/category/data/repositories/category_repository_provider.dart';
import 'package:todo_app/features/category/domain/entities/category.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/domain/entities/subtask.dart';
import 'package:todo_app/features/todo/presentation/views/task_detail_pane.dart';
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

  testWidgets('Split-pane layout: responsive views and right pane task editor', (
    WidgetTester tester,
  ) async {
    // Seed category
    final category = const Category(
      id: 'cat-1',
      name: 'Work',
      colorHex: '#4f46e5',
    );
    await fakeCategoryRepository.saveCategory(category);

    // Seed task with subtask
    final task = Task(
      id: 'task-1',
      title: 'Initial Title',
      description: 'Initial Description',
      priority: TaskPriority.medium,
      categoryId: 'cat-1',
      dueDate: DateTime(2026, 6, 16, 12, 0),
      subtasks: const [
        Subtask(id: 'sub-1', title: 'Subtask 1', isCompleted: false),
      ],
      createdAt: DateTime.now(),
    );
    await fakeTodoRepository.saveTask(task);

    // -------------------------------------------------------------
    // Test Scenario 1: Mobile Viewport (< 768px)
    // -------------------------------------------------------------
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1.0;

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

    // Verify task is in the list
    expect(find.text('Initial Title'), findsOneWidget);

    // Right pane detail pane and details editor should NOT be displayed on mobile
    expect(find.byType(TaskDetailPane), findsNothing);
    expect(find.byKey(const Key('placeholderText')), findsNothing);

    // Reset size
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();

    // -------------------------------------------------------------
    // Test Scenario 2: Widescreen Viewport (>= 768px)
    // -------------------------------------------------------------
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

    // Task details pane should show placeholder when no task is selected
    expect(find.byType(TaskDetailPane), findsOneWidget);
    expect(find.byKey(const Key('placeholderText')), findsOneWidget);
    expect(find.text('Select a task to view details'), findsOneWidget);

    // Click on the task list card to select it
    final cardGesture = find.byKey(const Key('task_card_gesture_task-1'));
    expect(cardGesture, findsOneWidget);
    await tester.tap(cardGesture);
    await tester.pumpAndSettle();

    // The detail editor should open immediately
    expect(find.byType(TaskDetailEditor), findsOneWidget);
    expect(find.byKey(const Key('placeholderText')), findsNothing);

    // Verify initial values in form fields
    expect(find.text('Initial Title'), findsWidgets); // Both list and editor
    expect(find.text('Initial Description'), findsNWidgets(2));
    expect(find.text('Medium'), findsWidgets); // Priority
    expect(find.text('Subtask 1'), findsOneWidget);

    // Edit Title & Description
    await tester.enterText(
      find.byKey(const Key('detailTitleField')),
      'Updated Title',
    );
    await tester.enterText(
      find.byKey(const Key('detailDescriptionField')),
      'Updated Description',
    );
    await tester.pumpAndSettle();

    // Toggle priority to High
    final highPriorityButton = find.byKey(const Key('detailPriority_high'));
    expect(highPriorityButton, findsOneWidget);
    await tester.tap(highPriorityButton);
    await tester.pumpAndSettle();

    // Toggle subtask checkbox
    final subtaskCheckbox = find.byKey(
      const Key('detailSubtaskCheckbox_sub-1'),
    );
    expect(subtaskCheckbox, findsOneWidget);
    await tester.tap(subtaskCheckbox);
    await tester.pumpAndSettle();

    // Add a new subtask
    final addSubtaskField = find.byKey(const Key('detailAddSubtaskField'));
    expect(addSubtaskField, findsOneWidget);
    await tester.enterText(addSubtaskField, 'Subtask 2');
    await tester.pumpAndSettle();

    final addSubtaskButton = find.byKey(const Key('detailAddSubtaskButton'));
    expect(addSubtaskButton, findsOneWidget);
    await tester.tap(addSubtaskButton);
    await tester.pumpAndSettle();

    expect(find.text('Subtask 2'), findsOneWidget);

    // Save changes
    final saveButton = find.byKey(const Key('detailSaveButton'));
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify updated task state in repository
    final savedTask = await fakeTodoRepository.getTask('task-1');
    expect(savedTask, isNotNull);
    expect(savedTask!.title, 'Updated Title');
    expect(savedTask.description, 'Updated Description');
    expect(savedTask.priority, TaskPriority.high);
    expect(savedTask.subtasks.length, 2);
    expect(savedTask.subtasks[0].title, 'Subtask 1');
    expect(savedTask.subtasks[0].isCompleted, true);
    expect(savedTask.subtasks[1].title, 'Subtask 2');
    expect(savedTask.subtasks[1].isCompleted, false);

    // Delete subtask 1
    final deleteSubtaskButton = find.byKey(
      const Key('detailSubtaskDelete_sub-1'),
    );
    expect(deleteSubtaskButton, findsOneWidget);
    await tester.tap(deleteSubtaskButton);
    await tester.pumpAndSettle();

    // Save again
    ScaffoldMessenger.of(
      tester.element(find.byType(TaskDetailEditor)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final savedTaskAfterSubtaskDelete = await fakeTodoRepository.getTask(
      'task-1',
    );
    expect(savedTaskAfterSubtaskDelete!.subtasks.length, 1);
    expect(savedTaskAfterSubtaskDelete.subtasks[0].title, 'Subtask 2');

    // Hide snackbar to prevent it from obscuring the delete button
    ScaffoldMessenger.of(
      tester.element(find.byType(TaskDetailEditor)),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    // Test Delete task from Right Pane
    final deleteButton = find.byKey(const Key('detailDeleteButton'));
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Verify task is soft-deleted in repository
    final deletedTask = await fakeTodoRepository.getTask('task-1');
    expect(deletedTask!.isDeleted, true);

    // Verify detail editor is replaced back by placeholder
    expect(find.byType(TaskDetailEditor), findsNothing);
    expect(find.text('Select a task to view details'), findsOneWidget);
  });
}
