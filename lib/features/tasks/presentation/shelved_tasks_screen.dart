import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_elevation_tokens.dart';
import '../../../core/theme/app_icon_tokens.dart';
import '../../../core/theme/app_motion_tokens.dart';
import '../../../core/theme/app_radius_tokens.dart';
import '../../../core/theme/app_spacing_tokens.dart';
import '../../../core/theme/app_theme_ext.dart';
import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import 'task_detail_screen.dart';
import 'widgets/task_empty_state_card.dart';
import 'widgets/task_list_card.dart';

class ShelvedTasksScreen extends StatelessWidget {
  const ShelvedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaces = theme.appSurfaces;

    return Scaffold(
      backgroundColor: surfaces.holdingSurface,
      appBar: AppBar(
        title: const Text('보관함'),
        backgroundColor: surfaces.holdingSurface,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              surfaces.holdingHeroHighlight,
              surfaces.holdingHeroBackground,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = state.shelvedTasks;
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacingTokens.screenInset,
                  AppSpacingTokens.listGap,
                  AppSpacingTokens.screenInset,
                  AppSpacingTokens.sectionGap,
                ),
                children: [
                  const _HoldingBoxIntroCard(),
                  const SizedBox(height: 18),
                  Text(
                    tasks.isEmpty ? '지금은 조용히 쉬는 칸' : '안전하게 내려둔 일들',
                    style: theme.appTextRoles.cardTitle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.comfortableTextGap),
                  Text(
                    '급하게 밀어올리지 않고, 준비될 때 다시 꺼낼 수 있게 차분히 보관해둔 목록이에요.',
                    style: theme.appTextRoles.body.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.cardInset),
                  if (tasks.isEmpty)
                    const TaskEmptyStateCard(
                      title: '아직 내려둔 일이 없어요',
                      message:
                          '반복해서 마음이 멀어지는 일은 여기로 잠시 옮겨둘 수 있어요. 필요해질 때 다시 꺼내면 돼요.',
                    )
                  else
                    ...tasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacingTokens.listGap,
                        ),
                        child: TaskListCard(
                          task: task,
                          onTap: () => Navigator.of(
                            context,
                          ).push(TaskDetailScreen.route(task.id)),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HoldingBoxIntroCard extends StatefulWidget {
  const _HoldingBoxIntroCard();

  @override
  State<_HoldingBoxIntroCard> createState() => _HoldingBoxIntroCardState();
}

class _HoldingBoxIntroCardState extends State<_HoldingBoxIntroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotionTokens.cardReveal,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: AppMotionTokens.enterCurve,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surfaces = theme.appSurfaces;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_fade),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surfaces.holdingHeroSurface,
            borderRadius: BorderRadius.circular(AppRadiusTokens.xl + 4),
            border: Border.all(color: surfaces.holdingBorder),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.04),
                blurRadius: AppElevationTokens.heroBlur,
                offset: const Offset(0, AppElevationTokens.heroOffsetY),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.heroInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _BreathingIconBubble(
                      icon: AppIconTokens.quickEntryShelved,
                      color: theme.appStatus.shelvedFg,
                    ),
                    const SizedBox(width: AppSpacingTokens.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '잠시 쉬어두는 선반',
                            style: theme.appTextRoles.cardTitle.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: AppSpacingTokens.compactTextGap,
                          ),
                          Text(
                            '급한 목록에서 잠깐 내려둔 일들을 보관해요',
                            style: theme.appTextRoles.supportingBody.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.cardInset),
                Text(
                  '보관함은 포기한 곳이 아니라, 지금 당장 붙잡지 않아도 되는 일을 조용히 두는 자리예요. 다시 꺼낼 준비가 되면 복원부터 하면 돼요.',
                  style: theme.appTextRoles.body.copyWith(
                    height: 1.55,
                    color: surfaces.holdingHeroBody,
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

class _BreathingIconBubble extends StatefulWidget {
  const _BreathingIconBubble({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_BreathingIconBubble> createState() => _BreathingIconBubbleState();
}

class _BreathingIconBubbleState extends State<_BreathingIconBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

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
        final scale = 0.96 + (_controller.value * 0.06);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(context).appSurfaces.holdingHeroIconSurface,
              borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
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
            child: Icon(widget.icon, color: widget.color, size: 20),
          ),
        );
      },
    );
  }
}
