/// Deadline-style focus that can displace scheduled blocks (v2 planner).
///
/// [capacityPercent] is 0–100: how much of the day this focus takes.
/// At 100% it also displaces non–brain-heavy slots.
class FocusOverride {
  const FocusOverride({
    required this.id,
    required this.title,
    required this.capacityPercent,
    required this.day,
  });

  final String id;
  final String title;
  final int capacityPercent;
  final DateTime day;

  FocusOverride copyWith({
    String? id,
    String? title,
    int? capacityPercent,
    DateTime? day,
  }) {
    return FocusOverride(
      id: id ?? this.id,
      title: title ?? this.title,
      capacityPercent: capacityPercent ?? this.capacityPercent,
      day: day ?? this.day,
    );
  }
}
