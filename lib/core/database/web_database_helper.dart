import 'package:flutter/foundation.dart';

import 'database_adapter.dart';

/// In-memory database for web platform (since sqflite doesn't support web).
/// Provides the same API as DatabaseHelper so the rest of the app works unchanged.
class WebDatabaseHelper extends DatabaseAdapter {
  static final WebDatabaseHelper instance = WebDatabaseHelper._init();
  WebDatabaseHelper._init();

  bool _initialized = false;

  // In-memory tables
  final List<Map<String, dynamic>> _departments = [];
  final List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _shifts = [];
  final List<Map<String, dynamic>> _userShiftAssignments = [];
  final List<Map<String, dynamic>> _attendance = [];
  final List<Map<String, dynamic>> _leaveRequests = [];
  final List<Map<String, dynamic>> _tasks = [];
  final List<Map<String, dynamic>> _taskComments = [];
  final List<Map<String, dynamic>> _taskReminders = [];

  int _nextAttendanceId = 100;
  int _nextLeaveRequestId = 100;
  int _nextTaskId = 100;
  int _nextCommentId = 100;
  int _nextReminderId = 100;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _seedInitialData();
    _initialized = true;
    debugPrint('[WebDB] In-memory database initialized with seed data.');
  }

  void _seedInitialData() {
    // 1. Departments
    _departments.addAll([
      {'id': 1, 'name': 'Phòng Công nghệ Thông tin', 'code': 'IT_DEPT', 'description': 'Phát triển phần mềm & Hạ tầng kỹ thuật'},
      {'id': 2, 'name': 'Phòng Nhân sự & Hành chính', 'code': 'HR_DEPT', 'description': 'Tuyển dụng, Chấm công, Phúc lợi'},
      {'id': 3, 'name': 'Phòng Kinh doanh & Tiếp thị', 'code': 'SALES_DEPT', 'description': 'Bán hàng và Chăm sóc khách hàng'},
    ]);

    // 2. Users (3 thành viên nhóm + Quản lý HR + Nhân viên thâm niên 2 năm)
    _users.addAll([
      {'id': 1, 'email': 'duyngoc@company.com', 'full_name': 'Duy Ngọc', 'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 'role': 'MANAGER', 'department_id': 1, 'position': 'Trưởng bộ phận Kỹ thuật IT', 'start_date': '2024-01-15', 'annual_leave_quota': 12, 'phone': '0901234567'},
      {'id': 2, 'email': 'uyen@company.com', 'full_name': 'Uyên', 'avatar_url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', 'role': 'EMPLOYEE', 'department_id': 1, 'position': 'Flutter Mobile Developer', 'start_date': '2026-07-12', 'annual_leave_quota': 12, 'phone': '0912345678'},
      {'id': 3, 'email': 'panh@company.com', 'full_name': 'P.Anh', 'avatar_url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', 'role': 'EMPLOYEE', 'department_id': 1, 'position': 'UI/UX & Mobile Specialist', 'start_date': '2026-06-01', 'annual_leave_quota': 12, 'phone': '0923456789'},
      {'id': 4, 'email': 'tranhr@company.com', 'full_name': 'Trần Thảo (HR)', 'avatar_url': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150', 'role': 'MANAGER', 'department_id': 2, 'position': 'Giám đốc Nhân sự & Đào tạo', 'start_date': '2023-03-01', 'annual_leave_quota': 12, 'phone': '0934567890'},
      {'id': 5, 'email': 'hoangnam@company.com', 'full_name': 'Hoàng Nam', 'avatar_url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'role': 'EMPLOYEE', 'department_id': 1, 'position': 'Senior Mobile Developer (Thâm niên 2 năm)', 'start_date': '2024-10-15', 'annual_leave_quota': 12, 'phone': '0945678901'},
    ]);

    // 3. Shifts
    _shifts.addAll([
      {'id': 1, 'code': 'CA01', 'name': 'Ca hành chính', 'start_time': '08:00', 'end_time': '17:00', 'color_hex': '0xFF1E3A8A'},
      {'id': 2, 'code': 'CA02', 'name': 'Ca chiều/tối', 'start_time': '14:00', 'end_time': '22:00', 'color_hex': '0xFF0D9488'},
      {'id': 3, 'code': 'CA03', 'name': 'Ca đêm', 'start_time': '22:00', 'end_time': '06:00', 'color_hex': '0xFF6366F1'},
    ]);

    // 4. User Shift Assignments
    _userShiftAssignments.addAll([
      {'id': 1, 'user_id': 2, 'shift_code': 'CA01', 'date': '2026-10-12', 'note': 'Lịch làm việc chuẩn'},
      {'id': 2, 'user_id': 2, 'shift_code': 'CA01', 'date': '2026-10-13', 'note': 'Lịch làm việc chuẩn'},
      {'id': 3, 'user_id': 2, 'shift_code': 'CA01', 'date': '2026-10-14', 'note': 'Lịch làm việc chuẩn'},
      {'id': 4, 'user_id': 2, 'shift_code': 'CA02', 'date': '2026-10-15', 'note': 'Ca chiều hỗ trợ triển khai hệ thống'},
      {'id': 5, 'user_id': 2, 'shift_code': 'CA01', 'date': '2026-10-16', 'note': 'Lịch làm việc chuẩn'},
      {'id': 6, 'user_id': 3, 'shift_code': 'CA01', 'date': '2026-10-12', 'note': 'Lịch làm việc chuẩn'},
      {'id': 7, 'user_id': 3, 'shift_code': 'CA01', 'date': '2026-10-13', 'note': 'Lịch làm việc chuẩn'},
      {'id': 8, 'user_id': 1, 'shift_code': 'CA01', 'date': '2026-10-12', 'note': 'Ca hành chính quản lý'},
      {'id': 9, 'user_id': 5, 'shift_code': 'CA01', 'date': '2026-10-12', 'note': 'Lịch làm việc chuẩn'},
      {'id': 10, 'user_id': 5, 'shift_code': 'CA01', 'date': '2026-10-13', 'note': 'Lịch làm việc chuẩn'},
      {'id': 11, 'user_id': 5, 'shift_code': 'CA01', 'date': '2026-10-14', 'note': 'Lịch làm việc chuẩn'},
      {'id': 12, 'user_id': 5, 'shift_code': 'CA01', 'date': '2026-10-15', 'note': 'Lịch làm việc chuẩn'},
      {'id': 13, 'user_id': 5, 'shift_code': 'CA01', 'date': '2026-10-16', 'note': 'Lịch làm việc chuẩn'},
    ]);

    // 5. Attendance
    _attendance.addAll([
      {'id': 1, 'user_id': 2, 'date': '2026-10-05', 'check_in_time': '07:55:00', 'check_out_time': '17:05:00', 'status': 'ON_TIME', 'work_hours': 8.0, 'note': 'Đúng giờ', 'shift_code': 'CA01'},
      {'id': 2, 'user_id': 2, 'date': '2026-10-06', 'check_in_time': '08:00:00', 'check_out_time': '17:02:00', 'status': 'ON_TIME', 'work_hours': 8.0, 'note': 'Đúng giờ', 'shift_code': 'CA01'},
      {'id': 3, 'user_id': 2, 'date': '2026-10-07', 'check_in_time': '08:25:00', 'check_out_time': '17:15:00', 'status': 'LATE', 'work_hours': 7.5, 'note': 'Kẹt xe đường Cầu Giấy', 'shift_code': 'CA01'},
      {'id': 4, 'user_id': 2, 'date': '2026-10-08', 'check_in_time': '07:58:00', 'check_out_time': '17:00:00', 'status': 'ON_TIME', 'work_hours': 8.0, 'note': 'Đúng giờ', 'shift_code': 'CA01'},
      {'id': 5, 'user_id': 2, 'date': '2026-10-09', 'check_in_time': '07:52:00', 'check_out_time': '16:00:00', 'status': 'EARLY_LEAVE', 'work_hours': 7.0, 'note': 'Xin về sớm việc gia đình', 'shift_code': 'CA01'},
      {'id': 6, 'user_id': 3, 'date': '2026-10-12', 'check_in_time': '07:50:00', 'check_out_time': null, 'status': 'ON_TIME', 'work_hours': 0.0, 'note': 'Đang làm việc', 'shift_code': 'CA01'},
      {'id': 7, 'user_id': 1, 'date': '2026-10-12', 'check_in_time': '08:05:00', 'check_out_time': null, 'status': 'ON_TIME', 'work_hours': 0.0, 'note': 'Đang làm việc', 'shift_code': 'CA01'},
      {'id': 8, 'user_id': 5, 'date': '2026-10-05', 'check_in_time': '07:50:00', 'check_out_time': '17:05:00', 'status': 'ON_TIME', 'work_hours': 8.0, 'note': 'Đúng giờ', 'shift_code': 'CA01'},
      {'id': 9, 'user_id': 5, 'date': '2026-10-06', 'check_in_time': '07:55:00', 'check_out_time': '17:00:00', 'status': 'ON_TIME', 'work_hours': 8.0, 'note': 'Đúng giờ', 'shift_code': 'CA01'},
      {'id': 10, 'user_id': 5, 'date': '2026-10-07', 'check_in_time': '07:52:00', 'check_out_time': '17:10:00', 'status': 'ON_TIME', 'work_hours': 8.0, 'note': 'Đúng giờ', 'shift_code': 'CA01'},
      {'id': 11, 'user_id': 5, 'date': '2026-10-08', 'check_in_time': '08:00:00', 'check_out_time': '17:02:00', 'status': 'ON_TIME', 'work_hours': 8.0, 'note': 'Đúng giờ', 'shift_code': 'CA01'},
      {'id': 12, 'user_id': 5, 'date': '2026-10-09', 'check_in_time': '07:50:00', 'check_out_time': '17:00:00', 'status': 'ON_TIME', 'work_hours': 8.0, 'note': 'Đúng giờ', 'shift_code': 'CA01'},
      {'id': 13, 'user_id': 5, 'date': '2026-10-12', 'check_in_time': '07:55:00', 'check_out_time': null, 'status': 'ON_TIME', 'work_hours': 0.0, 'note': 'Đang làm việc', 'shift_code': 'CA01'},
    ]);
    _nextAttendanceId = 14;

    // 6. Leave Requests (So sánh rõ nét Business Rule theo thâm niên!)
    // - Uyên (3 tháng): Quota = 3 ngày. Nghỉ 2 ngày -> Còn lại 1 ngày khả dụng.
    // - Hoàng Nam (2 năm thâm niên): Quota = 12 + 2 = 14 ngày. Nghỉ 3 ngày -> Còn lại 11 ngày khả dụng!
    _leaveRequests.addAll([
      {'id': 1, 'user_id': 2, 'request_type': 'ANNUAL_LEAVE', 'from_date': '2026-08-20', 'to_date': '2026-08-20', 'total_days': 1.0, 'reason': 'Giải quyết việc riêng gia đình ở quê', 'status': 'APPROVED', 'approver_id': 1, 'manager_comment': 'Đồng ý cho bạn nghỉ.', 'created_at': '2026-08-15 09:30:00'},
      {'id': 2, 'user_id': 2, 'request_type': 'ANNUAL_LEAVE', 'from_date': '2026-09-15', 'to_date': '2026-09-15', 'total_days': 1.0, 'reason': 'Khám sức khỏe định kỳ', 'status': 'APPROVED', 'approver_id': 1, 'manager_comment': 'Đã duyệt.', 'created_at': '2026-09-12 14:00:00'},
      {'id': 3, 'user_id': 3, 'request_type': 'ANNUAL_LEAVE', 'from_date': '2026-10-20', 'to_date': '2026-10-20', 'total_days': 1.0, 'reason': 'Về quê ăn cưới bạn thân', 'status': 'PENDING', 'approver_id': null, 'manager_comment': null, 'created_at': '2026-10-11 10:15:00'},
      {'id': 4, 'user_id': 3, 'request_type': 'LATE_EXPLANATION', 'from_date': '2026-10-07', 'to_date': '2026-10-07', 'total_days': 0.0, 'reason': 'Quên quẹt thẻ do hệ thống cửa vân tay bảo trì', 'status': 'PENDING', 'approver_id': null, 'manager_comment': null, 'created_at': '2026-10-08 08:30:00'},
      {'id': 5, 'user_id': 2, 'request_type': 'SHIFT_SWAP', 'from_date': '2026-10-15', 'to_date': '2026-10-15', 'total_days': 0.0, 'reason': 'Xin đổi ca CA02 sang ca CA01 cùng P.Anh', 'status': 'PENDING', 'approver_id': null, 'manager_comment': null, 'created_at': '2026-10-12 08:00:00'},
      {'id': 6, 'user_id': 5, 'request_type': 'ANNUAL_LEAVE', 'from_date': '2026-08-10', 'to_date': '2026-08-11', 'total_days': 2.0, 'reason': 'Nghỉ mát hè cùng gia đình', 'status': 'APPROVED', 'approver_id': 1, 'manager_comment': 'Đã phê duyệt cho Hoàng Nam.', 'created_at': '2026-08-05 08:30:00'},
      {'id': 7, 'user_id': 5, 'request_type': 'ANNUAL_LEAVE', 'from_date': '2026-09-22', 'to_date': '2026-09-22', 'total_days': 1.0, 'reason': 'Giải quyết thủ tục hành chính', 'status': 'APPROVED', 'approver_id': 1, 'manager_comment': 'Đã duyệt.', 'created_at': '2026-09-18 10:15:00'},
    ]);
    _nextLeaveRequestId = 8;

    // 7. Tasks
    _tasks.addAll([
      {'id': 1, 'title': 'Thiết kế giao diện HRM theo chuẩn ASOFT', 'description': 'Hoàn thiện 5 màn hình đơn từ & Quỹ phép cho nhân sự trải nghiệm mượt mà trực quan.', 'department_id': 1, 'creator_id': 1, 'assignee_id': 2, 'priority': 'HIGH', 'status': 'IN_PROGRESS', 'progress_percent': 70, 'deadline': '2026-10-18 17:00', 'created_at': '2026-10-10 09:00'},
      {'id': 2, 'title': 'Xây dựng Bảng Kanban & Tương tác Task', 'description': 'Xây dựng tính năng kéo thả công việc, xem deadline, trao đổi comment cùng phòng ban.', 'department_id': 1, 'creator_id': 1, 'assignee_id': 3, 'priority': 'HIGH', 'status': 'IN_PROGRESS', 'progress_percent': 50, 'deadline': '2026-10-20 18:00', 'created_at': '2026-10-10 10:00'},
      {'id': 3, 'title': 'Tối ưu hóa chấm công GPS & Quản lý duyệt đơn', 'description': 'Hoàn thiện tính năng Điểm danh Check-in/Out, bắt lỗi đi trễ và chức năng duyệt hàng loạt cho Manager.', 'department_id': 1, 'creator_id': 1, 'assignee_id': 1, 'priority': 'MEDIUM', 'status': 'IN_PROGRESS', 'progress_percent': 80, 'deadline': '2026-10-19 12:00', 'created_at': '2026-10-09 14:00'},
      {'id': 4, 'title': 'Báo cáo tổng hợp chấm công tháng 10', 'description': 'Tổng hợp số liệu ngày công thực tế, ngày nghỉ phép của toàn bộ phòng ban IT.', 'department_id': 1, 'creator_id': 1, 'assignee_id': 2, 'priority': 'LOW', 'status': 'TODO', 'progress_percent': 0, 'deadline': '2026-10-25 17:00', 'created_at': '2026-10-12 08:30'},
      {'id': 5, 'title': 'Nâng cấp Kiến trúc Clean Architecture & Caching', 'description': 'Tối ưu hóa performance và refactor codebase dự án HRM theo chuẩn Micro-services.', 'department_id': 1, 'creator_id': 1, 'assignee_id': 5, 'priority': 'HIGH', 'status': 'IN_PROGRESS', 'progress_percent': 60, 'deadline': '2026-10-22 18:00', 'created_at': '2026-10-10 08:30'},
    ]);
    _nextTaskId = 6;

    // 8. Task Comments
    _taskComments.addAll([
      {'id': 1, 'task_id': 1, 'user_id': 2, 'content': 'Đã kết nối với Database SQLite, màn hình Quỹ phép thể hiện đúng 3 tháng tối đa 3 ngày nghỉ rồi anh Ngọc nhé!', 'created_at': '2026-10-11 11:30:00'},
      {'id': 2, 'task_id': 1, 'user_id': 1, 'content': 'Rất tốt Uyên ơi! Nhớ bổ sung tính năng chặn gửi đơn khi nhân viên xin vượt quá số ngày phép còn lại nhé.', 'created_at': '2026-10-11 13:45:00'},
      {'id': 3, 'task_id': 2, 'user_id': 3, 'content': 'Em đang cài đặt hệ thống Notification nhắc nhở deadline trước 1 tiếng cho các task khẩn cấp.', 'created_at': '2026-10-12 09:15:00'},
      {'id': 4, 'task_id': 2, 'user_id': 1, 'content': 'Ok P.Anh, nhớ cho phép tất cả thành viên trong phòng IT đều đọc và comment được nhé.', 'created_at': '2026-10-12 10:00:00'},
      {'id': 5, 'task_id': 5, 'user_id': 5, 'content': 'Em đã hoàn tất thiết kế module Caching offline, hiệu năng truy vấn tăng 40% anh Ngọc nhé!', 'created_at': '2026-10-12 11:00:00'},
    ]);
    _nextCommentId = 6;

    // 9. Task Reminders
    _taskReminders.addAll([
      {'id': 1, 'task_id': 1, 'reminder_time': '2026-10-17 09:00', 'note': 'Nhắc nhở nộp bản kiểm thử giao diện màn hình Đơn từ', 'is_notified': 0},
      {'id': 2, 'task_id': 2, 'reminder_time': '2026-10-19 14:00', 'note': 'Nhắc nhở kiểm tra thông báo Notification trên thiết bị', 'is_notified': 0},
    ]);
    _nextReminderId = 3;
  }

  // ===================== CRUD & QUERY METHODS =====================

  // USERS
  @override
  Future<User?> getUserById(int id) async {
    await _ensureInitialized();
    final match = _users.where((u) => u['id'] == id);
    if (match.isNotEmpty) return User.fromMap(match.first);
    return null;
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    await _ensureInitialized();
    final match = _users.where((u) => u['email'] == email);
    if (match.isNotEmpty) return User.fromMap(match.first);
    return null;
  }

  @override
  Future<List<User>> getAllUsers() async {
    await _ensureInitialized();
    return _users.map((e) => User.fromMap(e)).toList();
  }

  @override
  Future<List<User>> getUsersByDepartment(int deptId) async {
    await _ensureInitialized();
    return _users
        .where((u) => u['department_id'] == deptId)
        .map((e) => User.fromMap(e))
        .toList();
  }

  // ATTENDANCE
  @override
  Future<Attendance?> getTodayAttendance(int userId, String date) async {
    await _ensureInitialized();
    final match = _attendance.where(
      (a) => a['user_id'] == userId && a['date'] == date,
    );
    if (match.isNotEmpty) return Attendance.fromMap(match.first);
    return null;
  }

  @override
  Future<int> insertAttendance(Attendance attendance) async {
    await _ensureInitialized();
    final map = attendance.toMap();
    map['id'] = _nextAttendanceId++;
    _attendance.add(map);
    return map['id'] as int;
  }

  @override
  Future<int> updateAttendance(Attendance attendance) async {
    await _ensureInitialized();
    final idx = _attendance.indexWhere((a) => a['id'] == attendance.id);
    if (idx != -1) {
      _attendance[idx] = attendance.toMap();
      return 1;
    }
    return 0;
  }

  @override
  Future<List<Attendance>> getUserAttendanceHistory(int userId) async {
    await _ensureInitialized();
    final filtered = _attendance
        .where((a) => a['user_id'] == userId)
        .toList()
      ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    return filtered.map((e) => Attendance.fromMap(e)).toList();
  }

  @override
  Future<List<Attendance>> getDepartmentTodayAttendance(int deptId, String date) async {
    await _ensureInitialized();
    final deptUsers = _users.where((u) => u['department_id'] == deptId).toList();
    List<Map<String, dynamic>> result = [];

    for (final user in deptUsers) {
      final att = _attendance.where(
        (a) => a['user_id'] == user['id'] && a['date'] == date,
      );
      if (att.isNotEmpty) {
        final merged = Map<String, dynamic>.from(att.first);
        merged['full_name'] = user['full_name'];
        merged['avatar_url'] = user['avatar_url'];
        merged['position'] = user['position'];
        result.add(merged);
      } else {
        result.add({
          'id': null,
          'user_id': user['id'],
          'date': date,
          'check_in_time': null,
          'check_out_time': null,
          'status': 'ABSENT',
          'work_hours': 0.0,
          'note': null,
          'shift_code': 'CA01',
          'full_name': user['full_name'],
          'avatar_url': user['avatar_url'],
          'position': user['position'],
        });
      }
    }

    return result.map((e) => Attendance.fromMap(e)).toList();
  }

  // LEAVE REQUESTS
  @override
  Future<int> insertLeaveRequest(LeaveRequest request) async {
    await _ensureInitialized();
    final map = request.toMap();
    map['id'] = _nextLeaveRequestId++;
    _leaveRequests.add(map);
    return map['id'] as int;
  }

  @override
  Future<int> updateLeaveRequest(LeaveRequest request) async {
    await _ensureInitialized();
    final idx = _leaveRequests.indexWhere((r) => r['id'] == request.id);
    if (idx != -1) {
      _leaveRequests[idx] = request.toMap();
      return 1;
    }
    return 0;
  }

  @override
  Future<List<LeaveRequest>> getUserLeaveRequests(int userId) async {
    await _ensureInitialized();
    List<Map<String, dynamic>> result = [];

    for (final lr in _leaveRequests.where((r) => r['user_id'] == userId)) {
      final user = _users.firstWhere((u) => u['id'] == lr['user_id']);
      final dept = _departments.firstWhere((d) => d['id'] == user['department_id']);
      final approver = lr['approver_id'] != null
          ? _users.where((u) => u['id'] == lr['approver_id']).firstOrNull
          : null;

      final merged = Map<String, dynamic>.from(lr);
      merged['user_name'] = user['full_name'];
      merged['user_avatar'] = user['avatar_url'];
      merged['department_name'] = dept['name'];
      merged['approver_name'] = approver?['full_name'];
      result.add(merged);
    }

    result.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return result.map((e) => LeaveRequest.fromMap(e)).toList();
  }

  @override
  Future<List<LeaveRequest>> getAllPendingRequestsForManager(int deptId) async {
    await _ensureInitialized();
    List<Map<String, dynamic>> result = [];
    final deptUserIds = _users
        .where((u) => u['department_id'] == deptId)
        .map((u) => u['id'])
        .toSet();

    for (final lr in _leaveRequests.where((r) => deptUserIds.contains(r['user_id']))) {
      final user = _users.firstWhere((u) => u['id'] == lr['user_id']);
      final dept = _departments.firstWhere((d) => d['id'] == user['department_id']);
      final approver = lr['approver_id'] != null
          ? _users.where((u) => u['id'] == lr['approver_id']).firstOrNull
          : null;

      final merged = Map<String, dynamic>.from(lr);
      merged['user_name'] = user['full_name'];
      merged['user_avatar'] = user['avatar_url'];
      merged['department_name'] = dept['name'];
      merged['approver_name'] = approver?['full_name'];
      result.add(merged);
    }

    result.sort((a, b) {
      final aIsPending = (a['status'] == 'PENDING') ? 0 : 1;
      final bIsPending = (b['status'] == 'PENDING') ? 0 : 1;
      if (aIsPending != bIsPending) return aIsPending.compareTo(bIsPending);
      return (b['id'] as int).compareTo(a['id'] as int);
    });

    return result.map((e) => LeaveRequest.fromMap(e)).toList();
  }

  @override
  Future<void> batchApproveRequests(List<int> requestIds, int approverId) async {
    await _ensureInitialized();
    for (final id in requestIds) {
      final idx = _leaveRequests.indexWhere((r) => r['id'] == id);
      if (idx != -1) {
        _leaveRequests[idx]['status'] = 'APPROVED';
        _leaveRequests[idx]['approver_id'] = approverId;
        _leaveRequests[idx]['manager_comment'] = 'Đã duyệt hàng loạt bởi Quản lý';
      }
    }
  }

  // SHIFTS
  @override
  Future<List<UserShiftAssignment>> getUserShifts(int userId) async {
    await _ensureInitialized();
    List<Map<String, dynamic>> result = [];

    final assignments = _userShiftAssignments
        .where((a) => a['user_id'] == userId)
        .toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

    for (final usa in assignments) {
      final shift = _shifts.firstWhere((s) => s['code'] == usa['shift_code']);
      final merged = Map<String, dynamic>.from(usa);
      merged['shift_name'] = shift['name'];
      merged['start_time'] = shift['start_time'];
      merged['end_time'] = shift['end_time'];
      result.add(merged);
    }

    return result.map((e) => UserShiftAssignment.fromMap(e)).toList();
  }

  // TASKS
  @override
  Future<int> insertTask(TaskItem task) async {
    await _ensureInitialized();
    final map = task.toMap();
    map['id'] = _nextTaskId++;
    _tasks.add(map);
    return map['id'] as int;
  }

  @override
  Future<int> updateTask(TaskItem task) async {
    await _ensureInitialized();
    final idx = _tasks.indexWhere((t) => t['id'] == task.id);
    if (idx != -1) {
      _tasks[idx] = task.toMap();
      return 1;
    }
    return 0;
  }

  @override
  Future<List<TaskItem>> getTasksByDepartment(int deptId) async {
    await _ensureInitialized();
    List<Map<String, dynamic>> result = [];

    for (final t in _tasks.where((t) => t['department_id'] == deptId)) {
      final assignee = _users.firstWhere((u) => u['id'] == t['assignee_id']);
      final creator = _users.firstWhere((u) => u['id'] == t['creator_id']);
      final dept = _departments.firstWhere((d) => d['id'] == t['department_id']);
      final commentCount = _taskComments.where((c) => c['task_id'] == t['id']).length;

      final merged = Map<String, dynamic>.from(t);
      merged['assignee_name'] = assignee['full_name'];
      merged['assignee_avatar'] = assignee['avatar_url'];
      merged['creator_name'] = creator['full_name'];
      merged['department_name'] = dept['name'];
      merged['comment_count'] = commentCount;
      result.add(merged);
    }

    result.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return result.map((e) => TaskItem.fromMap(e)).toList();
  }

  @override
  Future<List<TaskComment>> getCommentsForTask(int taskId) async {
    await _ensureInitialized();
    List<Map<String, dynamic>> result = [];

    for (final tc in _taskComments.where((c) => c['task_id'] == taskId)) {
      final user = _users.firstWhere((u) => u['id'] == tc['user_id']);
      final merged = Map<String, dynamic>.from(tc);
      merged['user_name'] = user['full_name'];
      merged['user_avatar'] = user['avatar_url'];
      result.add(merged);
    }

    result.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    return result.map((e) => TaskComment.fromMap(e)).toList();
  }

  @override
  Future<int> insertTaskComment(TaskComment comment) async {
    await _ensureInitialized();
    final map = comment.toMap();
    map['id'] = _nextCommentId++;
    _taskComments.add(map);
    return map['id'] as int;
  }

  @override
  Future<List<TaskReminder>> getRemindersForTask(int taskId) async {
    await _ensureInitialized();
    List<Map<String, dynamic>> result = [];

    for (final tr in _taskReminders.where((r) => r['task_id'] == taskId)) {
      final task = _tasks.firstWhere((t) => t['id'] == tr['task_id']);
      final merged = Map<String, dynamic>.from(tr);
      merged['task_title'] = task['title'];
      result.add(merged);
    }

    result.sort((a, b) => (a['reminder_time'] as String).compareTo(b['reminder_time'] as String));
    return result.map((e) => TaskReminder.fromMap(e)).toList();
  }

  @override
  Future<int> insertTaskReminder(TaskReminder reminder) async {
    await _ensureInitialized();
    final map = reminder.toMap();
    map['id'] = _nextReminderId++;
    _taskReminders.add(map);
    return map['id'] as int;
  }

  @override
  Future<int> deleteTaskReminder(int reminderId) async {
    await _ensureInitialized();
    final before = _taskReminders.length;
    _taskReminders.removeWhere((r) => r['id'] == reminderId);
    return before - _taskReminders.length;
  }
}
