import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_radius_tokens.dart';
import '../../../core/theme/app_spacing_tokens.dart';
import '../../../core/theme/reentry_atlas_tokens.dart';
import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import '../domain/task.dart';
import 'task_detail_screen.dart';
import 'widgets/banner_style_components.dart';
import 'widgets/reentry_atlas_components.dart';
import 'widgets/task_empty_state_card.dart';
import 'widgets/task_list_card.dart';

class PostponingTasksScreen extends StatefulWidget {
  const PostponingTasksScreen({super.key, this.onAddTask});

  final VoidCallback? onAddTask;

  @override
  State<PostponingTasksScreen> createState() => _PostponingTasksScreenState();
}

class _PostponingTasksScreenState extends State<PostponingTasksScreen> {
  _PostponingFilter _selectedFilter = _PostponingFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ReentryAtlasBackdrop(
        child: SafeArea(
          bottom: false,
          child: BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final visibleTasks = switch (_selectedFilter) {
                _PostponingFilter.all => state.postponingTasks,
                _PostponingFilter.available => state.availablePostponingTasks,
                _PostponingFilter.coolingDown => state.coolingDownTasks,
              };

              return LayoutBuilder(
                builder: (context, constraints) {
                  final canvasWidth = math.min(constraints.maxWidth, 1080.0);
                  final wide = canvasWidth >= 760;
                  final inset = wide ? 32.0 : AppSpacingTokens.screenInset;
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: canvasWidth,
                      height: constraints.maxHeight,
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(inset, 24, inset, 56),
                        children: [
                          _PostponingHero(wide: wide),
                          SizedBox(height: wide ? 30 : AppSpacingTokens.lg),
                          if (wide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 252,
                                  child: _PostponingControlRail(
                                    selectedFilter: _selectedFilter,
                                    totalCount: state.postponingTasks.length,
                                    availableCount:
                                        state.availablePostponingTasks.length,
                                    coolingCount: state.coolingDownTasks.length,
                                    onSelected: _selectFilter,
                                    onAddTask: widget.onAddTask,
                                  ),
                                ),
                                const SizedBox(width: AppSpacingTokens.xl),
                                Expanded(
                                  child: _PostponingRouteBody(
                                    filter: _selectedFilter,
                                    tasks: visibleTasks,
                                    totalCount: state.postponingTasks.length,
                                    onAddTask: widget.onAddTask,
                                    showAddButton: false,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _PostponingFilterDeck(
                              selectedFilter: _selectedFilter,
                              totalCount: state.postponingTasks.length,
                              availableCount:
                                  state.availablePostponingTasks.length,
                              coolingCount: state.coolingDownTasks.length,
                              onSelected: _selectFilter,
                              vertical: false,
                            ),
                            const SizedBox(height: AppSpacingTokens.xl),
                            _PostponingRouteBody(
                              filter: _selectedFilter,
                              tasks: visibleTasks,
                              totalCount: state.postponingTasks.length,
                              onAddTask: widget.onAddTask,
                              showAddButton: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _selectFilter(_PostponingFilter filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
  }
}

enum _PostponingFilter {
  all(
    label: '전체',
    listTitle: '붙잡고 있는 일 전체',
    emptyTitle: '아직 넣어둔 일이 없어요',
    emptyMessage: '캘린더까지는 아니지만 잊고 싶지 않은 일을 가볍게 적어둘 수 있어요.',
  ),
  available(
    label: '지금 다시 보기 쉬운',
    listTitle: '지금 다시 보기 쉬운 일',
    emptyTitle: '지금 다시 볼 일이 비어 있어요',
    emptyMessage: '조금 더 시간이 지난 뒤에 다시 떠오를 일이 생기면 여기서 가볍게 훑어볼 수 있어요.',
  ),
  coolingDown(
    label: '조금 더 두는 중',
    listTitle: '조금 더 두는 중인 일',
    emptyTitle: '조금 더 둘 일은 없어요',
    emptyMessage: '지금은 쉬게 두고 있는 일이 없어서, 화면이 한결 가볍게 비어 있어요.',
  );

  const _PostponingFilter({
    required this.label,
    required this.listTitle,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final String label;
  final String listTitle;
  final String emptyTitle;
  final String emptyMessage;

  String listDescription({required int totalCount, required int visibleCount}) {
    return switch (this) {
      _PostponingFilter.all =>
        totalCount == 0
            ? '지금 당장 하진 않지만, 아직 붙잡고 있는 일들을 한 곳에 담아두고 있어요.'
            : '한 곳에서 천천히 훑고, 지금 다룰 순서를 정할 수 있어요.',
      _PostponingFilter.available =>
        visibleCount == 0
            ? '지금은 바로 다시 볼 일들이 없어도 괜찮아요. 조금 기다려도 돼요.'
            : '지금 다시 보기 쉬운 항목만 골라서 보여주는 흐름이에요.',
      _PostponingFilter.coolingDown =>
        visibleCount == 0
            ? '지금은 잠깐 쉬어가는 항목이 비어 있어요. 화면이 가볍네요.'
            : '잠시 쉬어가는 항목은 천천히 다시 올릴 준비를 기다리는 흐름이에요.',
    };
  }

  int count({
    required int total,
    required int available,
    required int cooling,
  }) {
    return switch (this) {
      _PostponingFilter.all => total,
      _PostponingFilter.available => available,
      _PostponingFilter.coolingDown => cooling,
    };
  }
}

class _PostponingHero extends StatelessWidget {
  const _PostponingHero({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Semantics(
      header: true,
      label: '미루는 중. 서두르지 않아도 괜찮아요.',
      child: SizedBox(
        height: wide ? 228 : 242,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: CustomPaint(
                  painter: _PostponingHeroRoutePainter(
                    route: atlas.route,
                    periwinkle: atlas.periwinkle,
                    porcelain: atlas.porcelain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              right: wide ? 320 : 62,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '미루는 중',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: atlas.onMidnight,
                      fontSize: wide ? 44 : 36,
                      height: 1.04,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    '서두르지 않아도 괜찮아요',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: atlas.onMidnightMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              bottom: wide ? 16 : 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: atlas.midnightSoft.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.26),
                      blurRadius: 13,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    '가까운 일부터, 천천히 다시 닿기',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: atlas.onMidnight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostponingControlRail extends StatelessWidget {
  const _PostponingControlRail({
    required this.selectedFilter,
    required this.totalCount,
    required this.availableCount,
    required this.coolingCount,
    required this.onSelected,
    this.onAddTask,
  });

  final _PostponingFilter selectedFilter;
  final int totalCount;
  final int availableCount;
  final int coolingCount;
  final ValueChanged<_PostponingFilter> onSelected;
  final VoidCallback? onAddTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReentryPorcelainTicket(
          elevation: 10,
          notchPosition: 0.34,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '지금의 결을 고르기',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: atlas.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xs),
                Text(
                  '보고 싶은 온도만 남겨둘게요.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: atlas.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.lg),
                _PostponingFilterDeck(
                  selectedFilter: selectedFilter,
                  totalCount: totalCount,
                  availableCount: availableCount,
                  coolingCount: coolingCount,
                  onSelected: onSelected,
                  vertical: true,
                ),
              ],
            ),
          ),
        ),
        if (onAddTask != null) ...[
          const SizedBox(height: AppSpacingTokens.lg),
          ReentryAddButton(onPressed: onAddTask!),
        ],
      ],
    );
  }
}

class _PostponingFilterDeck extends StatelessWidget {
  const _PostponingFilterDeck({
    required this.selectedFilter,
    required this.totalCount,
    required this.availableCount,
    required this.coolingCount,
    required this.onSelected,
    required this.vertical,
  });

  final _PostponingFilter selectedFilter;
  final int totalCount;
  final int availableCount;
  final int coolingCount;
  final ValueChanged<_PostponingFilter> onSelected;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    final chips = _PostponingFilter.values
        .map((filter) {
          final selected = filter == selectedFilter;
          final count = filter.count(
            total: totalCount,
            available: availableCount,
            cooling: coolingCount,
          );
          final filterLabel = Text(
            filter.label,
            maxLines: vertical ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          );
          final label = Row(
            mainAxisSize: vertical ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (vertical) Expanded(child: filterLabel) else filterLabel,
              const SizedBox(width: AppSpacingTokens.xs),
              Container(
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? atlas.porcelain.withValues(alpha: 0.2)
                      : atlas.periwinkleSoft,
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? atlas.porcelain : atlas.periwinkleDeep,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          );
          final chip = ChoiceChip(
            label: vertical ? SizedBox(width: 144, child: label) : label,
            selected: selected,
            onSelected: (_) => onSelected(filter),
            showCheckmark: false,
            selectedColor: atlas.periwinkleDeep,
            backgroundColor: atlas.porcelain,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadiusTokens.md),
            ),
            labelStyle: theme.textTheme.labelMedium?.copyWith(
              color: selected ? atlas.porcelain : atlas.inkMuted,
              fontWeight: FontWeight.w800,
            ),
          );
          return vertical
              ? Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacingTokens.xs),
                  child: chip,
                )
              : chip;
        })
        .toList(growable: false);

    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: chips,
      );
    }
    return Wrap(
      spacing: AppSpacingTokens.xs,
      runSpacing: AppSpacingTokens.xs,
      children: chips,
    );
  }
}

class _PostponingRouteBody extends StatelessWidget {
  const _PostponingRouteBody({
    required this.filter,
    required this.tasks,
    required this.totalCount,
    required this.onAddTask,
    required this.showAddButton,
  });

  final _PostponingFilter filter;
  final List<Task> tasks;
  final int totalCount;
  final VoidCallback? onAddTask;
  final bool showAddButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filter.listTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: atlas.onMidnight,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(height: AppSpacingTokens.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            filter.listDescription(
              totalCount: totalCount,
              visibleCount: tasks.length,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: atlas.onMidnightMuted,
              height: 1.48,
            ),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        if (tasks.isEmpty)
          _PostponingEmptyStage(
            title: filter.emptyTitle,
            message: filter.emptyMessage,
            onAddTask: showAddButton ? onAddTask : null,
          )
        else
          _PostponingTaskStage(
            tasks: tasks,
            onOpen: (task) =>
                Navigator.of(context).push(TaskDetailScreen.route(task.id)),
          ),
        if (tasks.isNotEmpty && showAddButton && onAddTask != null) ...[
          const SizedBox(height: AppSpacingTokens.lg),
          ReentryAddButton(onPressed: onAddTask!),
        ],
      ],
    );
  }
}

class _PostponingEmptyStage extends StatelessWidget {
  const _PostponingEmptyStage({
    required this.title,
    required this.message,
    this.onAddTask,
  });

  final String title;
  final String message;
  final VoidCallback? onAddTask;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return _RouteStageShell(
      minimumHeight: 420,
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(
                painter: _EmptyRouteStagePainter(
                  route: atlas.route,
                  accent: atlas.periwinkle,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 98, 20, 22),
              child: TaskEmptyStateCard(
                title: title,
                message: message,
                actionLabel: onAddTask == null ? null : '떠오른 일 남기기',
                onAction: onAddTask,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostponingTaskStage extends StatelessWidget {
  const _PostponingTaskStage({required this.tasks, required this.onOpen});

  final List<Task> tasks;
  final ValueChanged<Task> onOpen;

  @override
  Widget build(BuildContext context) {
    return _RouteStageShell(
      minimumHeight: 260,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 20, 18),
        child: Column(
          children: [
            for (var index = 0; index < tasks.length; index++)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacingTokens.listGap,
                ),
                child: StaggeredRevealCard(
                  index: index,
                  child: _TimelineTaskRow(
                    active: index == 0,
                    isLast: index == tasks.length - 1,
                    child: TaskListCard(
                      task: tasks[index],
                      onTap: () => onOpen(tasks[index]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RouteStageShell extends StatelessWidget {
  const _RouteStageShell({required this.child, required this.minimumHeight});

  final Widget child;
  final double minimumHeight;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minimumHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: atlas.midnightRaised.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: atlas.onMidnight.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(30), child: child),
      ),
    );
  }
}

class _TimelineTaskRow extends StatelessWidget {
  const _TimelineTaskRow({
    required this.active,
    required this.isLast,
    required this.child,
  });

  final bool active;
  final bool isLast;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 54,
            child: CustomPaint(
              painter: _TimelineRailPainter(
                active: active,
                isLast: isLast,
                routeColor: atlas.route,
                nodeColor: active ? atlas.periwinkle : atlas.porcelain,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _PostponingHeroRoutePainter extends CustomPainter {
  const _PostponingHeroRoutePainter({
    required this.route,
    required this.periwinkle,
    required this.porcelain,
  });

  final Color route;
  final Color periwinkle;
  final Color porcelain;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.22, size.height + 18)
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.82,
        size.width * 0.48,
        size.height * 0.7,
        size.width * 0.62,
        size.height * 0.7,
      )
      ..cubicTo(
        size.width * 0.8,
        size.height * 0.7,
        size.width * 0.78,
        size.height * 0.28,
        size.width + 26,
        size.height * 0.18,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 21
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = route
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.54)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    _drawNode(
      canvas,
      Offset(size.width * 0.48, size.height * 0.76),
      24,
      periwinkle,
    );
    _drawNode(
      canvas,
      Offset(size.width * 0.76, size.height * 0.58),
      19,
      porcelain,
    );
    _drawNode(
      canvas,
      Offset(size.width * 0.92, size.height * 0.28),
      27,
      porcelain,
    );
  }

  void _drawNode(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center.translate(0, 6),
      radius + 5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.34)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(center, radius + 3, Paint()..color = route);
    canvas.drawCircle(center, radius, Paint()..color = color);
    canvas.drawCircle(
      center.translate(-radius * 0.28, -radius * 0.34),
      radius * 0.27,
      Paint()..color = Colors.white.withValues(alpha: 0.42),
    );
  }

  @override
  bool shouldRepaint(covariant _PostponingHeroRoutePainter oldDelegate) =>
      oldDelegate.route != route ||
      oldDelegate.periwinkle != periwinkle ||
      oldDelegate.porcelain != porcelain;
}

class _EmptyRouteStagePainter extends CustomPainter {
  const _EmptyRouteStagePainter({required this.route, required this.accent});

  final Color route;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(-22, size.height * 0.26)
      ..cubicTo(
        size.width * 0.16,
        size.height * 0.08,
        size.width * 0.38,
        size.height * 0.34,
        size.width * 0.54,
        size.height * 0.2,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.08,
        size.width * 0.82,
        size.height * 0.14,
        size.width + 24,
        size.height * 0.04,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 17
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = route
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
    );
    final center = Offset(size.width * 0.54, size.height * 0.2);
    canvas.drawCircle(center, 19, Paint()..color = route);
    canvas.drawCircle(center, 13, Paint()..color = accent);
    canvas.drawCircle(
      center.translate(-4, -5),
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.48),
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyRouteStagePainter oldDelegate) =>
      oldDelegate.route != route || oldDelegate.accent != accent;
}

class _TimelineRailPainter extends CustomPainter {
  const _TimelineRailPainter({
    required this.active,
    required this.isLast,
    required this.routeColor,
    required this.nodeColor,
  });

  final bool active;
  final bool isLast;
  final Color routeColor;
  final Color nodeColor;

  @override
  void paint(Canvas canvas, Size size) {
    const center = Offset(26, 34);
    if (!isLast) {
      canvas.drawLine(
        center,
        Offset(center.dx, size.height + 12),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.34)
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawLine(
        center,
        Offset(center.dx, size.height + 12),
        Paint()
          ..color = routeColor
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(
      center.translate(0, 5),
      21,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.36)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(center, 19, Paint()..color = routeColor);
    canvas.drawCircle(center, 13, Paint()..color = nodeColor);
    canvas.drawCircle(
      center.translate(-4, -5),
      4,
      Paint()..color = Colors.white.withValues(alpha: 0.42),
    );
  }

  @override
  bool shouldRepaint(covariant _TimelineRailPainter oldDelegate) =>
      oldDelegate.active != active ||
      oldDelegate.isLast != isLast ||
      oldDelegate.routeColor != routeColor ||
      oldDelegate.nodeColor != nodeColor;
}
