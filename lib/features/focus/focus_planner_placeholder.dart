import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/focus_override.dart';
import '../../providers/focus_providers.dart';

/// Stub for the focus-override % capacity planner (full UX in v2).
class FocusPlannerPlaceholder extends ConsumerWidget {
  const FocusPlannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrides = ref.watch(focusOverridesProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Focus override', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Deadline focuses replace brain-heavy slots. A slider (0–100%) sets '
          'how much day capacity they take — planner UI ships in v2.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (overrides.isEmpty)
          OutlinedButton.icon(
            onPressed: () {
              ref.read(focusOverridesProvider.notifier).setPlaceholder(
                    FocusOverride(
                      id: const Uuid().v4(),
                      title: 'Demo focus (stub)',
                      capacityPercent: 40,
                      day: DateTime.now(),
                    ),
                  );
            },
            icon: const Icon(Icons.tune),
            label: const Text('Preview % slider stub'),
          )
        else ...[
          Text(
            '${overrides.first.title} · ${overrides.first.capacityPercent}%',
            style: theme.textTheme.bodyLarge,
          ),
          Slider(
            value: overrides.first.capacityPercent.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            label: '${overrides.first.capacityPercent}%',
            onChanged: (value) {
              ref.read(focusOverridesProvider.notifier).setPlaceholder(
                    overrides.first.copyWith(capacityPercent: value.round()),
                  );
            },
          ),
          TextButton(
            onPressed: () => ref.read(focusOverridesProvider.notifier).clear(),
            child: const Text('Clear stub'),
          ),
        ],
      ],
    );
  }
}
