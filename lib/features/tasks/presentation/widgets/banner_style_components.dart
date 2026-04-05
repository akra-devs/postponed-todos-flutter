import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion_tokens.dart';
import '../../../../core/theme/app_radius_tokens.dart';
import '../../../../core/theme/app_theme_ext.dart';

const EdgeInsets _bannerTagPadding = EdgeInsets.symmetric(
  horizontal: 10,
  vertical: 4,
);

class BannerTagChip extends StatelessWidget {
  const BannerTagChip({
    super.key,
    required this.label,
    required this.icon,
    required this.highlighted,
  });

  final String label;
  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: highlighted
            ? LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.18),
                  colorScheme.primary.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: highlighted
            ? null
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Padding(
        padding: _bannerTagPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: highlighted
                    ? colorScheme.onPrimaryContainer.withValues(alpha: 0.16)
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 10,
                color: highlighted
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.appTextRoles.eyebrow.copyWith(
                color: highlighted
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerMotionSwitcher extends StatelessWidget {
  const BannerMotionSwitcher({
    super.key,
    required this.child,
    this.duration = AppMotionTokens.cardReveal,
    this.enterCurve = AppMotionTokens.enterCurve,
    this.exitCurve = AppMotionTokens.exitCurve,
    this.beginOffset = Offset.zero,
    this.scaleFrom,
    this.scaleTo,
  });

  final Widget child;
  final Duration duration;
  final Curve enterCurve;
  final Curve exitCurve;
  final Offset beginOffset;
  final double? scaleFrom;
  final double? scaleTo;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: enterCurve,
      switchOutCurve: exitCurve,
      transitionBuilder: (switchChild, animation) {
        final curved = CurvedAnimation(parent: animation, curve: enterCurve);
        final transitionChild = SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curved),
          child: switchChild,
        );

        if (scaleFrom == null || scaleTo == null) {
          return FadeTransition(opacity: curved, child: transitionChild);
        }

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: scaleFrom!,
              end: scaleTo!,
            ).animate(curved),
            child: transitionChild,
          ),
        );
      },
      child: child,
    );
  }
}

class StaggeredRevealCard extends StatefulWidget {
  const StaggeredRevealCard({
    super.key,
    required this.index,
    required this.child,
    this.duration = AppMotionTokens.cardReveal,
    this.lift = AppMotionTokens.homeCardLift,
    this.scaleFrom = 0.992,
    this.scaleTo = 1.0,
  });

  final int index;
  final Widget child;
  final Duration duration;
  final double lift;
  final double scaleFrom;
  final double scaleTo;

  @override
  State<StaggeredRevealCard> createState() => _StaggeredRevealCardState();
}

class _StaggeredRevealCardState extends State<StaggeredRevealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();

  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final start = (widget.index * 0.08).clamp(0.0, 0.5);
    final end = (start + 0.45).clamp(start + 0.01, 1.0);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: AppMotionTokens.microSpring),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Transform.translate(
        offset: Offset(0, (1 - _animation.value) * widget.lift * 100),
        child: Transform.scale(
          scale:
              widget.scaleFrom +
              (_animation.value * (widget.scaleTo - widget.scaleFrom)),
          child: widget.child,
        ),
      ),
    );
  }
}

class BreathingIconBadge extends StatefulWidget {
  const BreathingIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 42,
    this.iconSize = 20,
    this.duration = AppMotionTokens.graceful,
    this.minScale = 0.985,
    this.maxScale = 1.025,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final Duration duration;
  final double minScale;
  final double maxScale;

  @override
  State<BreathingIconBadge> createState() => _BreathingIconBadgeState();
}

class _BreathingIconBadgeState extends State<BreathingIconBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale =
            widget.minScale +
            (_controller.value * (widget.maxScale - widget.minScale));
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Theme.of(context).appSurfaces.holdingHeroIconSurface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: widget.iconSize,
            ),
          ),
        );
      },
    );
  }
}
