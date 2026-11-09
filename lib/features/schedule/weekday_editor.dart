import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/energy_tag.dart';
import '../../models/routine_block.dart';
import '../../providers/routine_providers.dart';

const _weekdayLabels = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// Weekday routine editor (Mon–Sun).
///
/// Editing a weekday updates that weekday for all upcoming weeks unless a
/// calendar event (or day override) forces a one-day exception.
class WeekdayEditor extends ConsumerStatefulWidget {
  const WeekdayEditor({super.key});

  @override
  ConsumerState<WeekdayEditor> createState() => _WeekdayEditorState();
}

class _WeekdayEditorState extends ConsumerState<WeekdayEditor> {
  int _selectedWeekday = DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    final blocks = ref.watch(blocksForWeekdayProvider(_selectedWeekday));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Week template', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Edits apply to every upcoming ${_weekdayLabels[_selectedWeekday]} '
          'unless a calendar override applies for a single day.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < 7; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_weekdayLabels[i]),
                    selected: _selectedWeekday == i,
                    onSelected: (_) => setState(() => _selectedWeekday = i),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (blocks.isEmpty)
          Text(
            'No blocks for ${_weekdayLabels[_selectedWeekday]}.',
            style: theme.textTheme.bodyMedium,
          )
        else
          ...blocks.map((block) => _BlockTile(
                block: block,
                onEdit: () => _editBlock(block),
              )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addBlock,
          icon: const Icon(Icons.add),
          label: const Text('Add block'),
        ),
      ],
    );
  }

  Future<void> _addBlock() async {
    final draft = RoutineBlock(
      id: 'blk-${DateTime.now().millisecondsSinceEpoch}',
      title: 'New focus',
      weekday: _selectedWeekday,
      startTime: 9 * 60,
      endTime: 10 * 60,
      themeColor: '#5B7C99',
      energyTag: EnergyTag.low,
    );
    await _editBlock(draft, isNew: true);
  }

  Future<void> _editBlock(RoutineBlock block, {bool isNew = false}) async {
    final titleController = TextEditingController(text: block.title);
    var energy = block.energyTag;
    var start = block.startTime;
    var end = block.endTime;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isNew ? 'Add block' : 'Edit block',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Locked product rule surfaced in the editor UI.
                    'Saving updates all upcoming '
                    '${_weekdayLabels[block.weekday]}s unless overridden.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<EnergyTag>(
                    segments: const [
                      ButtonSegment(
                        value: EnergyTag.low,
                        label: Text('Low energy'),
                      ),
                      ButtonSegment(
                        value: EnergyTag.high,
                        label: Text('High energy'),
                      ),
                    ],
                    selected: {energy},
                    onSelectionChanged: (value) {
                      setModalState(() => energy = value.first);
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Start'),
                    trailing: Text(_clock(start)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: start ~/ 60,
                          minute: start % 60,
                        ),
                      );
                      if (picked != null) {
                        setModalState(
                          () => start = picked.hour * 60 + picked.minute,
                        );
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('End'),
                    trailing: Text(_clock(end)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: end ~/ 60,
                          minute: end % 60,
                        ),
                      );
                      if (picked != null) {
                        setModalState(
                          () => end = picked.hour * 60 + picked.minute,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (saved == true && mounted) {
      await ref.read(routineBlocksProvider.notifier).saveBlock(
            block.copyWith(
              title: titleController.text.trim().isEmpty
                  ? block.title
                  : titleController.text.trim(),
              energyTag: energy,
              startTime: start,
              endTime: end,
            ),
          );
    }
    titleController.dispose();
  }

  String _clock(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({required this.block, required this.onEdit});

  final RoutineBlock block;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(block.themeColor);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 12,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      title: Text(block.title),
      subtitle: Text(
        '${_clock(block.startTime)}–${_clock(block.endTime)} · '
        '${block.energyTag.name} energy',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: onEdit,
      ),
    );
  }

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return Colors.blueGrey;
    if (cleaned.length == 6) return Color(0xFF000000 | value);
    return Color(value);
  }

  String _clock(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}
