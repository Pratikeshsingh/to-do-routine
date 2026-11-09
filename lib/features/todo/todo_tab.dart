import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/task_providers.dart';

class TodoTab extends ConsumerStatefulWidget {
  const TodoTab({super.key});

  @override
  ConsumerState<TodoTab> createState() => _TodoTabState();
}

class _TodoTabState extends ConsumerState<TodoTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'New task',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _submit,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(tasksProvider.notifier).refresh(),
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Failed to load tasks: $error'),
                  ),
                ],
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 80),
                      Center(child: Text('No tasks yet.')),
                    ],
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return CheckboxListTile(
                      value: task.isCompleted,
                      onChanged: (_) {
                        ref.read(tasksProvider.notifier).toggleCompleted(task);
                      },
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: task.recurrenceHint == null
                          ? null
                          : Text('Hint: ${task.recurrenceHint}'),
                      secondary: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          ref.read(tasksProvider.notifier).removeTask(task.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    ref.read(tasksProvider.notifier).addTask(title);
    _controller.clear();
  }
}
