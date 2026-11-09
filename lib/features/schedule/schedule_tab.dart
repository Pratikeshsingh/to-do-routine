import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/routine_providers.dart';
import '../focus/focus_planner_placeholder.dart';
import 'current_focus_banner.dart';
import 'weekday_editor.dart';

class ScheduleTab extends ConsumerWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(routineBlocksProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(routineBlocksProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Schedule',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Today vs your Mon–Sun template',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          const CurrentFocusBanner(),
          const SizedBox(height: 24),
          blocksAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('Failed to load routine: $error'),
            data: (_) => const WeekdayEditor(),
          ),
          const SizedBox(height: 24),
          const FocusPlannerPlaceholder(),
          // Live Activity / WidgetKit intentionally omitted until core app works.
        ],
      ),
    );
  }
}
