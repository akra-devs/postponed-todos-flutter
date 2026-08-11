import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_icon_tokens.dart';
import '../../../core/theme/app_motion_tokens.dart';
import 'widgets/banner_style_components.dart';
import '../../../core/theme/app_spacing_tokens.dart';
import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
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
                  final created = await cubit.addTask(title: title, note: note);
                  if (created && sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                  return created;
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
        onAddTask: _openQuickAddSheet,
      ),
      1 => const PostponingTasksScreen(),
      _ => const ShelvedTasksScreen(),
    };

    return BlocListener<TasksCubit, TasksState>(
      listenWhen: (previous, current) =>
          previous.operationFailure != current.operationFailure &&
          current.operationFailure != null,
      listener: (context, state) {
        final failure = state.operationFailure;
        if (failure == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(failure.message)));
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useNavigationRail = constraints.maxWidth >= 840;
          final content = BannerMotionSwitcher(
            duration: AppMotionTokens.pageTransition,
            enterCurve: AppMotionTokens.enterCurve,
            exitCurve: AppMotionTokens.exitCurve,
            beginOffset: Offset(0, AppMotionTokens.shellTabShift),
            scaleFrom: 0.985,
            scaleTo: 1.0,
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: currentScreen,
            ),
          );
          final adaptiveContent = useNavigationRail
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: content,
                  ),
                )
              : content;

          return Scaffold(
            body: useNavigationRail
                ? Row(
                    children: [
                      SafeArea(
                        child: NavigationRail(
                          selectedIndex: _currentIndex,
                          onDestinationSelected: _handleTabSelected,
                          labelType: NavigationRailLabelType.all,
                          leading: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: FloatingActionButton.small(
                              tooltip: '할 일 추가',
                              onPressed: _openQuickAddSheet,
                              child: const Icon(Icons.add),
                            ),
                          ),
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.home_outlined),
                              selectedIcon: Icon(Icons.home_rounded),
                              label: Text('홈'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(AppIconTokens.quickEntryPostponing),
                              label: Text('미루는 중'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(AppIconTokens.quickEntryShelved),
                              label: Text('보관함'),
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: adaptiveContent),
                    ],
                  )
                : adaptiveContent,
            bottomNavigationBar: useNavigationRail
                ? null
                : BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: _handleTabSelected,
                    type: BottomNavigationBarType.fixed,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_rounded),
                        label: '홈',
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
            floatingActionButton: useNavigationRail
                ? null
                : FloatingActionButton(
                    tooltip: '할 일 추가',
                    onPressed: _openQuickAddSheet,
                    child: const Icon(Icons.add),
                  ),
          );
        },
      ),
    );
  }
}
