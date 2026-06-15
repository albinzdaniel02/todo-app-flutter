import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/responsive_layout.dart';
import 'features/todo/data/models/subtask.dart';
import 'features/todo/data/models/category.dart';
import 'features/todo/data/models/task.dart';
import 'features/todo/presentation/views/home_view.dart';
import 'features/todo/presentation/views/widescreen_home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(SubtaskModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TaskPriorityModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());

  // Open Hive boxes
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox('settings');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Todo App',
      theme: AppTheme.lightThemeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: themeMode,
      home: const ResponsiveLayout(
        mobileLayout: HomeView(),
        desktopLayout: WidescreenHomeView(),
      ),
    );
  }
}
