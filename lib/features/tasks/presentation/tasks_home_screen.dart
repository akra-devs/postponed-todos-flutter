import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/ui_copy.dart';
import '../../../core/theme/app_icon_tokens.dart';
import '../../../core/theme/app_spacing_tokens.dart';
import '../../../core/theme/app_theme_ext.dart';
import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import '../domain/task.dart';
import '../domain/task_recommendation_service.dart';
import '../domain/task_status.dart';
import 'widgets/home_recommendation_card.dart';
import 'widgets/task_empty_state_card.dart';
import 'task_detail_screen.dart';

class TasksHomeScreen extends StatefulWidget {
  const TasksHomeScreen({super.key, this.onViewPostponing, this.onViewShelved});

  final VoidCallback? onViewPostponing;
  final VoidCallback? onViewShelved;

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
              padding: const EdgeInsets.all(AppSpacingTokens.screenInset),
              children: [
                _QuickEntrySection(
                  onViewPostponing: widget.onViewPostponing,
                  onViewShelved: widget.onViewShelved,
                ),
                const SizedBox(height: AppSpacingTokens.sectionGap),
                const _SectionHeader(
                  title: '홈 추천',
                  subtitle: '지금 다시 붙잡기 쉬운 일을 먼저 놓아둘게요',
                ),
                const SizedBox(height: AppSpacingTokens.listGap),
                if (state.recommendations.isEmpty)
                  const TaskEmptyStateCard(
                    title: '지금은 추천할 일이 없어요',
                    message: '쿨다운이 끝난 일이 생기면 여기에서 다시 꺼내볼 수 있어요.',
                  )
                else
                  ...state.recommendations.map(
                    (recommendation) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.listGap,
                      ),
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
                const SizedBox(height: AppSpacingTokens.sectionGapLarge),
                const _SectionHeader(
                  title: '보관함에서 다시 꺼내볼래',
                  subtitle: '한동안 쉬어둔 일 중에서, 다시 붙잡아볼 만한 것만 가볍게 가져왔어요',
                ),
                const SizedBox(height: AppSpacingTokens.listGap),
                if (state.holdingBoxRevisitSuggestions.isEmpty)
                  const TaskEmptyStateCard(
                    title: '지금은 조용히 두고 있어요',
                    message: '보관함에 넣은 지 14일이 지난 일만 낮은 강도로 다시 꺼내볼 수 있게 가져와요.',
                  )
                else
                  ...state.holdingBoxRevisitSuggestions.map(
                    (recommendation) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.listGap,
                      ),
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
    return Navigator.of(context).push(TaskDetailScreen.route(task.id));
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

class _QuickEntrySection extends StatelessWidget {
  const _QuickEntrySection({
    required this.onViewPostponing,
    required this.onViewShelved,
  });

  final VoidCallback? onViewPostponing;
  final VoidCallback? onViewShelved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('목록 바로가기', style: theme.appTextRoles.cardTitle),
        const SizedBox(height: AppSpacingTokens.eyebrowGap),
        Text(
          '필요한 순간에만 가볍게 다시 여는 공간이에요',
          style: theme.appTextRoles.supportingBody,
        ),
        const SizedBox(height: AppSpacingTokens.listGap),
        BlocBuilder<TasksCubit, TasksState>(
          builder: (context, _) {
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewPostponing,
                    child: _QuickEntryButtonContent(
                      label: '미루는 중',
                      detail: '가볍게 훑어보기 좋을 때로 남겨둔 목록',
                      icon: AppIconTokens.quickEntryPostponing,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.listGap),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewShelved,
                    child: _QuickEntryButtonContent(
                      label: '보관함',
                      detail: '급하게 밀어올리지 않고 안전하게 쉬어두는 자리',
                      icon: AppIconTokens.quickEntryShelved,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickEntryButtonContent extends StatelessWidget {
  const _QuickEntryButtonContent({
    required this.label,
    required this.detail,
    required this.icon,
  });

  final String label;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(height: AppSpacingTokens.compactTextGap),
        Text(
          label,
          style: theme.appTextRoles.cardTitle.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: theme.appTextRoles.supportingBody,
        ),
      ],
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
        Text(title, style: theme.appTextRoles.sectionTitle),
        const SizedBox(height: AppSpacingTokens.compactTextGap),
        Text(subtitle, style: theme.appTextRoles.body),
      ],
    );
  }
}
