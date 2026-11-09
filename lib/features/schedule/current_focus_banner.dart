import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/energy_tag.dart';
import '../../models/routine_block.dart';
import '../../providers/routine_providers.dart';

/// Dashboard banner comparing wall-clock "now" to the scheduled weekday block.
class CurrentFocusBanner extends ConsumerWidget {
  const CurrentFocusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final block = ref.watch(currentFocusProvider);
    final busyAsync = ref.watch(busyIntervalsProvider);
    final theme = Theme.of(context);
    final nowLabel = DateFormat.jm().format(DateTime.now());

    final busyOverlap = busyAsync.maybeWhen(
      data: (intervals) {
        final now = DateTime.now();
        for (final interval in intervals) {
          if (interval.overlaps(now)) return interval.title;
        }
        return null;
      },
      orElse: () => null,
    );

    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current focus · $nowLabel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            if (busyOverlap != null) ...[
              Text(
                'Calendar busy: $busyOverlap',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (block != null)
                Text(
                  'Would have been: ${_blockSummary(block)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
            ] else if (block != null) ...[
              Text(
                block.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _blockSummary(block),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ] else
              Text(
                'Nothing scheduled right now.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _blockSummary(RoutineBlock block) {
    final energy = block.energyTag == EnergyTag.high ? 'high' : 'low';
    return '${_clock(block.startTime)}–${_clock(block.endTime)} · $energy brainpower';
  }

  String _clock(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}
