import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/ui_copy.dart';
import '../../../core/theme/app_motion_tokens.dart';
import '../../../core/theme/app_spacing_tokens.dart';
import '../../../core/theme/reentry_atlas_tokens.dart';
import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import '../domain/task.dart';
import '../domain/task_recommendation_service.dart';
import '../domain/task_status.dart';
import 'task_detail_screen.dart';
import 'widgets/banner_style_components.dart';
import 'widgets/home_recommendation_card.dart';
import 'widgets/reentry_atlas_components.dart';

class TasksHomeScreen extends StatefulWidget {
  const TasksHomeScreen({
    super.key,
    this.onViewPostponing,
    this.onViewShelved,
    this.onAddTask,
  });

  final VoidCallback? onViewPostponing;
  final VoidCallback? onViewShelved;
  final VoidCallback? onAddTask;

  @override
  State<TasksHomeScreen> createState() => _TasksHomeScreenState();
}

class _TasksHomeScreenState extends State<TasksHomeScreen> {
  String _lastExposureKey = '';
  String _lastHoldingRevisitExposureKey = '';

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

              _recordExposureIfNeeded(context, state.recommendations);
              _recordHoldingRevisitExposureIfNeeded(
                context,
                state.holdingBoxRevisitSuggestions,
              );

              final spotlight = state.recommendations.isNotEmpty
                  ? state.recommendations.first
                  : state.holdingBoxRevisitSuggestions.firstOrNull;
              final remainingRecommendations = state.recommendations.length > 1
                  ? state.recommendations.skip(1).toList(growable: false)
                  : const <TaskRecommendation>[];

