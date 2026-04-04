import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/ui_copy.dart';
import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import '../domain/task.dart';
import '../domain/task_recommendation_service.dart';
import '../domain/task_status.dart';
import 'widgets/home_recommendation_card.dart';
import 'widgets/quick_add_card.dart';
import 'widgets/task_detail_sheet.dart';

class TasksHomeScreen extends StatefulWidget {
  const TasksHomeScreen({super.key});

  @override
  State<TasksHomeScreen> createState() => _TasksHomeScreenState();
}

class _TasksHomeScreenState extends State<TasksHomeScreen> {
  String _lastExposureKey = '';
  String _lastHoldingRevisitExposureKey = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미뤄둔 할일들')),
      body: SafeArea(
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            _recordExposureIfNeeded(context, state.recommendations);
            _recordHoldingRevisitExposureIfNeeded(
              context,
              state.holdingBoxRevisitSuggestions,
            );

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _StatusSummary(),
                const SizedBox(height: 16),
                QuickAddCard(
                  onSubmit: (title, note) => context.read<TasksCubit>().addTask(
                    title: title,
                    note: note,
                  ),
                ),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: '홈 추천',
                  subtitle: '지금 다시 붙잡기 쉬운 일을 먼저 놓아둘게요',
                ),
                const SizedBox(height: 12),
                if (state.recommendations.isEmpty)
                  const _EmptyState(
                    title: '지금은 추천할 일이 없어요',
                    message: '쿨다운이 끝난 일이 생기면 여기에서 다시 꺼내볼 수 있어요.',
                  )
                else
                  ...state.recommendations.map(
                    (recommendation) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HomeRecommendationCard(
                        recommendation: recommendation,
                        onOpen: () =>
                            _openTaskFromHome(context, recommendation.task),
                        onSnooze: () => context.read<TasksCubit>().snooze(
                          recommendation.task,
                        ),
                        onShelf: () =>
                            _confirmShelve(context, recommendation.task),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: '보류함에서 다시 꺼내볼래',
                  subtitle: '한동안 쉬어둔 일 중에서, 다시 붙잡아볼 만한 것만 가볍게 가져왔어요',
                ),
                const SizedBox(height: 12),
                if (state.holdingBoxRevisitSuggestions.isEmpty)
                  const _EmptyState(
                    title: '지금은 조용히 두고 있어요',
                    message: '보류함에 넣은 지 14일이 지난 일만 낮은 강도로 다시 꺼내볼 수 있게 가져와요.',
                  )
                else
                  ...state.holdingBoxRevisitSuggestions.map(
                    (recommendation) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HomeRecommendationCard(
                        recommendation: recommendation,
                        onOpen: () => context
                            .read<TasksCubit>()
                            .confirmHoldingBoxRevisit(recommendation.task),
                        onSnooze: () => context
                            .read<TasksCubit>()
                            .dismissHoldingBoxRevisit(recommendation.task),
                        onShelf: () =>
                            _openDetail(context, recommendation.task),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: '미루는 중',
                  subtitle: '지금 당장 하진 않지만, 아직 붙잡고 있는 일들',
                ),
                const SizedBox(height: 12),
                if (state.postponingTasks.isEmpty)
                  const _EmptyState(
                    title: '아직 넣어둔 일이 없어요',
                    message: '캘린더까지는 아니지만 잊고 싶지 않은 일을 가볍게 적어둘 수 있어요.',
                  )
                else
                  ...state.postponingTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TaskCard(
                        task: task,
                        onTap: () => _openDetail(context, task),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                _SectionHeader(title: '보류함', subtitle: '당분간 거리를 두기로 한 일들'),
                const SizedBox(height: 12),
                if (state.shelvedTasks.isEmpty)
                  const _EmptyState(
                    title: '보류함은 아직 비어 있어요',
                    message: '지금은 잠시 멀리 두고 싶은 일은 보류함으로 옮길 수 있어요.',
                  )
                else
                  ...state.shelvedTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TaskCard(
                        task: task,
                        onTap: () => _openDetail(context, task),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _recordExposureIfNeeded(
    BuildContext context,
    List<TaskRecommendation> recommendations,
  ) {
    final exposureKey = recommendations.map((item) => item.task.id).join(',');
    if (exposureKey.isEmpty) {
      _lastExposureKey = '';
      return;
    }
    if (exposureKey == _lastExposureKey) return;

    _lastExposureKey = exposureKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TasksCubit>().recordRecommendationExposure(recommendations);
    });
  }

  void _recordHoldingRevisitExposureIfNeeded(
    BuildContext context,
    List<TaskRecommendation> suggestions,
  ) {
    final exposureKey = suggestions.map((item) => item.task.id).join(',');
    if (exposureKey.isEmpty) {
      _lastHoldingRevisitExposureKey = '';
      return;
    }
    if (exposureKey == _lastHoldingRevisitExposureKey) return;

    _lastHoldingRevisitExposureKey = exposureKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TasksCubit>().recordHoldingBoxRevisitExposure(suggestions);
    });
  }

  Future<void> _openTaskFromHome(BuildContext context, Task task) async {
    await context.read<TasksCubit>().markTaskInteracted(task);
    if (!context.mounted) return;
    return _openDetail(context, task);
  }

  Future<void> _openDetail(BuildContext context, Task task) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => TaskDetailSheet(taskId: task.id),
    );
  }

  Future<void> _confirmShelve(BuildContext context, Task task) async {
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
        await context.read<TasksCubit>().recordHoldingSuggestionDismissed(task);
      }
      return;
    }
    if (!context.mounted) return;
    await context.read<TasksCubit>().transition(task, TaskStatus.shelved);
  }
}

class _StatusSummary extends StatelessWidget {
  const _StatusSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: '지금 다시 볼 수 있어요',
                value: state.availablePostponingTasks.length,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: '조금 더 두는 중',
                value: state.coolingDownTasks.length,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: '보류함',
                value: state.shelvedTasks.length,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCoolingDown = task.resurfaceAt?.isAfter(DateTime.now()) ?? false;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: theme.textTheme.titleMedium),
              if ((task.note ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(task.note!, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(label: task.status.label),
                  if (isCoolingDown)
                    const _StatusChip(label: '조금 더 둘래 · 다시 보기 대기 중'),
                  if (task.status == TaskStatus.shelved &&
                      task.isEligibleForHoldingBoxRevisitSuggestion)
                    const _StatusChip(label: '다시 꺼내보기 제안 가능'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label),
      ),
    );
  }
}
