import 'energy_tag.dart';

/// A recurring weekday schedule block stored in the RoutineBlocks sheet.
///
/// Editing a weekday template updates that weekday for all upcoming weeks
/// unless a calendar event (or day override) forces a one-day exception.
class RoutineBlock {
  const RoutineBlock({
    required this.id,
    required this.title,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.themeColor,
    required this.energyTag,
  });

  final String id;
  final String title;

  /// Dart [DateTime.weekday] style minus one: 0 = Monday … 6 = Sunday.
  final int weekday;

  /// Minutes from midnight (inclusive).
  final int startTime;

  /// Minutes from midnight (exclusive).
  final int endTime;

  /// ARGB hex such as `#4A6FA5`.
  final String themeColor;
  final EnergyTag energyTag;

  bool containsMinuteOfDay(int minuteOfDay) =>
      minuteOfDay >= startTime && minuteOfDay < endTime;

  RoutineBlock copyWith({
    String? id,
    String? title,
    int? weekday,
    int? startTime,
    int? endTime,
    String? themeColor,
    EnergyTag? energyTag,
  }) {
    return RoutineBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      themeColor: themeColor ?? this.themeColor,
      energyTag: energyTag ?? this.energyTag,
    );
  }

  factory RoutineBlock.fromSheetRow(Map<String, String> row) {
    return RoutineBlock(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      weekday: int.tryParse(row['weekday'] ?? '') ?? 0,
      startTime: _parseClock(row['startTime'] ?? '0'),
      endTime: _parseClock(row['endTime'] ?? '0'),
      themeColor: row['themeColor'] ?? '#4A6FA5',
      energyTag: EnergyTag.fromSheet(row['energyTag'] ?? 'low'),
    );
  }

  Map<String, String> toSheetRow() => {
        'id': id,
        'title': title,
        'weekday': '$weekday',
        'startTime': _formatClock(startTime),
        'endTime': _formatClock(endTime),
        'themeColor': themeColor,
        'energyTag': energyTag.toSheet(),
      };

  static int _parseClock(String raw) {
    final trimmed = raw.trim();
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return h * 60 + m;
    }
    return int.tryParse(trimmed) ?? 0;
  }

  static String _formatClock(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
