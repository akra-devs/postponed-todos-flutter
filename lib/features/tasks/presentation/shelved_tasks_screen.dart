import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_icon_tokens.dart';
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

class ShelvedTasksScreen extends StatelessWidget {
  const ShelvedTasksScreen({super.key, this.onAddTask});

  final VoidCallback? onAddTask;

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

              final tasks = state.shelvedTasks;
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
                        padding: EdgeInsets.fromLTRB(inset, 24, inset, 58),
                        children: [
                          if (wide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 292,
                                  child: _HoldingEditorialLead(
                                    isEmpty: tasks.isEmpty,
                                    onAddTask: tasks.isEmpty ? null : onAddTask,
                                    compact: false,
                                  ),
                                ),
                                const SizedBox(width: 34),
                                Expanded(
                                  child: _HoldingCabinet(
                                    tasks: tasks,
                                    onAddTask: onAddTask,
                                    onOpen: (task) => Navigator.of(
                                      context,
                                    ).push(TaskDetailScreen.route(task.id)),
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _HoldingEditorialLead(
                              isEmpty: tasks.isEmpty,
                              onAddTask: null,
                              compact: true,
                            ),
                            const SizedBox(height: 30),
                            _HoldingCabinet(
                              tasks: tasks,
                              onAddTask: onAddTask,
                              onOpen: (task) => Navigator.of(
                                context,
                              ).push(TaskDetailScreen.route(task.id)),
                            ),
                            if (tasks.isNotEmpty && onAddTask != null) ...[
                              const SizedBox(height: AppSpacingTokens.xl),
                              ReentryAddButton(onPressed: onAddTask!),
                            ],
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
}

class _HoldingEditorialLead extends StatelessWidget {
  const _HoldingEditorialLead({
    required this.isEmpty,
    required this.onAddTask,
    required this.compact,
  });

  final bool isEmpty;
  final VoidCallback? onAddTask;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Semantics(
      container: true,
      label:
          '보관함. 잠시 쉬어두는 선반. 보관함은 포기한 곳이 아니라, 지금 당장 붙잡지 않아도 되는 일을 편안히 두는 자리예요.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '보관함',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: atlas.onMidnight,
              fontSize: compact ? 36 : 44,
              height: 1.04,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            '마음에 둔 일들',
            style: theme.textTheme.titleLarge?.copyWith(
              color: atlas.onMidnightMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: compact ? AppSpacingTokens.xl : 38),
          _HoldingLeadMedallion(compact: compact),
          const SizedBox(height: AppSpacingTokens.lg),
          Text(
            '잠시 쉬어두는 선반',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: atlas.onMidnight,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.45,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              '지금 당장 붙잡지 않아도 되는 일을 편안히 두는 자리예요. 준비가 되면 조용히 다시 꺼내면 됩니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: atlas.onMidnightMuted,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.xl),
          Text(
            isEmpty ? '지금은 조용히 쉬는 칸' : '안전하게 내려둔 일들',
            style: theme.textTheme.titleMedium?.copyWith(
              color: atlas.mint,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          Text(
            '급하게 밀어올리지 않고, 준비될 때 다시 꺼낼 수 있게 차분히 보관해둔 목록이에요.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: atlas.onMidnightMuted,
              height: 1.45,
            ),
          ),
          if (onAddTask != null) ...[
            const SizedBox(height: 30),
            ReentryAddButton(onPressed: onAddTask!),
          ],
        ],
      ),
    );
  }
}

class _HoldingLeadMedallion extends StatelessWidget {
  const _HoldingLeadMedallion({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    final size = compact ? 72.0 : 88.0;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: atlas.porcelain,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.36),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.42),
            colors: [Color.lerp(atlas.mint, Colors.white, 0.4)!, atlas.mint],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        ),
        child: Icon(
          AppIconTokens.quickEntryShelved,
          color: atlas.ink.withValues(alpha: 0.7),
          size: compact ? 30 : 36,
        ),
      ),
    );
  }
}

class _HoldingCabinet extends StatelessWidget {
  const _HoldingCabinet({
    required this.tasks,
    required this.onOpen,
    this.onAddTask,
  });

