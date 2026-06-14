import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/category/data/repositories/category_repository_provider.dart';
import 'package:todo_app/features/todo/data/repositories/todo_repository_provider.dart';
import 'package:todo_app/features/todo/domain/entities/task.dart';
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

  testWidgets('Category management: Add, edit, and delete categories', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
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

    // 1. Go to Tags tab
    await tester.tap(find.byIcon(Icons.label_outline));
    await tester.pumpAndSettle();

    // Verify "Create Tag" section exists
    expect(find.text('Create Tag'), findsOneWidget);

    // 2. Add Tag
    final nameField = find.byKey(const Key('createTagNameField'));
    await tester.enterText(nameField, 'Personal');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // Drag the scrollable list view up to ensure the button is away from the bottom bar overlay
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    // Tap Add Tag by key
    final addTagButton = find.byKey(const Key('addTagButton'));
    await tester.tap(addTagButton);
    await tester.pumpAndSettle();

    // Verify Personal is added in the category list and repository
    expect(find.text('Personal'), findsOneWidget);
    var categories = await fakeCategoryRepository.getCategories();
    expect(categories, hasLength(1));
    expect(categories.first.name, 'Personal');
    final personalCatId = categories.first.id;

    // 3. Edit Tag
    final editButton = find.byKey(Key('edit_category_$personalCatId'));
    expect(editButton, findsOneWidget);
    await tester.ensureVisible(editButton);
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // Verify Edit dialog is open
    expect(find.text('Edit Tag'), findsOneWidget);
    final editNameField = find.byKey(const Key('editCategoryNameField'));
    await tester.enterText(editNameField, 'Personal Edited');
    await tester.pumpAndSettle();

    // Save changes
    final saveButton = find.byKey(const Key('saveCategoryButton'));
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify updated tag in repository and UI
    expect(find.text('Personal Edited'), findsOneWidget);
    categories = await fakeCategoryRepository.getCategories();
    expect(categories.first.name, 'Personal Edited');

    // 4. Delete Tag
    final deleteButton = find.byKey(Key('delete_category_$personalCatId'));
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Verify tag is deleted from repository and UI
    expect(find.text('Personal Edited'), findsNothing);
    categories = await fakeCategoryRepository.getCategories();
    expect(categories, isEmpty);
  });

  testWidgets('Archive View: Display, unarchive, and move to trash', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Seed an archived task
    final task = Task(
      id: 'task-archive-1',
      title: 'Archived Task',
      description: 'Archived task desc',
      priority: TaskPriority.medium,
      isArchived: true,
      isDeleted: false,
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

    // Go to Settings tab
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Tap "Archived Tasks" list tile
    final archiveTile = find.byKey(const Key('settingsArchiveTile'));
    expect(archiveTile, findsOneWidget);
    await tester.tap(archiveTile);
    await tester.pumpAndSettle();

    // Verify we are on the Archive screen and the archived task is listed
    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Archived Task'), findsOneWidget);

    // Unarchive the task
    final unarchiveBtn = find.byKey(const Key('unarchive_task-archive-1'));
    expect(unarchiveBtn, findsOneWidget);
    await tester.tap(unarchiveBtn);
    await tester.pumpAndSettle();

    // Verify the list is empty now and task is unarchived in repository
    expect(find.text('No archived tasks'), findsOneWidget);
    var repoTasks = await fakeTodoRepository.getTasks();
    expect(repoTasks.first.isArchived, isFalse);

    // Re-archive the task for the move to trash test
    await fakeTodoRepository.saveTask(repoTasks.first.copyWith(isArchived: true));
    await tester.pumpAndSettle();

    // Delete/move to trash from archive view
    final deleteBtn = find.byKey(const Key('delete_archived_task-archive-1'));
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    // Verify it is gone from Archive screen and marked isDeleted in repository
    expect(find.text('No archived tasks'), findsOneWidget);
    repoTasks = await fakeTodoRepository.getTasks();
    expect(repoTasks.first.isDeleted, isTrue);
    expect(repoTasks.first.isArchived, isTrue);
  });

  testWidgets('Trash View: Display, restore, delete permanently, and empty trash', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Seed soft-deleted tasks
    final task1 = Task(
      id: 'task-trash-1',
      title: 'Trashed Task 1',
      priority: TaskPriority.high,
      isDeleted: true,
      createdAt: DateTime.now(),
    );
    final task2 = Task(
      id: 'task-trash-2',
      title: 'Trashed Task 2',
      priority: TaskPriority.low,
      isDeleted: true,
      createdAt: DateTime.now(),
    );
    await fakeTodoRepository.saveTask(task1);
    await fakeTodoRepository.saveTask(task2);

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

    // Go to Settings tab
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Tap "Trash" list tile
    final trashTile = find.byKey(const Key('settingsTrashTile'));
    expect(trashTile, findsOneWidget);
    await tester.tap(trashTile);
    await tester.pumpAndSettle();

    // Verify we are on the Trash screen and both tasks are listed
    expect(find.text('Trash'), findsOneWidget);
    expect(find.text('Trashed Task 1'), findsOneWidget);
    expect(find.text('Trashed Task 2'), findsOneWidget);

    // 1. Restore task 1
    final restoreBtn = find.byKey(const Key('restore_task-trash-1'));
    await tester.tap(restoreBtn);
    await tester.pumpAndSettle();

    // Verify Trashed Task 1 is no longer listed in Trash and is restored in repository
    expect(find.text('Trashed Task 1'), findsNothing);
    var t1 = await fakeTodoRepository.getTask('task-trash-1');
    expect(t1!.isDeleted, isFalse);

    // 2. Delete task 2 permanently
    final deletePermBtn = find.byKey(const Key('delete_perm_task-trash-2'));
    await tester.tap(deletePermBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog shows up
    expect(find.text('Delete Permanently?'), findsOneWidget);
    final confirmDeleteBtn = find.byKey(const Key('confirmDeletePerm_task-trash-2'));
    await tester.tap(confirmDeleteBtn);
    await tester.pumpAndSettle();

    // Verify task 2 is permanently deleted from repo and UI
    expect(find.text('Trashed Task 2'), findsNothing);
    var t2 = await fakeTodoRepository.getTask('task-trash-2');
    expect(t2, isNull);

    // Seed task 2 again for Empty Trash testing
    await fakeTodoRepository.saveTask(task2);
    await tester.pumpAndSettle();

    // 3. Empty Trash
    final emptyTrashBtn = find.byKey(const Key('emptyTrashButton'));
    await tester.tap(emptyTrashBtn);
    await tester.pumpAndSettle();

    // Verify Empty Trash confirmation dialog shows up
    expect(find.text('Empty Trash?'), findsOneWidget);
    final confirmEmptyTrashBtn = find.byKey(const Key('confirmEmptyTrashButton'));
    await tester.tap(confirmEmptyTrashBtn);
    await tester.pumpAndSettle();

    // Verify trash is empty in UI and repo
    expect(find.text('Trash is empty'), findsOneWidget);
    var trashed = await fakeTodoRepository.getTrashedTasks();
    expect(trashed, isEmpty);
  });
}
