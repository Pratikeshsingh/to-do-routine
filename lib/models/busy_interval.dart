/// A busy window carved out of the schedule by Google Calendar (stub seam).
class BusyInterval {
  const BusyInterval({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;

  bool overlaps(DateTime instant) =>
      !instant.isBefore(start) && instant.isBefore(end);
}
