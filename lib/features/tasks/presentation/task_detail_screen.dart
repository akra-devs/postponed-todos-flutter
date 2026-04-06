import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/ui_copy.dart';
import '../../../core/theme/app_elevation_tokens.dart';
import '../../../core/theme/app_icon_tokens.dart';
import '../../../core/theme/app_radius_tokens.dart';
import '../../../core/theme/app_spacing_tokens.dart';
import '../../../core/theme/app_theme_ext.dart';
import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import '../domain/task.dart';
import '../domain/task_status.dart';

const _detailSupportPanelRadius = 18.0;
const _detailSupportPanelInset = 14.0;
const _detailActionSectionSpacing = 12.0;

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  static Route<void> route(String taskId) {
    return MaterialPageRoute<void>(
      builder: (_) => TaskDetailScreen(taskId: taskId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('할 일 상세')),
      body: SafeArea(
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            final task = state.tasks
                .where((item) => item.id == taskId)
                .firstOrNull;
            if (task == null) {
              return const Center(child: Text('이 일을 찾을 수 없어요.'));
            }

            final theme = Theme.of(context);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacingTokens.screenInset,
                AppSpacingTokens.listGap,
                AppSpacingTokens.screenInset,
                AppSpacingTokens.sectionGapLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TaskSummaryCard(task: task),
                  if (task.status == TaskStatus.shelved) ...[
                    const SizedBox(height: AppSpacingTokens.cardInset),
                    _ShelvedTaskNotice(task: task),
                  ],
                  if ((task.note ?? '').isNotEmpty) ...[
                    const SizedBox(height: AppSpacingTokens.sectionGap),
                    _InfoSectionCard(
                      title: '메모',
                      child: Text(task.note!, style: theme.appTextRoles.body),
                    ),
                  ],
                  if (task.isHoldingBoxSuggestionCandidate) ...[
                    const SizedBox(height: AppSpacingTokens.sectionGap),
                    const _SuggestionCard(
                      title: UiCopy.holdingSuggestionTitle,
                      description: UiCopy.holdingSuggestionDescription,
                    ),
                  ],
                  if (task.isEligibleForHoldingBoxRevisitSuggestion) ...[
                    const SizedBox(height: AppSpacingTokens.sectionGap),
                    const _SuggestionCard(
                      title: UiCopy.holdingRevisitTitle,
                      description: UiCopy.holdingRevisitDescription,
                    ),
                  ],
                  const SizedBox(height: AppSpacingTokens.sectionGapLarge),
                  ..._buildActionSections(context, task),
                  const SizedBox(height: AppSpacingTokens.sectionGapLarge),
                  _MetaSection(task: task),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildActionSections(BuildContext context, Task task) {
    final cubit = context.read<TasksCubit>();
    final sections = <Widget>[];

    if (task.status == TaskStatus.postponing) {
      sections.add(
        _ActionSection(
          title: '다음 행동',
          description: '지금은 편하게 정지할지, 잠시 보관함으로 옮길지 차분하게 고를 수 있어요.',
          children: [
            _ActionButton(
              label: UiCopy.homeSnooze,
              onPressed: () => cubit.snooze(task),
              emphasis: _ActionEmphasis.primary,
              icon: AppIconTokens.actionSnooze,
              expand: true,
            ),
            const SizedBox(height: AppSpacingTokens.actionGap),
            _ActionButton(
              label: UiCopy.homeHolding,
              onPressed: () => _confirmShelve(context, task, cubit),
              emphasis: _ActionEmphasis.secondary,
              icon: AppIconTokens.actionHold,
              expand: true,
            ),
          ],
        ),
      );
    }

    if (task.status == TaskStatus.shelved) {
      sections.add(
        _ActionSection(
          title: task.isEligibleForHoldingBoxRevisitSuggestion
              ? '다시 꺼내볼 타이밍'
              : '보관함에서 관리',
          description: task.isEligibleForHoldingBoxRevisitSuggestion
              ? '복원을 먼저 두고, 조금 더 둘지 차분하게 고를 수 있게 했어요.'
              : '필요해졌을 때만 다시 꺼내도 괜찮아요.',
          children: [
            _ActionButton(
              label: UiCopy.holdingRestore,
              onPressed: () => task.isEligibleForHoldingBoxRevisitSuggestion
                  ? cubit.confirmHoldingBoxRevisit(task)
                  : cubit.reopenFromShelved(task),
              emphasis: _ActionEmphasis.primary,
              icon: AppIconTokens.actionRestore,
              expand: true,
            ),
            if (task.isEligibleForHoldingBoxRevisitSuggestion) ...[
              const SizedBox(height: AppSpacingTokens.actionGap),
              _ActionButton(
                label: UiCopy.restoreDefer,
                onPressed: () => cubit.dismissHoldingBoxRevisit(task),
                emphasis: _ActionEmphasis.secondary,
                icon: AppIconTokens.actionDefer,
                expand: true,
              ),
            ],
          ],
        ),
      );
    }

    if (!task.status.isClosed) {
      sections.add(
        _ActionSection(
          title: '정리하기',
          description: '이 일의 흐름을 여기서 마감할 수도 있어요.',
          spacing: AppSpacingTokens.actionGap,
          children: [
            Wrap(
              spacing: AppSpacingTokens.actionGap,
              runSpacing: AppSpacingTokens.actionGap,
              children: [
                _ActionButton(
                  label: UiCopy.detailComplete,
                  onPressed: () => _completeTask(context, task, cubit),
                  emphasis: _ActionEmphasis.secondary,
                  icon: AppIconTokens.actionDone,
                ),
                _ActionButton(
                  label: UiCopy.detailDrop,
                  onPressed: () => cubit.transition(task, TaskStatus.dropped),
                  emphasis: _ActionEmphasis.secondary,
                  icon: AppIconTokens.actionDrop,
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (sections.isEmpty) {
      return const [];
    }

    return sections
        .expand(
          (section) => [
            section,
            const SizedBox(height: AppSpacingTokens.cardInset),
          ],
        )
        .toList()
      ..removeLast();
  }

  Future<void> _completeTask(
    BuildContext context,
    Task task,
    TasksCubit cubit,
  ) async {
    await cubit.transition(task, TaskStatus.done);

    if (!context.mounted) {
      return;
    }

    final shouldShowReward = cubit.shouldShowCompletionReward();
    if (!shouldShowReward) {
      return;
    }

    final completedTasks =
        cubit.state.tasks
            .where((item) => item.status == TaskStatus.done)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final fallbackCompleted = task.copyWith(
      status: TaskStatus.done,
      updatedAt: DateTime.now(),
    );

    final hasCurrent = completedTasks.any((item) => item.id == task.id);

    final uniqueCompleted = <String, Task>{
      for (final item in completedTasks) item.id: item,
    };

    if (!hasCurrent) {
      uniqueCompleted[fallbackCompleted.id] = fallbackCompleted;
    }

    final rewards = uniqueCompleted.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) =>
          _CompletionRewardDialog(completedTasks: rewards.take(2).toList()),
    );
  }

  Future<void> _confirmShelve(
    BuildContext context,
    Task task,
    TasksCubit cubit,
  ) async {
    final shouldShelve = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(UiCopy.holdingSuggestionTitle),
        content: const Text(UiCopy.holdingSuggestionDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(UiCopy.holdingCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(UiCopy.homeHolding),
          ),
        ],
      ),
    );

    if (shouldShelve != true) {
      if (context.mounted) {
        await cubit.recordHoldingSuggestionDismissed(task);
      }
      return;
    }
    if (!context.mounted) return;
    await cubit.transition(task, TaskStatus.shelved);
  }
}

class _TaskSummaryCard extends StatelessWidget {
  const _TaskSummaryCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.appSurfaces.card,
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        border: Border.all(
          color: task.status == TaskStatus.shelved
              ? theme.appSurfaces.holdingBorder.withValues(alpha: 0.7)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: AppElevationTokens.cardBlur - 2,
            offset: const Offset(0, AppElevationTokens.heroOffsetY),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.heroInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusPill(label: task.status.label, status: task.status),
            const SizedBox(height: 14),
            Text(task.title, style: theme.appTextRoles.heroTitle),
            const SizedBox(height: AppSpacingTokens.actionGap),
            Text(task.status.description, style: theme.appTextRoles.body),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.status});

  final String label;
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusTokens = theme.appStatus;
    final (background, foreground) = switch (status) {
      TaskStatus.postponing => (
        statusTokens.postponingBg,
        statusTokens.postponingFg,
      ),
      TaskStatus.shelved => (statusTokens.shelvedBg, statusTokens.shelvedFg),
      TaskStatus.done => (statusTokens.doneBg, statusTokens.doneFg),
      TaskStatus.dropped => (statusTokens.droppedBg, statusTokens.droppedFg),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: theme.appTextRoles.emphasisLabel.copyWith(color: foreground),
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _InfoSectionCard(
      title: title,
      child: Text(description, style: theme.appTextRoles.body),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  const _InfoSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.appSurfaces.cardMuted,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.cardInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.appTextRoles.panelTitle),
            const SizedBox(height: AppSpacingTokens.xs),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.title,
    required this.description,
    required this.children,
    this.spacing = _detailActionSectionSpacing,
  });

  final String title;
  final String description;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.appSurfaces.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.cardInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.appTextRoles.cardTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.comfortableTextGap),
            Text(
              description,
              style: theme.appTextRoles.supportingBody.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            SizedBox(height: spacing),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _MetaSection extends StatelessWidget {
  const _MetaSection({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <String>[
      '최근 업데이트: ${_formatDateTime(task.updatedAt)}',
      if (task.resurfaceAt != null)
        '다시 보기 예정: ${_formatDateTime(task.resurfaceAt!)}',
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.appSurfaces.cardMuted,
        borderRadius: BorderRadius.circular(_detailSupportPanelRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_detailSupportPanelInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('기록', style: theme.appTextRoles.panelTitle),
            const SizedBox(height: AppSpacingTokens.xs),
            for (var index = 0; index < rows.length; index++) ...[
              Text(rows[index], style: theme.appTextRoles.supportingBody),
              if (index != rows.length - 1)
                const SizedBox(height: AppSpacingTokens.comfortableTextGap),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}

class _ShelvedTaskNotice extends StatelessWidget {
  const _ShelvedTaskNotice({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.appSurfaces.revisitPanel,
        borderRadius: BorderRadius.circular(_detailSupportPanelRadius),
        border: Border.all(color: theme.appSurfaces.holdingBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_detailSupportPanelInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('보관함에 편하게 내려둔 일이에요', style: theme.appTextRoles.panelTitle),
            const SizedBox(height: AppSpacingTokens.comfortableTextGap),
            Text(
              task.isEligibleForHoldingBoxRevisitSuggestion
                  ? '지금은 다시 꺼내볼 준비가 되어 있는 시점이에요. 원하면 복원해둘 수 있어요.'
                  : '천천히 두는 게 맞는 시기라면 이 상태 그대로 두어도 괜찮아요. 필요해질 때만 복원해보세요.',
              style: theme.appTextRoles.body,
            ),
          ],
        ),
      ),
    );
  }
}

enum _ActionEmphasis { defaultTone, primary, secondary }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.emphasis = _ActionEmphasis.defaultTone,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback onPressed;
  final _ActionEmphasis emphasis;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    Widget buildLabel(String text) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 7)],
          Text(text),
        ],
      );
    }

    final child = switch (emphasis) {
      _ActionEmphasis.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, 52),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        child: buildLabel(label),
      ),
      _ActionEmphasis.secondary => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, 48),
        ),
        child: buildLabel(label),
      ),
      _ActionEmphasis.defaultTone => FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, 48),
        ),
        child: buildLabel(label),
      ),
    };

    if (!expand) {
      return child;
    }

    return SizedBox(width: double.infinity, child: child);
  }
}

