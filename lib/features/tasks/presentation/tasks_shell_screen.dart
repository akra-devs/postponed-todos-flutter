import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_icon_tokens.dart';
import '../../../core/theme/app_motion_tokens.dart';
import '../../../core/theme/app_spacing_tokens.dart';
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
              left: AppSpacingTokens.cardInset,
              right: AppSpacingTokens.cardInset,
              top: AppSpacingTokens.listGap,
              bottom:
                  MediaQuery.of(sheetContext).viewInsets.bottom +
                  AppSpacingTokens.cardInset,
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
    final currentScreen = switch (_currentIndex) {
      0 => TasksHomeScreen(
        onViewPostponing: () => _handleTabSelected(1),
        onViewShelved: () => _handleTabSelected(2),
      ),
      1 => const PostponingTasksScreen(),
      _ => const ShelvedTasksScreen(),
    };

    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppMotionTokens.pageTransition,
        switchInCurve: AppMotionTokens.enterCurve,
        switchOutCurve: AppMotionTokens.exitCurve,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: AppMotionTokens.enterCurve,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, AppMotionTokens.shellTabShift),
                end: Offset.zero,
              ).animate(curved),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
                child: child,
              ),
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: currentScreen,
        ),
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
            icon: Icon(AppIconTokens.quickEntryPostponing),
            label: '미루는 중',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIconTokens.quickEntryShelved),
            label: '보관함',
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
