/// A checkable to-do item stored in the Tasks sheet.
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    this.recurrenceHint,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  /// Optional hint such as `weekly` when sticky incomplete tasks should recur.
  final String? recurrenceHint;

  TaskItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    String? recurrenceHint,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      recurrenceHint: recurrenceHint ?? this.recurrenceHint,
    );
  }

  factory TaskItem.fromSheetRow(Map<String, String> row) {
    return TaskItem(
      id: row['id'] ?? '',
      title: row['title'] ?? '',
      isCompleted: (row['isCompleted'] ?? 'false').toLowerCase() == 'true',
      createdAt: DateTime.tryParse(row['createdAt'] ?? '') ?? DateTime.now(),
      recurrenceHint: (row['recurrenceHint']?.trim().isEmpty ?? true)
          ? null
          : row['recurrenceHint']!.trim(),
    );
  }

  Map<String, String> toSheetRow() => {
        'id': id,
        'title': title,
        'isCompleted': '$isCompleted',
        'createdAt': createdAt.toUtc().toIso8601String(),
        'recurrenceHint': recurrenceHint ?? '',
      };
}
