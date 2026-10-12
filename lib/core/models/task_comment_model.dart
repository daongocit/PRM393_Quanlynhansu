class TaskComment {
  final int? id;
  final int taskId;
  final int userId;
  final String content;
  final String createdAt;

  // Joined display attributes
  final String? userName;
  final String? userAvatar;

  TaskComment({
    this.id,
    required this.taskId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt,
    };
  }

  factory TaskComment.fromMap(Map<String, dynamic> map) {
    return TaskComment(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      userId: map['user_id'] as int,
      content: map['content'] as String,
      createdAt: map['created_at'] as String,
      userName: map['user_name'] as String?,
      userAvatar: map['user_avatar'] as String?,
    );
  }
}
