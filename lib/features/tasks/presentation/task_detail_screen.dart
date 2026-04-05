import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/ui_copy.dart';
import '../../../core/theme/app_elevation_tokens.dart';
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
          description: '지금은 유지할지, 잠시 보류함으로 옮길지 정할 수 있어요.',
          children: [
            _ActionButton(
              label: UiCopy.homeSnooze,
              onPressed: () => cubit.snooze(task),
              emphasis: _ActionEmphasis.primary,
              expand: true,
            ),
            const SizedBox(height: AppSpacingTokens.actionGap),
            _ActionButton(
              label: UiCopy.homeHolding,
              onPressed: () => _confirmShelve(context, task, cubit),
              emphasis: _ActionEmphasis.secondary,
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
              : '보류함에서 관리',
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
              expand: true,
            ),
            if (task.isEligibleForHoldingBoxRevisitSuggestion) ...[
              const SizedBox(height: AppSpacingTokens.actionGap),
              _ActionButton(
                label: UiCopy.restoreDefer,
                onPressed: () => cubit.dismissHoldingBoxRevisit(task),
                emphasis: _ActionEmphasis.secondary,
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
                  onPressed: () => cubit.transition(task, TaskStatus.done),
                  emphasis: _ActionEmphasis.secondary,
                ),
                _ActionButton(
                  label: UiCopy.detailDrop,
                  onPressed: () => cubit.transition(task, TaskStatus.dropped),
                  emphasis: _ActionEmphasis.secondary,
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
            Text('보류함에 잠시 내려둔 일이에요', style: theme.appTextRoles.panelTitle),
            const SizedBox(height: AppSpacingTokens.comfortableTextGap),
            Text(
              task.isEligibleForHoldingBoxRevisitSuggestion
                  ? '지금은 다시 꺼내보기 괜찮은 시점이라, 복원 버튼을 먼저 두었어요.'
                  : '급하지 않다면 이대로 둬도 괜찮아요. 필요해질 때 복원하면 다시 미루는 중으로 돌아가요.',
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
    this.expand = false,
  });

  final String label;
  final VoidCallback onPressed;
  final _ActionEmphasis emphasis;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = switch (emphasis) {
      _ActionEmphasis.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, 52),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
      _ActionEmphasis.secondary => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, 48),
        ),
        child: Text(label),
      ),
      _ActionEmphasis.defaultTone => FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, 48),
        ),
        child: Text(label),
      ),
    };

    if (!expand) {
      return child;
    }

    return SizedBox(width: double.infinity, child: child);
  }
}