class _CompletionRewardDialog extends StatefulWidget {
  const _CompletionRewardDialog({required this.completedTasks});

  final List<Task> completedTasks;

  @override
  State<_CompletionRewardDialog> createState() =>
      _CompletionRewardDialogState();
}

class _CompletionRewardDialogState extends State<_CompletionRewardDialog>
    with SingleTickerProviderStateMixin {
  static const int _particleCount = 8;

  late final AnimationController _controller;
  late final List<_ConfettiParticle> _confettiParticles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _confettiParticles = List.generate(_particleCount, (index) {
      final random = math.Random(index * 17 + 11);
      return _ConfettiParticle(
        xRatio: random.nextDouble(),
        size: 12 + random.nextDouble() * 12,
        startDelay: random.nextDouble() * 0.5,
        travelDistance: 48 + random.nextDouble() * 72,
        drift: random.nextDouble() * 12 - 6,
        spin: random.nextDouble() * 1.2 - 0.6,
        icon: Icons.auto_awesome,
        color: _rewardConfettiPalette[index % _rewardConfettiPalette.length],
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rewardsToShow = widget.completedTasks.take(2).toList();

    return Dialog(
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: _ConfettiBurstLayer(
                    particles: _confettiParticles,
                    controller: _controller,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Text(
                    UiCopy.completionBurstTitle,
                    style: theme.appTextRoles.cardTitle.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    UiCopy.completionBurstMessage,
                    style: theme.appTextRoles.body,
                  ),
                  const SizedBox(height: AppSpacingTokens.listGap),
                  Text(
                    UiCopy.completionRewardTitle,
                    style: theme.appTextRoles.cardTitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    UiCopy.completionRewardHint,
                    style: theme.appTextRoles.supportingBody,
                  ),
                  const SizedBox(height: AppSpacingTokens.actionGap),
                  for (final task in rewardsToShow) ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.appSurfaces.cardMuted,
                        borderRadius: BorderRadius.circular(
                          AppRadiusTokens.pill,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacingTokens.xs,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: theme.appStatus.doneFg,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.title,
                                style: theme.appTextRoles.supportingBody,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: AppSpacingTokens.cardInset),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(UiCopy.completionRewardClose),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiBurstLayer extends StatelessWidget {
  const _ConfettiBurstLayer({
    required this.particles,
    required this.controller,
  });

  final List<_ConfettiParticle> particles;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final progress = Curves.easeOut.transform(controller.value);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (final particle in particles)
                  _ConfettiParticleWidget(
                    particle: particle,
                    containerWidth: constraints.maxWidth,
                    timeline: progress,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ConfettiParticleWidget extends StatelessWidget {
  const _ConfettiParticleWidget({
    required this.particle,
    required this.containerWidth,
    required this.timeline,
  });

  final _ConfettiParticle particle;
  final double containerWidth;
  final double timeline;

  @override
  Widget build(BuildContext context) {
    final life = ((timeline - particle.startDelay) / (1 - particle.startDelay))
        .clamp(0.0, 1.0);

    if (life <= 0.0) {
      return const SizedBox.shrink();
    }

    final offsetY = life * particle.travelDistance;
    final driftX =
        math.sin((life * math.pi * 2) + particle.spin) * particle.drift;
    final opacity = (1.0 - life).clamp(0.0, 1.0);

    return Positioned(
      top: -8 + offsetY,
      left: particle.xRatio * containerWidth + driftX,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: particle.spin * life * 2,
          child: Icon(
            particle.icon,
            size: particle.size * (1 + (1 - life) * 0.2),
            color: particle.color.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.xRatio,
    required this.size,
    required this.startDelay,
    required this.travelDistance,
    required this.drift,
    required this.spin,
    required this.icon,
    required this.color,
  });

  final double xRatio;
  final double size;
  final double startDelay;
  final double travelDistance;
  final double drift;
  final double spin;
  final IconData icon;
  final Color color;
}

const _rewardConfettiPalette = [
  Color(0xFFFFF59D),
  Color(0xFF80CBC4),
  Color(0xFFA5D6A7),
  Color(0xFF90CAF9),
  Color(0xFFE1BEE7),
  Color(0xFFFFCC80),
];
