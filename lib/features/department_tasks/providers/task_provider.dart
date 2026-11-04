import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/task_model.dart';
import '../../../core/models/task_comment_model.dart';
import '../../../core/models/task_reminder_model.dart';
import '../../../core/services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskItem> _departmentTasks = [];
  final Map<int, List<TaskComment>> _taskComments = {};
  final Map<int, List<TaskReminder>> _taskReminders = {};
  String _selectedStatusFilter = 'ALL';
  bool _isLoading = false;

  List<TaskItem> get departmentTasks => _departmentTasks;
  String get selectedStatusFilter => _selectedStatusFilter;
  bool get isLoading => _isLoading;

  List<TaskItem> get filteredTasks {
    if (_selectedStatusFilter == 'ALL') return _departmentTasks;
    return _departmentTasks.where((t) => t.status == _selectedStatusFilter).toList();
  }

  void setStatusFilter(String filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  Future<void> loadDepartmentTasks(int deptId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _departmentTasks = await AppDatabase.instance.getTasksByDepartment(deptId);
    } catch (e) {
      debugPrint('Load tasks error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> createTask(TaskItem task) async {
    final id = await AppDatabase.instance.insertTask(task);
    final inserted = task.copyWith(id: id);
    _departmentTasks.insert(0, inserted);
    notifyListeners();
    return id;
  }

  Future<bool> updateTask(TaskItem task) async {
    await AppDatabase.instance.updateTask(task);
    final idx = _departmentTasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _departmentTasks[idx] = task;
    }
    notifyListeners();
    return true;
  }

  Future<bool> updateTaskProgress({
    required int taskId,
    required String newStatus,
    required int progressPercent,
  }) async {
    final idx = _departmentTasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return false;

    final updated = _departmentTasks[idx].copyWith(
      status: newStatus,
      progressPercent: progressPercent,
    );

    await AppDatabase.instance.updateTask(updated);
    _departmentTasks[idx] = updated;
    notifyListeners();
    return true;
  }

  Future<List<TaskComment>> loadComments(int taskId) async {
    final comments = await AppDatabase.instance.getCommentsForTask(taskId);
    _taskComments[taskId] = comments;
    notifyListeners();
    return comments;
  }

  List<TaskComment> getComments(int taskId) => _taskComments[taskId] ?? [];

  Future<bool> addComment({
    required int taskId,
    required int userId,
    required String content,
  }) async {
    final newComment = TaskComment(
      taskId: taskId,
      userId: userId,
      content: content,
      createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );

    final id = await AppDatabase.instance.insertTaskComment(newComment);
    final savedComment = TaskComment(
      id: id,
      taskId: taskId,
      userId: userId,
      content: content,
      createdAt: newComment.createdAt,
    );

    _taskComments[taskId] = [...(_taskComments[taskId] ?? []), savedComment];

    // Cập nhật comment count
    final idx = _departmentTasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _departmentTasks[idx] = _departmentTasks[idx].copyWith(
        commentCount: _departmentTasks[idx].commentCount + 1,
      );
    }

    notifyListeners();
    return true;
  }

  Future<List<TaskReminder>> loadReminders(int taskId) async {
    final reminders = await AppDatabase.instance.getRemindersForTask(taskId);
    _taskReminders[taskId] = reminders;
    notifyListeners();
    return reminders;
  }

  List<TaskReminder> getReminders(int taskId) => _taskReminders[taskId] ?? [];

  Future<bool> addReminder({
    required int taskId,
    required String taskTitle,
    required String reminderTime,
    required String note,
  }) async {
    final reminder = TaskReminder(
      taskId: taskId,
      reminderTime: reminderTime,
      note: note,
    );

    final id = await AppDatabase.instance.insertTaskReminder(reminder);
    final savedReminder = TaskReminder(
      id: id,
      taskId: taskId,
      reminderTime: reminderTime,
      note: note,
      taskTitle: taskTitle,
    );

    _taskReminders[taskId] = [...(_taskReminders[taskId] ?? []), savedReminder];

    // Bắn thông báo test / hiển thị thông báo đã lên lịch
    await NotificationService.instance.showNotification(
      id: id,
      title: 'Đã đặt mốc nhắc nhở: $taskTitle',
      body: '$note (Thời gian nhắc: $reminderTime)',
    );

    notifyListeners();
    return true;
  }

  Future<bool> deleteReminder(int taskId, int reminderId) async {
    await AppDatabase.instance.deleteTaskReminder(reminderId);
    _taskReminders[taskId]?.removeWhere((r) => r.id == reminderId);
    notifyListeners();
    return true;
  }
}
