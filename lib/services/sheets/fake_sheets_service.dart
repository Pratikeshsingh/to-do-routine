import 'package:uuid/uuid.dart';

import '../../models/energy_tag.dart';
import '../../models/routine_block.dart';
import '../../models/task.dart';
import 'sheets_service.dart';

/// In-memory Sheets stand-in for offline UI development.
class FakeSheetsService implements SheetsService {
  FakeSheetsService({Uuid? uuid}) : _uuid = uuid ?? const Uuid() {
    _seed();
  }

  final Uuid _uuid;
  final List<RoutineBlock> _blocks = [];
  final List<TaskItem> _tasks = [];

  void _seed() {
    _blocks.addAll([
      const RoutineBlock(
        id: 'blk-jobs',
        title: 'Applying jobs',
        weekday: 0,
        startTime: 9 * 60,
        endTime: 11 * 60,
        themeColor: '#5B7C99',
        energyTag: EnergyTag.low,
      ),
      const RoutineBlock(
        id: 'blk-vriend',
        title: 'Vriendtime app',
        weekday: 0,
        startTime: 11 * 60,
        endTime: 13 * 60,
        themeColor: '#6A8F7A',
        energyTag: EnergyTag.low,
      ),
      const RoutineBlock(
        id: 'blk-ai-study',
        title: 'Studying AI',
        weekday: 0,
        startTime: 14 * 60,
        endTime: 17 * 60,
        themeColor: '#C47B4A',
        energyTag: EnergyTag.high,
      ),
      const RoutineBlock(
        id: 'blk-videos',
        title: 'Channel videos',
        weekday: 2,
        startTime: 10 * 60,
        endTime: 13 * 60,
        themeColor: '#8B6B4A',
        energyTag: EnergyTag.low,
      ),
      const RoutineBlock(
        id: 'blk-blogs',
        title: 'AI blogs',
        weekday: 3,
        startTime: 9 * 60,
        endTime: 12 * 60,
        themeColor: '#A65D4E',
        energyTag: EnergyTag.high,
      ),
      const RoutineBlock(
        id: 'blk-jobs-fri',
        title: 'Applying jobs',
        weekday: 4,
        startTime: 9 * 60,
        endTime: 12 * 60,
        themeColor: '#5B7C99',
        energyTag: EnergyTag.low,
      ),
    ]);

    final now = DateTime.now();
    _tasks.addAll([
      TaskItem(
        id: 'task-1',
        title: 'Update resume for AI roles',
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      TaskItem(
        id: 'task-2',
        title: 'Draft Vriendtime onboarding copy',
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TaskItem(
        id: 'task-3',
        title: 'Outline next channel video',
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TaskItem(
        id: 'task-sticky',
        title: 'Read one AI paper',
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 12)),
        recurrenceHint: 'weekly',
      ),
    ]);
  }

  @override
  Future<List<RoutineBlock>> fetchRoutineBlocks() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_blocks);
  }

  @override
  Future<void> upsertRoutineBlock(RoutineBlock block) async {
    final index = _blocks.indexWhere((b) => b.id == block.id);
    if (index >= 0) {
      _blocks[index] = block;
    } else {
      _blocks.add(block);
    }
  }

  @override
  Future<List<TaskItem>> fetchTasks() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_tasks);
  }

  @override
  Future<void> upsertTask(TaskItem task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    } else {
      _tasks.add(
        task.id.isEmpty ? task.copyWith(id: _uuid.v4()) : task,
      );
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}
