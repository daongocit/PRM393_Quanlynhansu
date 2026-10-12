class TaskReminder {
  final int? id;
  final int taskId;
  final String reminderTime; // 'YYYY-MM-DD HH:mm'
  final String note;
  final int isNotified; // 0 or 1

  // Joined task title
  final String? taskTitle;

  TaskReminder({
    this.id,
    required this.taskId,
    required this.reminderTime,
    required this.note,
    this.isNotified = 0,
    this.taskTitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'reminder_time': reminderTime,
      'note': note,
      'is_notified': isNotified,
    };
  }

  factory TaskReminder.fromMap(Map<String, dynamic> map) {
    return TaskReminder(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      reminderTime: map['reminder_time'] as String,
      note: map['note'] as String? ?? '',
      isNotified: map['is_notified'] as int? ?? 0,
      taskTitle: map['task_title'] as String?,
    );
  }
}
