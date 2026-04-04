import 'package:flutter/material.dart';

import '../../../../core/theme/app_color_tokens.dart';
import '../../../../core/theme/app_elevation_tokens.dart';
import '../../../../core/theme/app_radius_tokens.dart';
import '../../../../core/theme/app_spacing_tokens.dart';
import '../../../../core/theme/app_theme_ext.dart';
import '../../domain/task.dart';
import '../../domain/task_status.dart';

class TaskListCard extends StatelessWidget {
  const TaskListCard({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaces = theme.appSurfaces;
    final isCoolingDown = task.resurfaceAt?.isAfter(DateTime.now()) ?? false;
    final hasNote = (task.note ?? '').isNotEmpty;
    final isShelved = task.status == TaskStatus.shelved;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: isShelved ? surfaces.holdingSurface : surfaces.card,
            borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
            border: Border.all(
              color: isShelved
                  ? surfaces.holdingBorder
                  : colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha: isShelved ? 0.025 : 0.035,
                ),
                blurRadius: isShelved
                    ? AppElevationTokens.cardBlur - 2
                    : AppElevationTokens.cardBlur,
                offset: const Offset(0, AppElevationTokens.cardOffsetY),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LeadingIntentMarker(status: task.status),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: AppSpacingTokens.xs),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.outline,
                          ),
                        ],
                      ),
                      if (hasNote) ...[
                        const SizedBox(height: AppSpacingTokens.xs),
                        Text(
                          task.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacingTokens.sm),
                      Wrap(
                        spacing: AppSpacingTokens.xs,
                        runSpacing: AppSpacingTokens.xs,
                        children: [
                          _StatusChip(
                            label: task.status.label,
                            tone: task.status == TaskStatus.shelved
                                ? _ChipTone.shelf
                                : _ChipTone.neutral,
                          ),
                          if (isShelved && task.shelvedAt != null)
                            _StatusChip(
                              label: '보관 ${_daysSince(task.shelvedAt!)}일째',
                              tone: _ChipTone.muted,
                            ),
                          if (isCoolingDown)
                            const _StatusChip(
                              label: '조금 더 둘래 · 다시 보기 대기 중',
                              tone: _ChipTone.muted,
                            ),
                          if (task.status == TaskStatus.shelved &&
                              task.isEligibleForHoldingBoxRevisitSuggestion)
                            const _StatusChip(
                              label: '다시 꺼내볼 때가 됐어요',
                              tone: _ChipTone.warm,
                            ),
                        ],
                      ),
                      if (isShelved) ...[
                        const SizedBox(height: AppSpacingTokens.sm),
                        Text(
                          task.isEligibleForHoldingBoxRevisitSuggestion
                              ? '준비되면 다시 꺼내볼 수 있어요.'
                              : '지금은 서두르지 말고 여기 두어도 괜찮아요.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColorTokens.warmForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static int _daysSince(DateTime from) {
    final difference = DateTime.now().difference(from).inDays;
    return difference < 1 ? 1 : difference;
  }
}

class _LeadingIntentMarker extends StatelessWidget {
  const _LeadingIntentMarker({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaces = theme.appSurfaces;
    final isShelved = status == TaskStatus.shelved;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isShelved
            ? surfaces.subtleAccent
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Icon(
        isShelved ? Icons.inventory_2_outlined : Icons.access_time_rounded,
        size: 20,
        color: isShelved
            ? AppColorTokens.warmAccentForeground
            : colorScheme.onSurfaceVariant,
      ),
    );
  }
}

enum _ChipTone { neutral, muted, shelf, warm }

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.tone});

  final String label;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusTokens = theme.appStatus;

    final Color backgroundColor;
    final Color foregroundColor;
    switch (tone) {
      case _ChipTone.neutral:
        backgroundColor = colorScheme.surfaceContainerHighest;
        foregroundColor = colorScheme.onSurfaceVariant;
      case _ChipTone.muted:
        backgroundColor = statusTokens.mutedBg;
        foregroundColor = statusTokens.mutedFg;
      case _ChipTone.shelf:
        backgroundColor = theme.appSurfaces.subtleAccent;
        foregroundColor = AppColorTokens.warmAccentForeground;
      case _ChipTone.warm:
        backgroundColor = statusTokens.revisitBg;
        foregroundColor = statusTokens.revisitFg;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}
