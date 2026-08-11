import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_icon_tokens.dart';
import '../../../core/theme/app_motion_tokens.dart';
import 'widgets/banner_style_components.dart';
import '../../../core/theme/app_spacing_tokens.dart';
import '../../../core/theme/reentry_atlas_tokens.dart';
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
      1 => PostponingTasksScreen(onAddTask: _openQuickAddSheet),
      _ => ShelvedTasksScreen(onAddTask: _openQuickAddSheet),
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
          final theme = Theme.of(context);
          final atlas = theme.reentryAtlas;
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
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: content,
                  ),
                )
              : content;

          return Scaffold(
            backgroundColor: atlas.midnight,
            body: useNavigationRail
                ? Row(
                    children: [
                      _AtlasNavigationRail(
                        selectedIndex: _currentIndex,
                        onDestinationSelected: _handleTabSelected,
                        onAddTask: _openQuickAddSheet,
                      ),
                      Expanded(child: adaptiveContent),
                    ],
                  )
                : adaptiveContent,
            bottomNavigationBar: useNavigationRail
                ? null
                : _AtlasBottomNavigation(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _handleTabSelected,
                  ),
          );
        },
      ),
    );
  }
}

const _atlasDestinations = <NavigationRailDestination>[
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
];

const _atlasBottomDestinations = <NavigationDestination>[
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
    label: '홈',
  ),
  NavigationDestination(
    icon: Icon(AppIconTokens.quickEntryPostponing),
    label: '미루는 중',
  ),
  NavigationDestination(
    icon: Icon(AppIconTokens.quickEntryShelved),
    label: '보관함',
  ),
];

class _AtlasNavigationRail extends StatelessWidget {
  const _AtlasNavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onAddTask,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: atlas.midnightDeep.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: atlas.onMidnight.withValues(alpha: 0.09)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.34),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: NavigationRail(
              minWidth: 92,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.34,
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 16),
                child: _RailAddOrb(onPressed: onAddTask),
              ),
              destinations: _atlasDestinations,
            ),
          ),
        ),
      ),
    );
  }
}

class _RailAddOrb extends StatelessWidget {
  const _RailAddOrb({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return Tooltip(
      message: '할 일 추가',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [atlas.periwinkle, atlas.periwinkleDeep],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.38),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Icon(Icons.add_rounded, color: atlas.porcelain, size: 30),
          ),
        ),
      ),
    );
  }
}

class _AtlasBottomNavigation extends StatelessWidget {
  const _AtlasBottomNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return ColoredBox(
      color: atlas.midnightDeep,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: atlas.midnightRaised,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: atlas.onMidnight.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: NavigationBar(
              height: 68,
              backgroundColor: Colors.transparent,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: _atlasBottomDestinations,
            ),
          ),
        ),
      ),
    );
  }
}
