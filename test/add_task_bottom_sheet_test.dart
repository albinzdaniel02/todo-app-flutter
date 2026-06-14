import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/category/data/repositories/category_repository_provider.dart';
import 'package:todo_app/features/category/domain/entities/category.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
import 'package:todo_app/features/todo/presentation/views/add_task_bottom_sheet.dart';
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

  testWidgets(
    'AddTaskBottomSheet validation, priority selection, category selection, and task creation',
    (WidgetTester tester) async {
      // 1. Seed categories
      final category = const Category(
        id: 'cat-1',
        name: 'Work',
        colorHex: '#4F46E5',
      );
      await fakeCategoryRepository.saveCategory(category);

      // 2. Build the widget with overrides
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

      // 3. Open Bottom Sheet using the floating action button
      final fabFinder = find.byTooltip('Add Task');
      expect(fabFinder, findsOneWidget);
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      // 4. Verify Bottom Sheet is open
      expect(find.byType(AddTaskBottomSheet), findsOneWidget);

      // 5. Test validation: tap submit with empty title
      final submitButtonFinder = find.byKey(const Key('submitTaskButton'));
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Verification: Error message should be visible
      expect(find.text('Task title is required'), findsOneWidget);

      // Verify repository still empty
      var tasks = await fakeTodoRepository.getTasks();
      expect(tasks, isEmpty);

      // 6. Enter Task Title and Description
      final titleFieldFinder = find.byKey(const Key('taskTitleField'));
      final descFieldFinder = find.byKey(const Key('taskDescriptionField'));

      await tester.enterText(titleFieldFinder, 'Test Task Title');
      await tester.enterText(descFieldFinder, 'Test Task Description');
      await tester.pumpAndSettle();

      // Error message should disappear when typing/validating again
      // Let's verify selection of priority
      // Default priority is medium. Let's tap 'High'
      final highPriorityFinder = find.byKey(const Key('priority_high'));
      await tester.tap(highPriorityFinder);
      await tester.pumpAndSettle();

      // 7. Category selector dropdown interaction
      final categoryDropdownFinder = find.byKey(const Key('categoryDropdown'));
      expect(categoryDropdownFinder, findsOneWidget);
      await tester.tap(categoryDropdownFinder);
      await tester.pumpAndSettle();

      // Tap the 'Work' item in the dropdown
      final workDropdownItemFinder = find.text('Work').last;
      await tester.tap(workDropdownItemFinder);
      await tester.pumpAndSettle();

      // 8. Submit the form
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Verify Bottom Sheet is closed (should find zero AddTaskBottomSheet widgets)
      expect(find.byType(AddTaskBottomSheet), findsNothing);

      // 9. Verify task is saved correctly in repository
      tasks = await fakeTodoRepository.getTasks();
      expect(tasks, hasLength(1));
      final savedTask = tasks.first;
      expect(savedTask.title, equals('Test Task Title'));
      expect(savedTask.description, equals('Test Task Description'));
      expect(savedTask.priority, equals(TaskPriority.high));
      expect(savedTask.categoryId, equals('cat-1'));
      expect(savedTask.isCompleted, isFalse);
    },
  );

  testWidgets('AddTaskBottomSheet can cancel due date selection and clear it', (
    WidgetTester tester,
  ) async {
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

    // Open Bottom Sheet
    await tester.tap(find.byTooltip('Add Task'));
    await tester.pumpAndSettle();

    // Verify initial due date text is 'Set Due Date'
    expect(find.text('Set Due Date'), findsOneWidget);

    // Let's interact with date picker
    final datePickerButtonFinder = find.byKey(const Key('dueDatePicker'));
    await tester.tap(datePickerButtonFinder);
    await tester.pumpAndSettle();

    // Verify date picker dialog is shown
    expect(find.byType(DatePickerDialog), findsOneWidget);

    // Tap cancel/ok. Let's tap the 'OK' button (usually has text 'OK' in Material 3)
    // First, let's tap 'OK' (or cancel). Let's tap the 'CANCEL' button to ensure it doesn't set
    final cancelBtn = find.text('CANCEL');
    if (cancelBtn.evaluate().isNotEmpty) {
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();
    } else {
      // In some locales/versions it is 'Cancel'
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }

    // Verify dialog closed and text is still 'Set Due Date'
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(find.text('Set Due Date'), findsOneWidget);
  });

  testWidgets('AddTaskBottomSheet can successfully select due date and time', (
    WidgetTester tester,
  ) async {
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

    // Open Bottom Sheet
    await tester.tap(find.byTooltip('Add Task'));
    await tester.pumpAndSettle();

    // Fill title
    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Due Date Task',
    );
    await tester.pumpAndSettle();

    // Tap due date picker
    final datePickerButtonFinder = find.byKey(const Key('dueDatePicker'));
    await tester.tap(datePickerButtonFinder);
    await tester.pumpAndSettle();

    // Tap OK on DatePickerDialog
    final okBtn = find.text('OK');
    if (okBtn.evaluate().isNotEmpty) {
      await tester.tap(okBtn);
    } else {
      await tester.tap(find.text('Select'));
    }
    await tester.pumpAndSettle();

    // Tap OK on TimePickerDialog
    final timeOkBtn = find.text('OK');
    if (timeOkBtn.evaluate().isNotEmpty) {
      await tester.tap(timeOkBtn);
    } else {
      await tester.tap(find.text('Select'));
    }
    await tester.pumpAndSettle();

    // Verify due date is selected and no longer says 'Set Due Date'
    expect(find.text('Set Due Date'), findsNothing);

    // Tap submit button
    final submitButtonFinder = find.byKey(const Key('submitTaskButton'));
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Verify task is saved in repository with a non-null dueDate
    final tasks = await fakeTodoRepository.getTasks();
    expect(tasks, hasLength(1));
    expect(tasks.first.dueDate, isNotNull);
  });
}
