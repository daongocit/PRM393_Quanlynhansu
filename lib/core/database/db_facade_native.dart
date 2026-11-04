import 'database_adapter.dart';
import 'database_helper.dart';

/// Native implementation – wraps the existing DatabaseHelper (sqflite).
DatabaseAdapter createDatabaseImpl() => NativeDatabaseAdapter.instance;

class NativeDatabaseAdapter extends DatabaseAdapter {
  static final NativeDatabaseAdapter instance = NativeDatabaseAdapter._();
  NativeDatabaseAdapter._();

  final _db = DatabaseHelper.instance;

  @override
  Future<User?> getUserById(int id) => _db.getUserById(id);
  @override
  Future<User?> getUserByEmail(String email) => _db.getUserByEmail(email);
  @override
  Future<List<User>> getAllUsers() => _db.getAllUsers();
  @override
  Future<List<User>> getUsersByDepartment(int deptId) => _db.getUsersByDepartment(deptId);

  @override
  Future<Attendance?> getTodayAttendance(int userId, String date) => _db.getTodayAttendance(userId, date);
  @override
  Future<int> insertAttendance(Attendance attendance) => _db.insertAttendance(attendance);
  @override
  Future<int> updateAttendance(Attendance attendance) => _db.updateAttendance(attendance);
  @override
  Future<List<Attendance>> getUserAttendanceHistory(int userId) => _db.getUserAttendanceHistory(userId);
  @override
  Future<List<Attendance>> getDepartmentTodayAttendance(int deptId, String date) => _db.getDepartmentTodayAttendance(deptId, date);

  @override
  Future<int> insertLeaveRequest(LeaveRequest request) => _db.insertLeaveRequest(request);
  @override
  Future<int> updateLeaveRequest(LeaveRequest request) => _db.updateLeaveRequest(request);
  @override
  Future<List<LeaveRequest>> getUserLeaveRequests(int userId) => _db.getUserLeaveRequests(userId);
  @override
  Future<List<LeaveRequest>> getAllPendingRequestsForManager(int deptId) => _db.getAllPendingRequestsForManager(deptId);
  @override
  Future<void> batchApproveRequests(List<int> requestIds, int approverId) => _db.batchApproveRequests(requestIds, approverId);

  @override
  Future<List<UserShiftAssignment>> getUserShifts(int userId) => _db.getUserShifts(userId);

  @override
  Future<int> insertTask(TaskItem task) => _db.insertTask(task);
  @override
  Future<int> updateTask(TaskItem task) => _db.updateTask(task);
  @override
  Future<List<TaskItem>> getTasksByDepartment(int deptId) => _db.getTasksByDepartment(deptId);
  @override
  Future<List<TaskComment>> getCommentsForTask(int taskId) => _db.getCommentsForTask(taskId);
  @override
  Future<int> insertTaskComment(TaskComment comment) => _db.insertTaskComment(comment);
  @override
  Future<List<TaskReminder>> getRemindersForTask(int taskId) => _db.getRemindersForTask(taskId);
  @override
  Future<int> insertTaskReminder(TaskReminder reminder) => _db.insertTaskReminder(reminder);
  @override
  Future<int> deleteTaskReminder(int reminderId) => _db.deleteTaskReminder(reminderId);
}
