import 'package:flutter/material.dart';

import '../../../../core/theme/app_icon_tokens.dart';
import '../../../../core/theme/app_spacing_tokens.dart';
import '../../../../core/theme/reentry_atlas_tokens.dart';
import '../../domain/task.dart';
import '../../domain/task_status.dart';
import 'reentry_atlas_components.dart';

class TaskListCard extends StatelessWidget {
  const TaskListCard({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    final isShelved = task.status == TaskStatus.shelved;
    final isReadyToRevisit =
        isShelved && task.isEligibleForHoldingBoxRevisitSuggestion;
    final isCoolingDown = task.resurfaceAt?.isAfter(DateTime.now()) ?? false;
    final note = task.note?.trim();
    final accent = isReadyToRevisit
        ? const Color(0xFF477F76)
        : isShelved
        ? const Color(0xFF6E7B80)
        : atlas.periwinkleDeep;
    final contextLabel = switch ((isShelved, isReadyToRevisit, isCoolingDown)) {
      (_, true, _) => '다시 꺼내볼 때가 됐어요',
      (true, false, _) => '마음에 두는 중',
      (false, _, true) => '조금 더 쉬고 다시 보기',
      _ => '지금 다시 보기 좋아요',
    };

    return ReentryPorcelainTicket(
      onTap: onTap,
      semanticLabel: '${task.title}, $contextLabel, 자세히 보기',
      minimumHeight: 128,
      notchPosition: 0.5,
      elevation: 7,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TaskClayNode(
                  color: isReadyToRevisit
                      ? atlas.mint
                      : isShelved
                      ? atlas.porcelainLow
                      : atlas.periwinkle,
                  icon: isShelved
                      ? AppIconTokens.quickEntryShelved
                      : AppIconTokens.quickEntryPostponing,
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Text(
                    contextLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.xs),
                Icon(
                  AppIconTokens.listChevron,
                  color: atlas.inkMuted,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            Text(
              task.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: atlas.ink,
                fontWeight: FontWeight.w800,
                height: 1.25,
                letterSpacing: -0.35,
              ),
            ),
            if (note?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Text(
                note!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: atlas.inkMuted,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskClayNode extends StatelessWidget {
  const _TaskClayNode({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: atlas.porcelain,
        boxShadow: [
          BoxShadow(
            color: atlas.ink.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.45),
            colors: [Color.lerp(color, Colors.white, 0.34)!, color],
          ),
        ),
        child: Icon(icon, color: atlas.ink.withValues(alpha: 0.68), size: 18),
      ),
    );
  }
}
