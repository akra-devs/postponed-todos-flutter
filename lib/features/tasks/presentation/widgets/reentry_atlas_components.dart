import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius_tokens.dart';
import '../../../../core/theme/app_spacing_tokens.dart';
import '../../../../core/theme/reentry_atlas_tokens.dart';

class ReentryAtlasBackdrop extends StatelessWidget {
  const ReentryAtlasBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return ColoredBox(
      color: atlas.midnight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/midnight_enamel_texture.png',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.88),
            excludeFromSemantics: true,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: atlas.midnight.withValues(alpha: 0.12),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class ReentryBrandHeader extends StatelessWidget {
  const ReentryBrandHeader({
    super.key,
    this.title = '미뤄둔 일',
    this.subtitle = '오늘, 다시 닿아볼 일',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: atlas.onMidnight,
            fontSize: 31,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Text(
          subtitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: atlas.onMidnightMuted,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.35,
          ),
        ),
      ],
    );
  }
}

class ReentryJourneyRail extends StatelessWidget {
  const ReentryJourneyRail({
    super.key,
    required this.postponingCount,
    required this.shelvedCount,
    this.onAdd,
    this.onViewPostponing,
    this.onViewShelved,
    this.onReconnect,
  });

  final int postponingCount;
  final int shelvedCount;
  final VoidCallback? onAdd;
  final VoidCallback? onViewPostponing;
  final VoidCallback? onViewShelved;
  final VoidCallback? onReconnect;

  static const _positions = <Offset>[
    Offset(0.08, 0.72),
    Offset(0.34, 0.47),
    Offset(0.62, 0.31),
    Offset(0.90, 0.16),
  ];

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final expandedLabels = textScale >= 1.35;
    final stages = <_JourneyStageData>[
      _JourneyStageData(
        label: '떠올림',
        semanticLabel: '떠올림, 새 할 일 남기기',
        color: atlas.periwinkle,
        onTap: onAdd,
        emphasized: true,
      ),
      _JourneyStageData(
        label: '미루는 중',
        semanticLabel: '미루는 중인 할 일 $postponingCount개',
        count: postponingCount,
        color: atlas.porcelainLow,
        onTap: onViewPostponing,
      ),
      _JourneyStageData(
        label: '보관함',
        semanticLabel: '보관함에 둔 할 일 $shelvedCount개',
        count: shelvedCount,
        color: atlas.porcelain,
        onTap: onViewShelved,
      ),
      _JourneyStageData(
        label: '다시 닿기',
        semanticLabel: '추천한 일과 다시 닿기',
        color: atlas.mint,
        onTap: onReconnect,
      ),
    ];

    return Semantics(
      container: true,
      label: '할 일을 떠올리고, 잠시 미루거나 보관한 뒤 다시 닿는 흐름',
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final compact = width < 430;
            final routeHeight = compact ? 106.0 : 126.0;
            final height = expandedLabels
                ? (compact ? 196.0 : 226.0)
                : (compact ? 158.0 : 194.0);
            return SizedBox(
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: width,
                    height: routeHeight,
                    child: CustomPaint(
                      painter: _ReentryRoutePainter(
                        routeColor: atlas.route,
                        shadowColor: Colors.black.withValues(alpha: 0.38),
                        positions: _positions,
                      ),
                    ),
                  ),
                  for (var index = 0; index < stages.length; index++)
                    Positioned(
                      left: _stageLeft(width, _positions[index].dx),
                      top: _positions[index].dy * routeHeight - 25,
                      width: 88,
                      child: _JourneyStage(
                        data: stages[index],
                        expandedLabel: expandedLabels,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double _stageLeft(double width, double normalizedX) {
    return (width * normalizedX - 44).clamp(0, width - 88);
  }
}

class _JourneyStageData {
  const _JourneyStageData({
    required this.label,
    required this.semanticLabel,
    required this.color,
    this.count = 0,
    this.onTap,
    this.emphasized = false,
  });

  final String label;
  final String semanticLabel;
  final int count;
  final Color color;
  final VoidCallback? onTap;
  final bool emphasized;
}

class _JourneyStage extends StatelessWidget {
  const _JourneyStage({required this.data, required this.expandedLabel});

  final _JourneyStageData data;
  final bool expandedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Semantics(
      button: data.onTap != null,
      label: data.semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: data.onTap,
          borderRadius: BorderRadius.circular(AppRadiusTokens.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ClayNode(color: data.color, glowing: data.emphasized),
                const SizedBox(height: 8),
                Text(
                  data.label,
                  maxLines: expandedLabel ? 2 : 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: data.emphasized
                        ? atlas.periwinkleSoft
                        : atlas.onMidnight,
                    fontWeight: data.emphasized
                        ? FontWeight.w800
                        : FontWeight.w700,
                  ),
                ),
                if (data.count > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${data.count}개',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: atlas.onMidnightMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClayNode extends StatelessWidget {
  const _ClayNode({required this.color, required this.glowing});

  final Color color;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: atlas.porcelain,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 11,
            offset: const Offset(0, 6),
          ),
          if (glowing)
            BoxShadow(
              color: atlas.periwinkle.withValues(alpha: 0.34),
              blurRadius: 18,
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
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.54),
            width: 1,
          ),
        ),
      ),
    );
  }
}

