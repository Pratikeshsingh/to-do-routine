import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/busy_interval.dart';
import '../models/routine_block.dart';
import 'service_providers.dart';

final routineBlocksProvider =
    AsyncNotifierProvider<RoutineBlocksNotifier, List<RoutineBlock>>(
  RoutineBlocksNotifier.new,
);

class RoutineBlocksNotifier extends AsyncNotifier<List<RoutineBlock>> {
  @override
  Future<List<RoutineBlock>> build() {
    return ref.read(sheetsServiceProvider).fetchRoutineBlocks();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(sheetsServiceProvider).fetchRoutineBlocks(),
    );
  }

  /// Persists a weekday template change.
  ///
  /// Editing a weekday updates that weekday for all upcoming weeks unless a
  /// calendar event (or day override) forces a one-day exception.
  Future<void> saveBlock(RoutineBlock block) async {
    await ref.read(sheetsServiceProvider).upsertRoutineBlock(block);
    await refresh();
  }
}

final busyIntervalsProvider =
    FutureProvider.autoDispose<List<BusyInterval>>((ref) async {
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day);
  final to = from.add(const Duration(days: 1));
  return ref.read(calendarServiceProvider).fetchBusyIntervals(from: from, to: to);
});

/// The routine block that contains "now", if any (ignoring calendar carve-outs).
final currentFocusProvider = Provider<RoutineBlock?>((ref) {
  final blocks = ref.watch(routineBlocksProvider).asData?.value;
  if (blocks == null) return null;

  final now = DateTime.now();
  // Convert DateTime.weekday (Mon=1..Sun=7) to sheet weekday (Mon=0..Sun=6).
  final weekday = now.weekday - 1;
  final minuteOfDay = now.hour * 60 + now.minute;

  for (final block in blocks.where((b) => b.weekday == weekday)) {
    if (block.containsMinuteOfDay(minuteOfDay)) {
      return block;
    }
  }
  return null;
});

final blocksForWeekdayProvider =
    Provider.family<List<RoutineBlock>, int>((ref, weekday) {
  final blocks = ref.watch(routineBlocksProvider).asData?.value ?? const [];
  final filtered = blocks.where((b) => b.weekday == weekday).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  return filtered;
});
