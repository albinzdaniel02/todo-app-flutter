import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/todo/presentation/controllers/navigation_controller.dart';
import 'package:todo_app/features/todo/presentation/views/home_view.dart';
import 'package:todo_app/features/todo/presentation/views/add_task_bottom_sheet.dart';
import 'package:todo_app/features/todo/presentation/views/archive_view.dart';
import 'package:todo_app/features/todo/presentation/views/trash_view.dart';

class WidescreenHomeView extends ConsumerWidget {
  const WidescreenHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationControllerProvider);
    final titles = ['My Tasks', 'Tags', 'Settings'];

    return Material(
      child: Row(
        children: [
          NavigationRail(
            key: const Key('widescreenNavigationRail'),
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(navigationControllerProvider.notifier).setIndex(index);
            },
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Icon(
                Icons.playlist_add_check,
                size: 36,
                color: Colors.blue,
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.check_box_outlined, key: Key('nav_todo_icon')),
                selectedIcon: Icon(Icons.check_box),
                label: Text('Todo', key: Key('nav_todo_label')),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.label_outline, key: Key('nav_tags_icon')),
                selectedIcon: Icon(Icons.label),
                label: Text('Tags', key: Key('nav_tags_label')),
              ),
              NavigationRailDestination(
                icon: Icon(
                  Icons.settings_outlined,
                  key: Key('nav_settings_icon'),
                ),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings', key: Key('nav_settings_label')),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(titles[currentIndex]),
                elevation: 0,
                actions: currentIndex == 0
                    ? [
                        PopupMenuButton<String>(
                          key: const Key('homeMenuButton'),
                          onSelected: (value) {
                            if (value == 'archive') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ArchiveView(),
                                ),
                              );
                            } else if (value == 'trash') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TrashView(),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'archive',
                              child: Row(
                                children: [
                                  Icon(Icons.archive_outlined),
                                  SizedBox(width: 8),
                                  Text('Archive'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'trash',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline),
                                  SizedBox(width: 8),
                                  Text('Trash'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]
                    : null,
              ),
              body: IndexedStack(
                index: currentIndex,
                children: const [TodoTab(), TagsTab(), SettingsTab()],
              ),
              floatingActionButton: currentIndex == 0
                  ? FloatingActionButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddTaskBottomSheet(),
                        );
                      },
                      tooltip: 'Add Task',
                      child: const Icon(Icons.add),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