class _ReentryRoutePainter extends CustomPainter {
  const _ReentryRoutePainter({
    required this.routeColor,
    required this.shadowColor,
    required this.positions,
  });

  final Color routeColor;
  final Color shadowColor;
  final List<Offset> positions;

  @override
  void paint(Canvas canvas, Size size) {
    final points = positions
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList(growable: false);
    final path = Path()
      ..moveTo(-18, size.height * 0.92)
      ..cubicTo(
        points[0].dx - 18,
        points[0].dy + 7,
        points[1].dx - 35,
        points[1].dy + 18,
        points[1].dx,
        points[1].dy,
      )
      ..cubicTo(
        points[1].dx + 50,
        points[1].dy - 24,
        points[2].dx - 28,
        points[2].dy + 22,
        points[2].dx,
        points[2].dy,
      )
      ..cubicTo(
        points[2].dx + 58,
        points[2].dy - 22,
        points[3].dx - 38,
        points[3].dy + 18,
        size.width + 18,
        points[3].dy - 9,
      );

    canvas.drawPath(
      path,
      Paint()
        ..color = shadowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 17
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = routeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ReentryRoutePainter oldDelegate) {
    return oldDelegate.routeColor != routeColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.positions != positions;
  }
}

class ReentryPorcelainTicket extends StatelessWidget {
  const ReentryPorcelainTicket({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.minimumHeight = 0,
    this.elevation = 9,
    this.notchPosition = 0.56,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double minimumHeight;
  final double elevation;
  final double notchPosition;

  @override
  Widget build(BuildContext context) {
    final atlas = Theme.of(context).reentryAtlas;
    final ticket = PhysicalShape(
      clipper: ReentryTicketClipper(notchPosition: notchPosition),
      color: atlas.porcelain,
      shadowColor: Colors.black.withValues(alpha: 0.58),
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minimumHeight),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [atlas.porcelain, atlas.porcelainLow],
              ),
            ),
            child: InkWell(onTap: onTap, child: child),
          ),
        ),
      ),
    );

    if (onTap == null) return ticket;
    return Semantics(
      button: true,
      label: semanticLabel,
      container: true,
      excludeSemantics: semanticLabel != null,
      child: ticket,
    );
  }
}

class ReentryAtlasTicket extends StatelessWidget {
  const ReentryAtlasTicket({
    super.key,
    required this.title,
    required this.supportingText,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.onDetails,
    this.detailsTooltip = '자세히 보기',
    this.icon = Icons.refresh_rounded,
  });

