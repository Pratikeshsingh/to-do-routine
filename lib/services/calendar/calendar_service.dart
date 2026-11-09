import '../../models/busy_interval.dart';

/// Seam for Google Calendar busy times that carve out of the schedule.
///
/// Live Calendar API sync is v2; v1 uses [FakeCalendarService].
abstract class CalendarService {
  Future<List<BusyInterval>> fetchBusyIntervals({
    required DateTime from,
    required DateTime to,
  });
}
