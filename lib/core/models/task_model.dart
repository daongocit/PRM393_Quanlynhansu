class TaskItem {
  final int? id;
  final String title;
  final String description;
  final int departmentId;
  final int creatorId;
  final int assigneeId;
  final String priority; // 'LOW', 'MEDIUM', 'HIGH'
  final String status; // 'TODO', 'IN_PROGRESS', 'DONE'
  final int progressPercent; // 0 - 100
  final String deadline; // 'YYYY-MM-DD HH:mm'
  final String createdAt;

  // Joined display attributes
  final String? assigneeName;
  final String? assigneeAvatar;
  final String? creatorName;
  final String? departmentName;
  final int commentCount;

  TaskItem({
    this.id,
    required this.title,
    required this.description,
    required this.departmentId,
    required this.creatorId,
    required this.assigneeId,
    this.priority = 'MEDIUM',
    this.status = 'TODO',
    this.progressPercent = 0,
    required this.deadline,
    required this.createdAt,
    this.assigneeName,
    this.assigneeAvatar,
    this.creatorName,
    this.departmentName,
    this.commentCount = 0,
  });

  String get priorityDisplay {
    switch (priority) {
      case 'HIGH':
        return 'Khẩn cấp';
      case 'MEDIUM':
        return 'Trung bình';
      case 'LOW':
        return 'Thấp';
      default:
        return priority;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'TODO':
        return 'Chưa làm';
      case 'IN_PROGRESS':
        return 'Đang làm';
      case 'DONE':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  bool get isOverdue {
    try {
      String str = deadline.trim().replaceFirst(' ', 'T');
      if (str.length == 16) str = '$str:00';
      final deadlineDate = DateTime.parse(str);
      return DateTime.now().isAfter(deadlineDate) && status != 'DONE';
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'department_id': departmentId,
      'creator_id': creatorId,
      'assignee_id': assigneeId,
      'priority': priority,
      'status': status,
      'progress_percent': progressPercent,
      'deadline': deadline,
      'created_at': createdAt,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      departmentId: map['department_id'] as int,
      creatorId: map['creator_id'] as int,
      assigneeId: map['assignee_id'] as int,
      priority: map['priority'] as String? ?? 'MEDIUM',
      status: map['status'] as String? ?? 'TODO',
      progressPercent: map['progress_percent'] as int? ?? 0,
      deadline: map['deadline'] as String,
      createdAt: map['created_at'] as String,
      assigneeName: map['assignee_name'] as String?,
      assigneeAvatar: map['assignee_avatar'] as String?,
      creatorName: map['creator_name'] as String?,
      departmentName: map['department_name'] as String?,
      commentCount: map['comment_count'] as int? ?? 0,
    );
  }

  TaskItem copyWith({
    int? id,
    String? title,
    String? description,
    int? departmentId,
    int? creatorId,
    int? assigneeId,
    String? priority,
    String? status,
    int? progressPercent,
    String? deadline,
    String? createdAt,
    String? assigneeName,
    String? assigneeAvatar,
    String? creatorName,
    String? departmentName,
    int? commentCount,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      departmentId: departmentId ?? this.departmentId,
      creatorId: creatorId ?? this.creatorId,
      assigneeId: assigneeId ?? this.assigneeId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeAvatar: assigneeAvatar ?? this.assigneeAvatar,
      creatorName: creatorName ?? this.creatorName,
      departmentName: departmentName ?? this.departmentName,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
