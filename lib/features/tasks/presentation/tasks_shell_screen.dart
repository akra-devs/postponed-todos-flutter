import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/tasks_cubit.dart';
import 'postponing_tasks_screen.dart';
import 'shelved_tasks_screen.dart';
import 'tasks_home_screen.dart';
import 'widgets/quick_add_card.dart';

class TasksShellScreen extends StatefulWidget {
  const TasksShellScreen({super.key});

  @override
  State<TasksShellScreen> createState() => _TasksShellScreenState();
}

class _TasksShellScreenState extends State<TasksShellScreen> {
  int _currentIndex = 0;

  void _handleTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  Future<void> _openQuickAddSheet() {
    final cubit = context.read<TasksCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: QuickAddCard(
                onSubmit: (title, note) async {
                  await cubit.addTask(title: title, note: note);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TasksHomeScreen(
            onViewPostponing: () => _handleTabSelected(1),
            onViewShelved: () => _handleTabSelected(2),
          ),
          const PostponingTasksScreen(),
          const ShelvedTasksScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleTabSelected,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_rounded),
            label: '미루는 중',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_rounded),
            label: '보류함',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openQuickAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
