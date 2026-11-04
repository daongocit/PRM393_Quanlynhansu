import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/leave_request_model.dart';
import '../models/shift_model.dart';
import '../models/task_model.dart';
import '../models/task_comment_model.dart';
import '../models/task_reminder_model.dart';

export '../models/user_model.dart';
export '../models/attendance_model.dart';
export '../models/leave_request_model.dart';
export '../models/shift_model.dart';
export '../models/task_model.dart';
export '../models/task_comment_model.dart';
export '../models/task_reminder_model.dart';

/// Abstract interface for database operations.
/// Both native (sqflite) and web (in-memory) implementations extend this.
abstract class DatabaseAdapter {
  Future<User?> getUserById(int id);
  Future<User?> getUserByEmail(String email);
  Future<List<User>> getAllUsers();
  Future<List<User>> getUsersByDepartment(int deptId);

  Future<Attendance?> getTodayAttendance(int userId, String date);
  Future<int> insertAttendance(Attendance attendance);
  Future<int> updateAttendance(Attendance attendance);
  Future<List<Attendance>> getUserAttendanceHistory(int userId);
  Future<List<Attendance>> getDepartmentTodayAttendance(int deptId, String date);

  Future<int> insertLeaveRequest(LeaveRequest request);
  Future<int> updateLeaveRequest(LeaveRequest request);
  Future<List<LeaveRequest>> getUserLeaveRequests(int userId);
  Future<List<LeaveRequest>> getAllPendingRequestsForManager(int deptId);
  Future<void> batchApproveRequests(List<int> requestIds, int approverId);

  Future<List<UserShiftAssignment>> getUserShifts(int userId);

  Future<int> insertTask(TaskItem task);
  Future<int> updateTask(TaskItem task);
  Future<List<TaskItem>> getTasksByDepartment(int deptId);
  Future<List<TaskComment>> getCommentsForTask(int taskId);
  Future<int> insertTaskComment(TaskComment comment);
  Future<List<TaskReminder>> getRemindersForTask(int taskId);
  Future<int> insertTaskReminder(TaskReminder reminder);
  Future<int> deleteTaskReminder(int reminderId);
}
