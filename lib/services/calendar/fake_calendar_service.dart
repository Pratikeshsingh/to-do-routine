import '../../models/busy_interval.dart';
import 'calendar_service.dart';

/// Returns a sample busy window so Schedule UI can show carve-outs offline.
class FakeCalendarService implements CalendarService {
  @override
  Future<List<BusyInterval>> fetchBusyIntervals({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final today = DateTime(from.year, from.month, from.day);
    return [
      BusyInterval(
        id: 'busy-standup',
        title: 'Calendar: standup (stub)',
        start: today.add(const Duration(hours: 12)),
        end: today.add(const Duration(hours: 12, minutes: 30)),
      ),
    ];
  }
}
