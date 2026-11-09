import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_routine/models/energy_tag.dart';
import 'package:to_do_routine/models/routine_block.dart';
import 'package:to_do_routine/models/task.dart';

void main() {
  test('RoutineBlock parses sheet row clocks', () {
    final block = RoutineBlock.fromSheetRow({
      'id': '1',
      'title': 'Studying AI',
      'weekday': '0',
      'startTime': '09:30',
      'endTime': '11:00',
      'themeColor': '#C47B4A',
      'energyTag': 'high',
    });

    expect(block.startTime, 9 * 60 + 30);
    expect(block.endTime, 11 * 60);
    expect(block.energyTag, EnergyTag.high);
    expect(block.containsMinuteOfDay(10 * 60), isTrue);
    expect(block.containsMinuteOfDay(11 * 60), isFalse);
  });

  test('TaskItem round-trips sheet row', () {
    final task = TaskItem.fromSheetRow({
      'id': 't1',
      'title': 'Read paper',
      'isCompleted': 'false',
      'createdAt': '2026-11-01T10:00:00.000Z',
      'recurrenceHint': 'weekly',
    });

    expect(task.recurrenceHint, 'weekly');
    expect(task.toSheetRow()['isCompleted'], 'false');
  });
}
