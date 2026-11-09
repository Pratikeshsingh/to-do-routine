import '../../models/routine_block.dart';
import '../../models/task.dart';

/// Abstraction over the user's Google Spreadsheet.
///
/// Production uses [GoogleSheetsService]; UI work and tests use
/// [FakeSheetsService] so the app runs without OAuth.
abstract class SheetsService {
  Future<List<RoutineBlock>> fetchRoutineBlocks();

  Future<void> upsertRoutineBlock(RoutineBlock block);

  Future<List<TaskItem>> fetchTasks();

  Future<void> upsertTask(TaskItem task);

  Future<void> deleteTask(String id);
}
