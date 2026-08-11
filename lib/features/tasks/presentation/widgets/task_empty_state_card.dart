import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing_tokens.dart';

class TaskEmptyStateCard extends StatelessWidget {
  const TaskEmptyStateCard({
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.heroInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacingTokens.eyebrowGap),
            Text(message, style: theme.textTheme.bodyMedium),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacingTokens.cardInset),
              FilledButton.tonalIcon(
                onPressed: onAction,
                icon: const Icon(Icons.add_task_outlined),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