  final List<Task> tasks;
  final ValueChanged<Task> onOpen;
  final VoidCallback? onAddTask;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return PhysicalShape(
      clipper: const _HoldingCabinetClipper(),
      color: atlas.porcelain,
      shadowColor: Colors.black.withValues(alpha: 0.64),
      elevation: 18,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 9, 8, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: atlas.midnightDeep,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              const SizedBox(height: 34),
              _CabinetCrown(isEmpty: tasks.isEmpty),
              const SizedBox(height: AppSpacingTokens.lg),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: tasks.isEmpty
                    ? _EmptyCabinetShelf(onAddTask: onAddTask)
                    : _FilledCabinetShelf(tasks: tasks, onOpen: onOpen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CabinetCrown extends StatelessWidget {
  const _CabinetCrown({required this.isEmpty});

  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: atlas.porcelainLow,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.34),
                blurRadius: 11,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEmpty ? atlas.porcelain : atlas.mint,
              border: Border.all(color: Colors.white.withValues(alpha: 0.58)),
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              color: atlas.inkMuted,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Text(
          isEmpty ? '비워둔 선반' : '마음에 둔 일들',
          style: theme.textTheme.labelLarge?.copyWith(
            color: atlas.onMidnight,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptyCabinetShelf extends StatelessWidget {
  const _EmptyCabinetShelf({this.onAddTask});

  final VoidCallback? onAddTask;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return Column(
      children: [
        _ShelfLedge(color: atlas.porcelain),
        const SizedBox(height: AppSpacingTokens.md),
        TaskEmptyStateCard(
          title: '아직 보관할 일이 없어요',
          message: '마음이 아직 정리되지 않은 일은 여기로 잠시 옮겨둘 수 있어요. 필요해질 때 다시 꺼내면 돼요.',
          actionLabel: onAddTask == null ? null : '떠오른 일 남기기',
          onAction: onAddTask,
          tone: TaskEmptyStateTone.holding,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _ShelfLedge(color: atlas.porcelainLow),
        const SizedBox(height: AppSpacingTokens.sm),
        SizedBox(
          height: 88,
          width: double.infinity,
          child: ExcludeSemantics(
            child: CustomPaint(
              painter: _EmptyShelfEchoPainter(
                porcelain: atlas.porcelain,
                mint: atlas.mint,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilledCabinetShelf extends StatelessWidget {
  const _FilledCabinetShelf({required this.tasks, required this.onOpen});

  final List<Task> tasks;
  final ValueChanged<Task> onOpen;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return Column(
      children: [
        _ShelfLedge(color: atlas.porcelain),
        const SizedBox(height: AppSpacingTokens.md),
        for (var index = 0; index < tasks.length; index++) ...[
          StaggeredRevealCard(
            index: index,
            child: TaskListCard(
              task: tasks[index],
              onTap: () => onOpen(tasks[index]),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          _ShelfLedge(
            color: index.isEven ? atlas.porcelain : atlas.porcelainLow,
          ),
          if (index != tasks.length - 1)
            const SizedBox(height: AppSpacingTokens.md),
        ],
      ],
    );
  }
}

class _ShelfLedge extends StatelessWidget {
  const _ShelfLedge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return Container(
      height: 11,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, Colors.white, 0.3)!, color],
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.38),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: atlas.onMidnight.withValues(alpha: 0.12),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
    );
  }
}

class _HoldingCabinetClipper extends CustomClipper<Path> {
  const _HoldingCabinetClipper();

  @override
  Path getClip(Size size) {
    const bottomRadius = 30.0;
    final crownY = math.min(66.0, size.height * 0.13);
    return Path()
      ..moveTo(0, crownY + 18)
      ..quadraticBezierTo(0, crownY, 18, crownY)
      ..lineTo(size.width * 0.3, crownY)
      ..cubicTo(
        size.width * 0.37,
        crownY,
        size.width * 0.38,
        0,
        size.width * 0.5,
        0,
      )
      ..cubicTo(
        size.width * 0.62,
        0,
        size.width * 0.63,
        crownY,
        size.width * 0.7,
        crownY,
      )
      ..lineTo(size.width - 18, crownY)
      ..quadraticBezierTo(size.width, crownY, size.width, crownY + 18)
      ..lineTo(size.width, size.height - bottomRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - bottomRadius,
        size.height,
      )
      ..lineTo(bottomRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - bottomRadius)
      ..close();
  }

  @override
  bool shouldReclip(covariant _HoldingCabinetClipper oldClipper) => false;
}

class _EmptyShelfEchoPainter extends CustomPainter {
  const _EmptyShelfEchoPainter({required this.porcelain, required this.mint});

  final Color porcelain;
  final Color mint;

  @override
  void paint(Canvas canvas, Size size) {
    final left = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.12, 18, size.width * 0.35, 50),
      const Radius.circular(16),
    );
    final right = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.52, 8, size.width * 0.34, 56),
      const Radius.circular(16),
    );
    canvas.drawRRect(left, Paint()..color = porcelain.withValues(alpha: 0.11));
    canvas.drawRRect(right, Paint()..color = porcelain.withValues(alpha: 0.07));
    canvas.drawCircle(
      Offset(size.width * 0.18, 18),
      10,
      Paint()..color = mint.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, 8),
      8,
      Paint()..color = porcelain.withValues(alpha: 0.16),
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyShelfEchoPainter oldDelegate) =>
      oldDelegate.porcelain != porcelain || oldDelegate.mint != mint;
}
