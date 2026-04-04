import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_radius_tokens.dart';
import '../../../core/theme/app_spacing_tokens.dart';
import '../application/tasks_cubit.dart';
import '../application/tasks_state.dart';
import 'task_detail_screen.dart';
import 'widgets/task_empty_state_card.dart';
import 'widgets/task_list_card.dart';

class PostponingTasksScreen extends StatefulWidget {
  const PostponingTasksScreen({super.key});

  @override
  State<PostponingTasksScreen> createState() => _PostponingTasksScreenState();
}

class _PostponingTasksScreenState extends State<PostponingTasksScreen> {
  _PostponingFilter _selectedFilter = _PostponingFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미루는 중')),
      body: SafeArea(
        child: BlocBuilder<TasksCubit, TasksState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final visibleTasks = switch (_selectedFilter) {
              _PostponingFilter.all => state.postponingTasks,
              _PostponingFilter.available => state.availablePostponingTasks,
              _PostponingFilter.coolingDown => state.coolingDownTasks,
            };

            return ListView(
              padding: const EdgeInsets.all(AppSpacingTokens.screenInset),
              children: [
                _PostponingHubIntro(
                  selectedFilter: _selectedFilter,
                  totalCount: state.postponingTasks.length,
                  availableCount: state.availablePostponingTasks.length,
                  coolingDownCount: state.coolingDownTasks.length,
                ),
                const SizedBox(height: AppSpacingTokens.cardInset),
                _PostponingFilterSection(
                  selectedFilter: _selectedFilter,
                  onSelected: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
                const SizedBox(height: AppSpacingTokens.cardInset),
                _VisibleListContext(
                  title: _selectedFilter.listTitle,
                  description: _selectedFilter.listDescription(
                    totalCount: state.postponingTasks.length,
                    visibleCount: visibleTasks.length,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.cardInset),
                if (visibleTasks.isEmpty)
                  TaskEmptyStateCard(
                    title: _selectedFilter.emptyTitle,
                    message: _selectedFilter.emptyMessage,
                  )
                else
                  ...visibleTasks.map(
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
    );
  }
}

enum _PostponingFilter {
  all(
    label: '전체',
    listTitle: '붙잡고 있는 일 전체',
    emptyTitle: '아직 넣어둔 일이 없어요',
    emptyMessage: '캘린더까지는 아니지만 잊고 싶지 않은 일을 가볍게 적어둘 수 있어요.',
  ),
  available(
    label: '지금 다시 보기 쉬운',
    listTitle: '지금 다시 보기 쉬운 일',
    emptyTitle: '지금 다시 볼 일이 비어 있어요',
    emptyMessage: '조금 더 시간이 지난 뒤에 다시 떠오를 일이 생기면 여기서 가볍게 훑어볼 수 있어요.',
  ),
  coolingDown(
    label: '조금 더 두는 중',
    listTitle: '조금 더 두는 중인 일',
    emptyTitle: '조금 더 둘 일은 없어요',
    emptyMessage: '지금은 쉬게 두고 있는 일이 없어서, 화면이 한결 가볍게 비어 있어요.',
  );

  const _PostponingFilter({
    required this.label,
    required this.listTitle,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final String label;
  final String listTitle;
  final String emptyTitle;
  final String emptyMessage;

  String listDescription({required int totalCount, required int visibleCount}) {
    return switch (this) {
      _PostponingFilter.all =>
        totalCount == 0
            ? '지금 당장 하진 않지만 아직 놓지 않은 일들을 한곳에서 차분히 살펴볼 수 있어요.'
            : '$totalCount개의 일을 한 자리에서 천천히 훑어볼 수 있어요.',
      _PostponingFilter.available =>
        visibleCount == 0
            ? '지금은 바로 다시 볼 만한 일이 없어도 괜찮아요.'
            : '$visibleCount개의 일이 지금 다시 보기 쉬운 상태예요.',
      _PostponingFilter.coolingDown =>
        visibleCount == 0
            ? '잠시 쉬게 두고 있는 일 없이 가볍게 비워져 있어요.'
            : '$visibleCount개의 일이 아직은 조금 더 쉬는 쪽에 가까워요.',
    };
  }
}

class _PostponingHubIntro extends StatelessWidget {
  const _PostponingHubIntro({
    required this.selectedFilter,
    required this.totalCount,
    required this.availableCount,
    required this.coolingDownCount,
  });

  final _PostponingFilter selectedFilter;
  final int totalCount;
  final int availableCount;
  final int coolingDownCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.cardInset),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '지금 당장 하진 않지만, 아직 붙잡고 있는 일들',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacingTokens.eyebrowGap),
          Text(
            '필요할 때 다시 보기 쉬운 일과 조금 더 두는 중인 일을 가볍게 나눠서 볼 수 있어요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.cardInset),
          Wrap(
            spacing: AppSpacingTokens.xs,
            runSpacing: AppSpacingTokens.xs,
            children: [
              _SummaryPill(label: '전체 $totalCount'),
              _SummaryPill(label: '지금 다시 보기 쉬운 $availableCount'),
              _SummaryPill(label: '조금 더 두는 중 $coolingDownCount'),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.eyebrowGap),
          Text(
            selectedFilter == _PostponingFilter.all
                ? '원하는 결로만 가볍게 좁혀보세요.'
                : '지금은 ${selectedFilter.label} 흐름으로 보고 있어요.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostponingFilterSection extends StatelessWidget {
  const _PostponingFilterSection({
    required this.selectedFilter,
    required this.onSelected,
  });

  final _PostponingFilter selectedFilter;
  final ValueChanged<_PostponingFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacingTokens.xs,
      runSpacing: AppSpacingTokens.xs,
      children: _PostponingFilter.values
          .map(
            (filter) => ChoiceChip(
              label: Text(filter.label),
              selected: selectedFilter == filter,
              onSelected: (_) => onSelected(filter),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _VisibleListContext extends StatelessWidget {
  const _VisibleListContext({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacingTokens.xs),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
