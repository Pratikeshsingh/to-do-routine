import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/task_providers.dart';

class SummaryTab extends ConsumerWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomplete = ref.watch(incompleteTasksProvider);
    final sticky = ref.watch(stickyIncompleteNudgeProvider);
    final theme = Theme.of(context);

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));

    final dayIncomplete = incomplete
        .where((t) => !t.createdAt.isAfter(startOfDay.add(const Duration(days: 1))))
        .toList();
    final weekIncomplete = incomplete
        .where((t) => !t.createdAt.isBefore(startOfWeek))
        .toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(tasksProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Summary', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Incomplete work rolling into the day and week',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Today incomplete',
            emptyLabel: 'Nothing incomplete for today.',
            items: dayIncomplete.map((t) => t.title).toList(),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'This week incomplete',
            emptyLabel: 'Week is clear.',
            items: weekIncomplete.map((t) => t.title).toList(),
          ),
          const SizedBox(height: 16),
          if (sticky.isNotEmpty) ...[
            Material(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sticky task nudge',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These tasks keep showing up incomplete. Remove them or '
                      'make them weekly.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...sticky.map(
                      (t) => Text(
                        '· ${t.title}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.emptyLabel,
    required this.items,
  });

  final String title;
  final String emptyLabel;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(emptyLabel, style: theme.textTheme.bodyMedium)
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('· $item'),
            ),
          ),
      ],
    );
  }
}