  final String title;
  final String supportingText;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final VoidCallback? onDetails;
  final String detailsTooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compact = MediaQuery.sizeOf(context).width < 480;
    return ReentryPorcelainTicket(
      elevation: 13,
      minimumHeight: compact ? 220 : 258,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 22 : 28,
          compact ? 21 : 28,
          compact ? 22 : 28,
          compact ? 18 : 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: compact ? 46 : 54,
                  height: compact ? 46 : 54,
                  decoration: BoxDecoration(
                    color: atlas.periwinkleSoft.withValues(alpha: 0.62),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: atlas.periwinkleDeep,
                    size: compact ? 24 : 28,
                  ),
                ),
                const Spacer(),
                if (onDetails != null)
                  IconButton(
                    onPressed: onDetails,
                    tooltip: detailsTooltip,
                    color: atlas.inkMuted,
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
              ],
            ),
            SizedBox(
              height: compact ? AppSpacingTokens.sm : AppSpacingTokens.md,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: atlas.ink,
                  fontSize: compact ? 24 : 27,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.65,
                ),
              ),
            ),
            SizedBox(
              height: compact ? AppSpacingTokens.xs : AppSpacingTokens.sm,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                supportingText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: atlas.inkMuted,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ),
            SizedBox(
              height: compact ? AppSpacingTokens.sm : AppSpacingTokens.lg,
            ),
            Divider(color: atlas.ink.withValues(alpha: 0.12), height: 1),
            SizedBox(
              height: compact ? AppSpacingTokens.sm : AppSpacingTokens.md,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final stackActions =
                    constraints.maxWidth < 310 || textScale >= 1.25;
                final primary = _TicketPrimaryAction(
                  label: primaryLabel,
                  onPressed: onPrimary,
                );
                final secondary = secondaryLabel != null && onSecondary != null
                    ? TextButton(
                        onPressed: onSecondary,
                        style: TextButton.styleFrom(
                          foregroundColor: atlas.inkMuted,
                          minimumSize: const Size(48, 48),
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(secondaryLabel!),
                      )
                    : null;
                if (stackActions) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      primary,
                      if (secondary != null) ...[
                        const SizedBox(height: AppSpacingTokens.xs),
                        secondary,
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: primary),
                    if (secondary != null) ...[
                      const SizedBox(width: AppSpacingTokens.sm),
                      secondary,
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketPrimaryAction extends StatelessWidget {
  const _TicketPrimaryAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    final compact = MediaQuery.sizeOf(context).width < 480;
    return Semantics(
      button: true,
      label: label,
      container: true,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: compact ? 54 : 62,
                  height: compact ? 54 : 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [atlas.periwinkle, atlas.periwinkleDeep],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: atlas.ink.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: atlas.porcelain,
                    size: compact ? 28 : 32,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: atlas.periwinkleDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReentryThoughtHint extends StatelessWidget {
  const ReentryThoughtHint({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Align(
      alignment: Alignment.center,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: atlas.midnightSoft.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '생각난 일을 한 줄로…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: atlas.onMidnight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacingTokens.xs),
              Icon(
                Icons.south_east_rounded,
                color: atlas.onMidnightMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReentryAddButton extends StatelessWidget {
  const ReentryAddButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Semantics(
      button: true,
      label: '떠오른 일 남기기',
      container: true,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [atlas.periwinkle, atlas.periwinkleDeep],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.42),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 68),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: atlas.porcelain, size: 31),
                    const SizedBox(width: AppSpacingTokens.sm),
                    Flexible(
                      child: Text(
                        '떠오른 일 남기기',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: atlas.porcelain,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReentrySectionHeader extends StatelessWidget {
  const ReentrySectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlas = theme.reentryAtlas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: atlas.onMidnight,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacingTokens.xs),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: atlas.onMidnightMuted,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class ReentryTicketClipper extends CustomClipper<Path> {
  const ReentryTicketClipper({this.notchPosition = 0.56});

  final double notchPosition;

  @override
  Path getClip(Size size) {
    final radius = Radius.circular(
      lerpDouble(20, 28, (size.width / 600).clamp(0, 1))!,
    );
    final ticket = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, radius));
    final notchY = size.height * notchPosition;
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset.zero.translate(0, notchY), radius: 15),
      )
      ..addOval(
        Rect.fromCircle(center: Offset(size.width, notchY), radius: 15),
      );
    return Path.combine(PathOperation.difference, ticket, notches);
  }

  @override
  bool shouldReclip(covariant ReentryTicketClipper oldClipper) =>
      oldClipper.notchPosition != notchPosition;
}
