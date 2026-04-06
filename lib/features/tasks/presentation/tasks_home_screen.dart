import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/ui_copy.dart';
import '../../../core/theme/app_icon_tokens.dart';
import '../../../core/theme/app_elevation_tokens.dart';
import '../../../core/theme/app_radius_tokens.dart';
import '../../../core/theme/app_motion_tokens.dart';
import '../../../core/theme/app_spacing_tokens.dart';
import '../../../core/theme/app_theme_ext.dart';
import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import '../domain/task.dart';
import '../domain/task_recommendation_service.dart';
import '../domain/task_status.dart';
import 'widgets/home_recommendation_card.dart';
import 'widgets/banner_style_components.dart';
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
                  postponingCount: state.postponingTasks.length,
                  shelvedCount: state.shelvedTasks.length,
                ),
                const SizedBox(height: AppSpacingTokens.sectionGap),
                const _SectionHeader(
                  title: '홈 추천',
                  subtitle: '지금은 가볍게 시작해볼 수 있는 일부터 보여드릴게요',
                ),
                const SizedBox(height: AppSpacingTokens.listGap),
                BannerMotionSwitcher(
                  duration: AppMotionTokens.homeSectionReveal,
                  beginOffset: const Offset(
                    0,
                    AppMotionTokens.sectionSwitchShift,
                  ),
                  child: state.recommendations.isEmpty
                      ? const _TaskSectionPlaceholder(
                          key: ValueKey('home-recommend-empty'),
                          title: '지금은 추천할 일이 없어요',
                          message: '쿨다운이 끝난 일이 생기면, 조용히 다시 보여줄게요.',
                        )
                      : _RevealingRecommendationList(
                          key: ValueKey(
                            'home-recommend-${state.recommendations.map((item) => item.task.id).join(',')}',
                          ),
                          recommendations: state.recommendations,
                          cardDuration: AppMotionTokens.homeSectionReveal,
                          staggerStep:
                              AppMotionTokens.homeRecommendationStaggerStep,
                          buildCard: (context, index, recommendation) =>
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
                const SizedBox(height: AppSpacingTokens.sectionGapLarge),
                const _SectionHeader(
                  title: '보관함에서 다시 꺼내볼래',
                  subtitle: '한동안 쉬어둔 일 중, 다시 천천히 잡아볼 만한 것만 골라 보여드릴게요',
                ),
                const SizedBox(height: AppSpacingTokens.listGap),
                BannerMotionSwitcher(
                  duration: AppMotionTokens.homeSectionReveal,
                  beginOffset: const Offset(
                    0,
                    AppMotionTokens.sectionSwitchShift,
                  ),
                  child: state.holdingBoxRevisitSuggestions.isEmpty
                      ? const _TaskSectionPlaceholder(
                          key: ValueKey('home-revisit-empty'),
                          title: '지금은 조용히 두고 있어요',
                          message: '보관함에 넣은 지 14일이 지난 일만, 천천히 꺼내볼 수 있게 가져와요.',
                        )
                      : _RevealingRecommendationList(
                          key: ValueKey(
                            'home-revisit-${state.holdingBoxRevisitSuggestions.map((item) => item.task.id).join(',')}',
                          ),
                          recommendations: state.holdingBoxRevisitSuggestions,
                          cardDuration: AppMotionTokens.homeSectionReveal,
                          staggerStartOffset:
                              AppMotionTokens.homeRevisitStaggerOffset,
                          staggerStep: AppMotionTokens.homeRevisitStaggerStep,
                          buildCard: (context, index, recommendation) =>
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

class _TaskSectionPlaceholder extends StatelessWidget {
  const _TaskSectionPlaceholder({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return TaskEmptyStateCard(title: title, message: message);
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

class _QuickEntrySection extends StatelessWidget {
  const _QuickEntrySection({
    required this.onViewPostponing,
    required this.onViewShelved,
    required this.postponingCount,
    required this.shelvedCount,
  });

  final VoidCallback? onViewPostponing;
  final VoidCallback? onViewShelved;
  final int postponingCount;
  final int shelvedCount;
  String _countBadgeText(int count) => '$count개';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaces = theme.appSurfaces;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.1),
                colorScheme.surfaceContainerLowest,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadiusTokens.md),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '가볍게 들어가는 곳',
                    style: theme.appTextRoles.cardTitle.copyWith(
                      color:
                          theme.appTextRoles.cardTitle.color ??
                          colorScheme.onSurface,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: surfaces.revisitPanel,
                    borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.xs,
                      vertical: AppSpacingTokens.xxs,
                    ),
                    child: Text(
                      '천천히',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.eyebrowGap),
        Text(
          '원할 때 살짝 열어볼 수 있는 가벼운 시작 공간이에요',
          style: theme.appTextRoles.supportingBody,
        ),
        const SizedBox(height: AppSpacingTokens.listGap),
        BlocBuilder<TasksCubit, TasksState>(
          builder: (context, _) {
            return Row(
              children: [
                Expanded(
                  child: _QuickEntryCommandCard(
                    onPressed: onViewPostponing,
                    icon: AppIconTokens.quickEntryPostponing,
                    label: '미루는 중',
                    detail: '지금은 아니어도 좋을 만큼 쉬워요. 천천히 다시 볼 목록을 담아뒀어요',
                    countBadge: _countBadgeText(postponingCount),
                    accentSurface: surfaces.revisitPanel,
                    accent: colorScheme.onSurfaceVariant,
                    highlight: theme.appStatus.postponingFg,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.listGap),
                Expanded(
                  child: _QuickEntryCommandCard(
                    onPressed: onViewShelved,
                    icon: AppIconTokens.quickEntryShelved,
                    label: '보관함',
                    detail: '지금은 바로 올리지 않고, 마음 편하게 다시 꺼내둘 수 있는 자리',
                    countBadge: _countBadgeText(shelvedCount),
                    accentSurface: surfaces.holdingHeroSurface,
                    accent: theme.appStatus.shelvedFg,
                    highlight: theme.appStatus.shelvedFg,
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

class _QuickEntryCommandCard extends StatelessWidget {
  const _QuickEntryCommandCard({
    required this.onPressed,
    required this.label,
    required this.detail,
    required this.icon,
    required this.accentSurface,
    required this.accent,
    required this.highlight,
    this.countBadge,
  });

  final VoidCallback? onPressed;
  final String label;
  final String detail;
  final IconData icon;
  final Color accentSurface;
  final Color accent;
  final Color highlight;
  final String? countBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadiusTokens.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadiusTokens.md),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: AppElevationTokens.cardBlur,
                offset: const Offset(0, AppElevationTokens.cardOffsetY),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.cardInset),
            child: _QuickEntryButtonContent(
              label: label,
              detail: detail,
              icon: icon,
              accent: accent,
              background: accentSurface,
              highlight: highlight,
              countBadge: countBadge,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickEntryButtonContent extends StatelessWidget {
  const _QuickEntryButtonContent({
    required this.label,
    required this.detail,
    required this.icon,
    required this.accent,
    required this.background,
    required this.highlight,
    this.countBadge,
  });

  final String label;
  final String detail;
  final IconData icon;
  final Color accent;
  final Color background;
  final Color highlight;
  final String? countBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (countBadge != null) ...[
          Text(
            countBadge!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.xs),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: background.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.xxs),
            child: Icon(icon, size: 18, color: accent),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.compactTextGap),
        Text(
          label,
          style: theme.appTextRoles.cardTitle.copyWith(
            fontWeight: FontWeight.w700,
            color: highlight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: theme.appTextRoles.supportingBody.copyWith(height: 1.28),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: AppSpacingTokens.xs),
            Expanded(
              child: Text(
                title,
                style: theme.appTextRoles.sectionTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.compactTextGap),
        Text(
          subtitle,
          style: theme.appTextRoles.supportingBody.copyWith(height: 1.42),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
