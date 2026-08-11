import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius_tokens.dart';
import '../../../../core/theme/app_spacing_tokens.dart';
import '../../../../core/theme/reentry_atlas_tokens.dart';
import 'reentry_atlas_components.dart';

enum TaskEmptyStateTone { reentry, holding }

class TaskEmptyStateCard extends StatelessWidget {
  const TaskEmptyStateCard({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.tone = TaskEmptyStateTone.reentry,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final TaskEmptyStateTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    final accent = tone == TaskEmptyStateTone.holding
        ? atlas.mint
        : atlas.periwinkle;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        return ReentryPorcelainTicket(
          minimumHeight: compact ? 224 : 244,
          elevation: 11,
          notchPosition: 0.58,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _EmptyTicketRoutePainter(
                      accent: accent,
                      ink: atlas.ink,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 24 : 30,
                  compact ? 22 : 26,
                  compact ? 24 : 30,
                  compact ? 20 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EmptyStateSeal(accent: accent, tone: tone),
                    const SizedBox(height: AppSpacingTokens.md),
                    Text(
                      title,
                      style:
                          (compact
                                  ? theme.textTheme.titleLarge
                                  : theme.textTheme.headlineSmall)
                              ?.copyWith(
                                color: atlas.ink,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                                letterSpacing: -0.45,
                              ),
                    ),
                    const SizedBox(height: AppSpacingTokens.xs),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: atlas.inkMuted,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: AppSpacingTokens.lg),
                      FilledButton.icon(
                        onPressed: onAction,
                        style: FilledButton.styleFrom(
                          backgroundColor: atlas.periwinkleDeep,
                          foregroundColor: atlas.porcelain,
                          minimumSize: const Size(0, 52),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadiusTokens.pill,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 23),
                        label: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyStateSeal extends StatelessWidget {
  const _EmptyStateSeal({required this.accent, required this.tone});

  final Color accent;
  final TaskEmptyStateTone tone;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: atlas.porcelain,
        boxShadow: [
          BoxShadow(
            color: atlas.ink.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.42),
            colors: [Color.lerp(accent, Colors.white, 0.42)!, accent],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.58)),
        ),
        child: Icon(
          tone == TaskEmptyStateTone.holding
              ? Icons.bookmark_outline_rounded
              : Icons.route_outlined,
          color: atlas.ink.withValues(alpha: 0.68),
          size: 24,
        ),
      ),
    );
  }
}

class _EmptyTicketRoutePainter extends CustomPainter {
  const _EmptyTicketRoutePainter({required this.accent, required this.ink});

  final Color accent;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.62, -12)
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.16,
        size.width * 0.74,
        size.height * 0.52,
        size.width + 18,
        size.height * 0.68,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = ink.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = accent.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.23),
      13,
      Paint()..color = accent.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.23),
      6,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyTicketRoutePainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.ink != ink;
}