              return LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = math.min(constraints.maxWidth, 640.0);
                  final horizontalInset = contentWidth >= 560
                      ? 28.0
                      : AppSpacingTokens.screenInset;
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: contentWidth,
                      height: constraints.maxHeight,
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalInset,
                          AppSpacingTokens.lg,
                          horizontalInset,
                          48,
                        ),
                        children: [
                          const ReentryBrandHeader(),
                          const SizedBox(height: AppSpacingTokens.lg),
                          ReentryJourneyRail(
                            postponingCount: state.postponingTasks.length,
                            shelvedCount: state.shelvedTasks.length,
                            onAdd: widget.onAddTask,
                            onViewPostponing: widget.onViewPostponing,
                            onViewShelved: widget.onViewShelved,
                            onReconnect: spotlight == null
                                ? widget.onAddTask
                                : () => _activateSpotlight(context, spotlight),
                          ),
                          _buildSpotlight(context, spotlight),
                          const SizedBox(height: AppSpacingTokens.xl),
                          const ReentryThoughtHint(),
                          const SizedBox(height: AppSpacingTokens.sm),
                          if (widget.onAddTask != null)
                            ReentryAddButton(onPressed: widget.onAddTask!),
                          const SizedBox(height: 44),
                          const ReentrySectionHeader(
                            title: '홈 추천',
                            subtitle: '한 번에 하나씩, 다시 닿기 좋은 순서로 놓아둘게요',
                          ),
                          const SizedBox(height: AppSpacingTokens.listGap),
                          BannerMotionSwitcher(
                            duration: AppMotionTokens.homeSectionReveal,
                            beginOffset: const Offset(
                              0,
                              AppMotionTokens.sectionSwitchShift,
                            ),
                            child: remainingRecommendations.isEmpty
                                ? _AtlasSectionPlaceholder(
                                    key: const ValueKey('home-recommend-empty'),
                                    title: state.recommendations.isEmpty
                                        ? '지금은 추천할 일이 없어요'
                                        : '첫 번째 추천을 위에 꺼내두었어요',
                                    message: state.recommendations.isEmpty
                                        ? '한 가지를 남겨두면 다시 볼 타이밍을 조용히 챙겨드릴게요.'
                                        : '위 티켓에서 다시 닿거나, 지금은 넘길 수 있어요.',
                                    actionLabel: state.recommendations.isEmpty
                                        ? '할 일 추가'
                                        : null,
                                    onAction: state.recommendations.isEmpty
                                        ? widget.onAddTask
                                        : null,
                                  )
                                : _RevealingRecommendationList(
                                    key: ValueKey(
                                      'home-recommend-${remainingRecommendations.map((item) => item.task.id).join(',')}',
                                    ),
                                    recommendations: remainingRecommendations,
                                    cardDuration:
                                        AppMotionTokens.homeSectionReveal,
                                    staggerStep: AppMotionTokens
                                        .homeRecommendationStaggerStep,
                                    buildCard:
                                        (context, index, recommendation) =>
                                            HomeRecommendationCard(
                                              recommendation: recommendation,
                                              onOpen: () => _openTaskFromHome(
                                                context,
                                                recommendation.task,
                                              ),
                                              onSnooze: () => context
                                                  .read<TasksCubit>()
                                                  .snooze(recommendation.task),
                                              onShelf: () => _confirmShelve(
                                                context,
                                                recommendation.task,
                                              ),
                                            ),
                                  ),
                          ),
                          const SizedBox(height: 40),
                          const ReentrySectionHeader(
                            title: '보관함에서 다시 꺼내볼래',
                            subtitle: '오래 쉬어둔 일 가운데, 지금 다시 만나도 좋은 것만 보여드려요',
                          ),
                          const SizedBox(height: AppSpacingTokens.listGap),
                          BannerMotionSwitcher(
                            duration: AppMotionTokens.homeSectionReveal,
                            beginOffset: const Offset(
                              0,
                              AppMotionTokens.sectionSwitchShift,
                            ),
                            child: state.holdingBoxRevisitSuggestions.isEmpty
                                ? const _AtlasSectionPlaceholder(
                                    key: ValueKey('home-revisit-empty'),
                                    title: '지금은 조용히 두고 있어요',
                                    message:
                                        '보관한 지 14일이 지난 일만, 다시 닿을 수 있게 천천히 가져와요.',
                                  )
                                : _RevealingRecommendationList(
                                    key: ValueKey(
                                      'home-revisit-${state.holdingBoxRevisitSuggestions.map((item) => item.task.id).join(',')}',
                                    ),
                                    recommendations:
                                        state.holdingBoxRevisitSuggestions,
                                    cardDuration:
                                        AppMotionTokens.homeSectionReveal,
                                    staggerStartOffset: AppMotionTokens
                                        .homeRevisitStaggerOffset,
                                    staggerStep:
                                        AppMotionTokens.homeRevisitStaggerStep,
                                    buildCard:
                                        (context, index, recommendation) =>
                                            HomeRecommendationCard(
                                              recommendation: recommendation,
                                              onOpen: () => context
                                                  .read<TasksCubit>()
                                                  .confirmHoldingBoxRevisit(
                                                    recommendation.task,
                                                  ),
                                              onSnooze: () => context
                                                  .read<TasksCubit>()
                                                  .dismissHoldingBoxRevisit(
                                                    recommendation.task,
                                                  ),
                                              onShelf: () => _openDetail(
                                                context,
                                                recommendation.task,
                                              ),
                                            ),
                                  ),
                          ),
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

  Widget _buildSpotlight(
    BuildContext context,
    TaskRecommendation? recommendation,
  ) {
    if (recommendation == null) {
      return ReentryAtlasTicket(
        title: '아직 다시 닿을 일이 없어요',
        supportingText: '떠오른 일을 한 줄 남겨두면, 다시 볼 때를 조용히 챙겨드릴게요.',
        primaryLabel: '떠오른 일 남기기',
        onPrimary: widget.onAddTask ?? () {},
        icon: Icons.lightbulb_outline_rounded,
      );
    }

    final isRevisit = recommendation.suggestHoldingRevisit;
    final note = recommendation.task.note?.trim();
    final reason = recommendation.reasons.firstOrNull;
    final supportingText = switch ((note?.isNotEmpty ?? false, reason)) {
      (true, _) => note!,
      (false, final reason?) => reason,
      _ =>
        isRevisit ? '오래 쉬어둔 일이라, 지금 천천히 다시 꺼내볼 수 있어요.' : '작게 다시 시작하기 좋은 때예요.',
    };

    return ReentryAtlasTicket(
      key: ValueKey('spotlight-${recommendation.task.id}'),
      title: recommendation.task.title,
      supportingText: supportingText,
      primaryLabel: isRevisit ? '다시 꺼내볼래요' : '다시 닿기',
      onPrimary: () => _activateSpotlight(context, recommendation),
      secondaryLabel: '지금은 넘기기',
      onSecondary: () => _deferSpotlight(context, recommendation),
      onDetails: () => _openDetail(context, recommendation.task),
      icon: isRevisit ? Icons.inventory_2_outlined : Icons.refresh_rounded,
    );
  }

  Future<void> _activateSpotlight(
    BuildContext context,
    TaskRecommendation recommendation,
  ) {
    if (recommendation.suggestHoldingRevisit) {
      return context.read<TasksCubit>().confirmHoldingBoxRevisit(
        recommendation.task,
      );
    }
    return _openTaskFromHome(context, recommendation.task);
  }

  Future<void> _deferSpotlight(
    BuildContext context,
    TaskRecommendation recommendation,
  ) {
    if (recommendation.suggestHoldingRevisit) {
      return context.read<TasksCubit>().dismissHoldingBoxRevisit(
        recommendation.task,
      );
    }
    return context.read<TasksCubit>().snooze(recommendation.task);
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
    final recorded = await context.read<TasksCubit>().markTaskInteracted(task);
    if (!recorded || !context.mounted) return;
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

class _AtlasSectionPlaceholder extends StatelessWidget {
  const _AtlasSectionPlaceholder({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return ReentryPorcelainTicket(
      minimumHeight: 152,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: atlas.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: atlas.inkMuted,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacingTokens.md),
              FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: atlas.periwinkleDeep,
                  foregroundColor: atlas.porcelain,
                ),
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RevealingRecommendationList extends StatelessWidget {
  const _RevealingRecommendationList({
    super.key,
    required this.recommendations,
    required this.buildCard,
    this.cardDuration = AppMotionTokens.cardReveal,
    this.staggerStartOffset = 0.0,
    this.staggerStep = 0.08,
  });

  final List<TaskRecommendation> recommendations;
  final Widget Function(
    BuildContext context,
    int index,
    TaskRecommendation recommendation,
  )
  buildCard;
  final Duration cardDuration;
  final double staggerStartOffset;
  final double staggerStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < recommendations.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacingTokens.listGap),
            child: StaggeredRevealCard(
              index: index,
              duration: cardDuration,
              staggerStart: staggerStartOffset,
              staggerStep: staggerStep,
              child: buildCard(context, index, recommendations[index]),
            ),
          ),
      ],
    );
  }
}
