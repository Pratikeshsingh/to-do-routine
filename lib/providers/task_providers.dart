import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import 'service_providers.dart';

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskItem>>(TasksNotifier.new);

class TasksNotifier extends AsyncNotifier<List<TaskItem>> {
  static const _uuid = Uuid();

  @override
  Future<List<TaskItem>> build() {
    return ref.read(sheetsServiceProvider).fetchTasks();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(sheetsServiceProvider).fetchTasks(),
    );
  }

  Future<void> toggleCompleted(TaskItem task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await ref.read(sheetsServiceProvider).upsertTask(updated);
    await refresh();
  }

  Future<void> addTask(String title) async {
    final task = TaskItem(
      id: _uuid.v4(),
      title: title.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    await ref.read(sheetsServiceProvider).upsertTask(task);
    await refresh();
  }

  Future<void> removeTask(String id) async {
    await ref.read(sheetsServiceProvider).deleteTask(id);
    await refresh();
  }
}

/// Incomplete tasks for Summary day/week views.
final incompleteTasksProvider = Provider<List<TaskItem>>((ref) {
  final tasks = ref.watch(tasksProvider).asData?.value ?? const [];
  return tasks.where((t) => !t.isCompleted).toList();
});

/// Sticky incomplete tasks that warrant a nudge (v1 heuristic stub).
final stickyIncompleteNudgeProvider = Provider<List<TaskItem>>((ref) {
  final incomplete = ref.watch(incompleteTasksProvider);
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  return incomplete
      .where(
        (t) =>
            t.createdAt.isBefore(cutoff) ||
            (t.recurrenceHint?.isNotEmpty ?? false),
      )
      .toList();
});
