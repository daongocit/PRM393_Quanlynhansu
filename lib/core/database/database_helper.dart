import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/leave_request_model.dart';
import '../models/shift_model.dart';
import '../models/task_model.dart';
import '../models/task_comment_model.dart';
import '../models/task_reminder_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hrm_company_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // In web, fallback or default sqflite
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final docDir = await getApplicationDocumentsDirectory();
      path = join(docDir.path, 'HRM_App_Data', filePath);
      final dir = Directory(dirname(path));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await _onOpenDB(db);
      },
      onOpen: _onOpenDB,
    );
  }

  Future<void> _onOpenDB(Database db) async {
    // Đảm bảo Hoàng Nam (Nhân viên 2 năm thâm niên) luôn tồn tại ngay cả trên SQLite DB đã tạo trước đó
    try {
      final existing = await db.rawQuery('SELECT id FROM users WHERE email = ?', ['hoangnam@company.com']);
      if (existing.isEmpty) {
        await db.rawInsert('''
          INSERT OR IGNORE INTO users (id, email, full_name, avatar_url, role, department_id, position, start_date, annual_leave_quota, phone) VALUES
          (5, 'hoangnam@company.com', 'Hoàng Nam', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'EMPLOYEE', 1, 'Senior Mobile Developer (Thâm niên 2 năm)', '2024-10-15', 12, '0945678901')
        ''');
        await db.rawInsert('''
          INSERT OR IGNORE INTO user_shift_assignments (user_id, shift_code, date, note) VALUES
          (5, 'CA01', '2026-10-12', 'Lịch làm việc chuẩn'),
          (5, 'CA01', '2026-10-13', 'Lịch làm việc chuẩn'),
          (5, 'CA01', '2026-10-14', 'Lịch làm việc chuẩn'),
          (5, 'CA01', '2026-10-15', 'Lịch làm việc chuẩn'),
          (5, 'CA01', '2026-10-16', 'Lịch làm việc chuẩn')
        ''');
        await db.rawInsert('''
          INSERT OR IGNORE INTO attendance (user_id, date, check_in_time, check_out_time, status, work_hours, note, shift_code) VALUES
          (5, '2026-10-05', '07:50:00', '17:05:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
          (5, '2026-10-06', '07:55:00', '17:00:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
          (5, '2026-10-07', '07:52:00', '17:10:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
          (5, '2026-10-08', '08:00:00', '17:02:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
          (5, '2026-10-09', '07:50:00', '17:00:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
          (5, '2026-10-12', '07:55:00', NULL, 'ON_TIME', 0.0, 'Đang làm việc', 'CA01')
        ''');
        await db.rawInsert('''
          INSERT OR IGNORE INTO leave_requests (id, user_id, request_type, from_date, to_date, total_days, reason, status, approver_id, manager_comment, created_at) VALUES
          (6, 5, 'ANNUAL_LEAVE', '2026-08-10', '2026-08-11', 2.0, 'Nghỉ mát hè cùng gia đình', 'APPROVED', 1, 'Đã phê duyệt cho Hoàng Nam.', '2026-08-05 08:30:00'),
          (7, 5, 'ANNUAL_LEAVE', '2026-09-22', '2026-09-22', 1.0, 'Giải quyết thủ tục hành chính', 'APPROVED', 1, 'Đã duyệt.', '2026-09-18 10:15:00')
        ''');
        await db.rawInsert('''
          INSERT OR IGNORE INTO tasks (id, title, description, department_id, creator_id, assignee_id, priority, status, progress_percent, deadline, created_at) VALUES
          (5, 'Nâng cấp Kiến trúc Clean Architecture & Caching', 'Tối ưu hóa performance và refactor codebase dự án HRM theo chuẩn Micro-services.', 1, 1, 5, 'HIGH', 'IN_PROGRESS', 60, '2026-10-22 18:00', '2026-10-10 08:30')
        ''');
        await db.rawInsert('''
          INSERT OR IGNORE INTO task_comments (task_id, user_id, content, created_at) VALUES
          (5, 5, 'Em đã hoàn tất thiết kế module Caching offline, hiệu năng truy vấn tăng 40% anh Ngọc nhé!', '2026-10-12 11:00:00')
        ''');
      }
    } catch (_) {}
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. DEPARTMENTS
    await db.execute('''
      CREATE TABLE departments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        description TEXT
      )
    ''');

    // 2. USERS
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        full_name TEXT NOT NULL,
        avatar_url TEXT NOT NULL,
        role TEXT NOT NULL, -- 'EMPLOYEE' or 'MANAGER'
        department_id INTEGER NOT NULL,
        position TEXT NOT NULL,
        start_date TEXT NOT NULL, -- 'YYYY-MM-DD'
        annual_leave_quota INTEGER DEFAULT 12,
        phone TEXT,
        FOREIGN KEY (department_id) REFERENCES departments (id)
      )
    ''');

    // 3. SHIFTS
    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE, -- 'CA01', 'CA02', 'CA03'
        name TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        color_hex TEXT
      )
    ''');

    // 4. USER_SHIFT_ASSIGNMENTS
    await db.execute('''
      CREATE TABLE user_shift_assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        shift_code TEXT NOT NULL,
        date TEXT NOT NULL, -- 'YYYY-MM-DD'
        note TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (shift_code) REFERENCES shifts (code)
      )
    ''');

    // 5. ATTENDANCE
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL, -- 'YYYY-MM-DD'
        check_in_time TEXT,
        check_out_time TEXT,
        status TEXT NOT NULL, -- 'ON_TIME', 'LATE', 'EARLY_LEAVE', 'ABSENT'
        work_hours REAL DEFAULT 0.0,
        note TEXT,
        shift_code TEXT DEFAULT 'CA01',
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 6. LEAVE_REQUESTS
    await db.execute('''
      CREATE TABLE leave_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        request_type TEXT NOT NULL,
        from_date TEXT NOT NULL,
        to_date TEXT NOT NULL,
        total_days REAL NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL, -- 'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'
        approver_id INTEGER,
        manager_comment TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (approver_id) REFERENCES users (id)
      )
    ''');

    // 7. TASKS
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        department_id INTEGER NOT NULL,
        creator_id INTEGER NOT NULL,
        assignee_id INTEGER NOT NULL,
        priority TEXT DEFAULT 'MEDIUM', -- 'LOW', 'MEDIUM', 'HIGH'
        status TEXT DEFAULT 'TODO', -- 'TODO', 'IN_PROGRESS', 'DONE'
        progress_percent INTEGER DEFAULT 0,
        deadline TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (department_id) REFERENCES departments (id),
        FOREIGN KEY (creator_id) REFERENCES users (id),
        FOREIGN KEY (assignee_id) REFERENCES users (id)
      )
    ''');

    // 8. TASK_COMMENTS
    await db.execute('''
      CREATE TABLE task_comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 9. TASK_REMINDERS
    await db.execute('''
      CREATE TABLE task_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        reminder_time TEXT NOT NULL,
        note TEXT,
        is_notified INTEGER DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // Seed Initial Mock Data
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // 1. Departments
    await db.rawInsert('''
      INSERT INTO departments (id, name, code, description) VALUES
      (1, 'Phòng Công nghệ Thông tin', 'IT_DEPT', 'Phát triển phần mềm & Hạ tầng kỹ thuật'),
      (2, 'Phòng Nhân sự & Hành chính', 'HR_DEPT', 'Tuyển dụng, Chấm công, Phúc lợi'),
      (3, 'Phòng Kinh doanh & Tiếp thị', 'SALES_DEPT', 'Bán hàng và Chăm sóc khách hàng')
    ''');

    // 2. Users (3 thành viên nhóm + Quản lý HR + Nhân viên thâm niên 2 năm)
    // Duy Ngọc: MANAGER (IT Department)
    // Uyên: EMPLOYEE (Start: 2026-07-12 -> 3 tháng thâm niên!)
    // P.Anh: EMPLOYEE (Start: 2026-06-01 -> 4 tháng thâm niên!)
    // Hoàng Nam: EMPLOYEE (Start: 2024-10-15 -> 2 năm / 24 tháng thâm niên -> Thưởng +2 ngày phép!)
    await db.rawInsert('''
      INSERT INTO users (id, email, full_name, avatar_url, role, department_id, position, start_date, annual_leave_quota, phone) VALUES
      (1, 'duyngoc@company.com', 'Duy Ngọc', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 'MANAGER', 1, 'Trưởng bộ phận Kỹ thuật IT', '2024-01-15', 12, '0901234567'),
      (2, 'uyen@company.com', 'Uyên', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', 'EMPLOYEE', 1, 'Flutter Mobile Developer', '2026-07-12', 12, '0912345678'),
      (3, 'panh@company.com', 'P.Anh', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', 'EMPLOYEE', 1, 'UI/UX & Mobile Specialist', '2026-06-01', 12, '0923456789'),
      (4, 'tranhr@company.com', 'Trần Thảo (HR)', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150', 'MANAGER', 2, 'Giám đốc Nhân sự & Đào tạo', '2023-03-01', 12, '0934567890'),
      (5, 'hoangnam@company.com', 'Hoàng Nam', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'EMPLOYEE', 1, 'Senior Mobile Developer (Thâm niên 2 năm)', '2024-10-15', 12, '0945678901')
    ''');

    // 3. Shifts
    await db.rawInsert('''
      INSERT INTO shifts (id, code, name, start_time, end_time, color_hex) VALUES
      (1, 'CA01', 'Ca hành chính', '08:00', '17:00', '0xFF1E3A8A'),
      (2, 'CA02', 'Ca chiều/tối', '14:00', '22:00', '0xFF0D9488'),
      (3, 'CA03', 'Ca đêm', '22:00', '06:00', '0xFF6366F1')
    ''');

    // 4. User Shift Assignments for current week
    await db.rawInsert('''
      INSERT INTO user_shift_assignments (user_id, shift_code, date, note) VALUES
      (2, 'CA01', '2026-10-12', 'Lịch làm việc chuẩn'),
      (2, 'CA01', '2026-10-13', 'Lịch làm việc chuẩn'),
      (2, 'CA01', '2026-10-14', 'Lịch làm việc chuẩn'),
      (2, 'CA02', '2026-10-15', 'Ca chiều hỗ trợ triển khai hệ thống'),
      (2, 'CA01', '2026-10-16', 'Lịch làm việc chuẩn'),
      (3, 'CA01', '2026-10-12', 'Lịch làm việc chuẩn'),
      (3, 'CA01', '2026-10-13', 'Lịch làm việc chuẩn'),
      (1, 'CA01', '2026-10-12', 'Ca hành chính quản lý'),
      (5, 'CA01', '2026-10-12', 'Lịch làm việc chuẩn'),
      (5, 'CA01', '2026-10-13', 'Lịch làm việc chuẩn'),
      (5, 'CA01', '2026-10-14', 'Lịch làm việc chuẩn'),
      (5, 'CA01', '2026-10-15', 'Lịch làm việc chuẩn'),
      (5, 'CA01', '2026-10-16', 'Lịch làm việc chuẩn')
    ''');

    // 5. Attendance (Historical records for October 2026)
    await db.rawInsert('''
      INSERT INTO attendance (user_id, date, check_in_time, check_out_time, status, work_hours, note, shift_code) VALUES
      (2, '2026-10-05', '07:55:00', '17:05:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
      (2, '2026-10-06', '08:00:00', '17:02:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
      (2, '2026-10-07', '08:25:00', '17:15:00', 'LATE', 7.5, 'Kẹt xe đường Cầu Giấy', 'CA01'),
      (2, '2026-10-08', '07:58:00', '17:00:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
      (2, '2026-10-09', '07:52:00', '16:00:00', 'EARLY_LEAVE', 7.0, 'Xin về sớm việc gia đình', 'CA01'),
      (3, '2026-10-12', '07:50:00', NULL, 'ON_TIME', 0.0, 'Đang làm việc', 'CA01'),
      (1, '2026-10-12', '08:05:00', NULL, 'ON_TIME', 0.0, 'Đang làm việc', 'CA01'),
      (5, '2026-10-05', '07:50:00', '17:05:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
      (5, '2026-10-06', '07:55:00', '17:00:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
      (5, '2026-10-07', '07:52:00', '17:10:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
      (5, '2026-10-08', '08:00:00', '17:02:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
      (5, '2026-10-09', '07:50:00', '17:00:00', 'ON_TIME', 8.0, 'Đúng giờ', 'CA01'),
      (5, '2026-10-12', '07:55:00', NULL, 'ON_TIME', 0.0, 'Đang làm việc', 'CA01')
    ''');

    // 6. Leave Requests (So sánh rõ nét Business Rule theo thâm niên!)
    // - Uyên (3 tháng): Quota = 3 ngày. Nghỉ 2 ngày -> Còn lại 1 ngày khả dụng.
    // - Hoàng Nam (2 năm thâm niên): Quota = 12 + 2 = 14 ngày. Nghỉ 3 ngày -> Còn lại 11 ngày khả dụng!
    await db.rawInsert('''
      INSERT INTO leave_requests (id, user_id, request_type, from_date, to_date, total_days, reason, status, approver_id, manager_comment, created_at) VALUES
      (1, 2, 'ANNUAL_LEAVE', '2026-08-20', '2026-08-20', 1.0, 'Giải quyết việc riêng gia đình ở quê', 'APPROVED', 1, 'Đồng ý cho bạn nghỉ.', '2026-08-15 09:30:00'),
      (2, 2, 'ANNUAL_LEAVE', '2026-09-15', '2026-09-15', 1.0, 'Khám sức khỏe định kỳ', 'APPROVED', 1, 'Đã duyệt.', '2026-09-12 14:00:00'),
      (3, 3, 'ANNUAL_LEAVE', '2026-10-20', '2026-10-20', 1.0, 'Về quê ăn cưới bạn thân', 'PENDING', NULL, NULL, '2026-10-11 10:15:00'),
      (4, 3, 'LATE_EXPLANATION', '2026-10-07', '2026-10-07', 0.0, 'Quên quẹt thẻ do hệ thống cửa vân tay bảo trì', 'PENDING', NULL, NULL, '2026-10-08 08:30:00'),
      (5, 2, 'SHIFT_SWAP', '2026-10-15', '2026-10-15', 0.0, 'Xin đổi ca CA02 sang ca CA01 cùng P.Anh', 'PENDING', NULL, NULL, '2026-10-12 08:00:00'),
      (6, 5, 'ANNUAL_LEAVE', '2026-08-10', '2026-08-11', 2.0, 'Nghỉ mát hè cùng gia đình', 'APPROVED', 1, 'Đã phê duyệt cho Hoàng Nam.', '2026-08-05 08:30:00'),
      (7, 5, 'ANNUAL_LEAVE', '2026-09-22', '2026-09-22', 1.0, 'Giải quyết thủ tục hành chính', 'APPROVED', 1, 'Đã duyệt.', '2026-09-18 10:15:00')
    ''');

    // 7. Tasks
    await db.rawInsert('''
      INSERT INTO tasks (id, title, description, department_id, creator_id, assignee_id, priority, status, progress_percent, deadline, created_at) VALUES
      (1, 'Thiết kế giao diện HRM theo chuẩn ASOFT', 'Hoàn thiện 5 màn hình đơn từ & Quỹ phép cho nhân sự trải nghiệm mượt mà trực quan.', 1, 1, 2, 'HIGH', 'IN_PROGRESS', 70, '2026-10-18 17:00', '2026-10-10 09:00'),
      (2, 'Xây dựng Bảng Kanban & Tương tác Task', 'Xây dựng tính năng kéo thả công việc, xem deadline, trao đổi comment cùng phòng ban.', 1, 1, 3, 'HIGH', 'IN_PROGRESS', 50, '2026-10-20 18:00', '2026-10-10 10:00'),
      (3, 'Tối ưu hóa chấm công GPS & Quản lý duyệt đơn', 'Hoàn thiện tính năng Điểm danh Check-in/Out, bắt lỗi đi trễ và chức năng duyệt hàng loạt cho Manager.', 1, 1, 1, 'MEDIUM', 'IN_PROGRESS', 80, '2026-10-19 12:00', '2026-10-09 14:00'),
      (4, 'Báo cáo tổng hợp chấm công tháng 10', 'Tổng hợp số liệu ngày công thực tế, ngày nghỉ phép của toàn bộ phòng ban IT.', 1, 1, 2, 'LOW', 'TODO', 0, '2026-10-25 17:00', '2026-10-12 08:30'),
      (5, 'Nâng cấp Kiến trúc Clean Architecture & Caching', 'Tối ưu hóa performance và refactor codebase dự án HRM theo chuẩn Micro-services.', 1, 1, 5, 'HIGH', 'IN_PROGRESS', 60, '2026-10-22 18:00', '2026-10-10 08:30')
    ''');

    // 8. Task Comments
    await db.rawInsert('''
      INSERT INTO task_comments (task_id, user_id, content, created_at) VALUES
      (1, 2, 'Đã kết nối với Database SQLite, màn hình Quỹ phép thể hiện đúng 3 tháng tối đa 3 ngày nghỉ rồi anh Ngọc nhé!', '2026-10-11 11:30:00'),
      (1, 1, 'Rất tốt Uyên ơi! Nhớ bổ sung tính năng chặn gửi đơn khi nhân viên xin vượt quá số ngày phép còn lại nhé.', '2026-10-11 13:45:00'),
      (2, 3, 'Em đang cài đặt hệ thống Notification nhắc nhở deadline trước 1 tiếng cho các task khẩn cấp.', '2026-10-12 09:15:00'),
      (2, 1, 'Ok P.Anh, nhớ cho phép tất cả thành viên trong phòng IT đều đọc và comment được nhé.', '2026-10-12 10:00:00'),
      (5, 5, 'Em đã hoàn tất thiết kế module Caching offline, hiệu năng truy vấn tăng 40% anh Ngọc nhé!', '2026-10-12 11:00:00')
    ''');

    // 9. Task Reminders
    await db.rawInsert('''
      INSERT INTO task_reminders (task_id, reminder_time, note, is_notified) VALUES
      (1, '2026-10-17 09:00', 'Nhắc nhở nộp bản kiểm thử giao diện màn hình Đơn từ', 0),
      (2, '2026-10-19 14:00', 'Nhắc nhở kiểm tra thông báo Notification trên thiết bị', 0)
    ''');
  }

  // ===================== CRUD & QUERY METHODS =====================

  // USERS
  Future<User?> getUserById(int id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final maps = await db.query('users');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  Future<List<User>> getUsersByDepartment(int deptId) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'department_id = ?', whereArgs: [deptId]);
    return maps.map((e) => User.fromMap(e)).toList();
  }

  // ATTENDANCE (MEMBER 1: DUY NGỌC)
  Future<Attendance?> getTodayAttendance(int userId, String date) async {
    final db = await instance.database;
    final maps = await db.query(
      'attendance',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
    );
    if (maps.isNotEmpty) {
      return Attendance.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertAttendance(Attendance attendance) async {
    final db = await instance.database;
    return await db.insert('attendance', attendance.toMap());
  }

  Future<int> updateAttendance(Attendance attendance) async {
    final db = await instance.database;
    return await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<List<Attendance>> getUserAttendanceHistory(int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'attendance',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((e) => Attendance.fromMap(e)).toList();
  }

  Future<List<Attendance>> getDepartmentTodayAttendance(int deptId, String date) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT a.*, u.full_name, u.avatar_url, u.position
      FROM users u
      LEFT JOIN attendance a ON u.id = a.user_id AND a.date = ?
      WHERE u.department_id = ?
    ''', [date, deptId]);

    return result.map((e) => Attendance.fromMap(e)).toList();
  }

  // LEAVE REQUESTS (MEMBER 2: UYÊN & APPROVAL FOR MEMBER 1: DUY NGỌC)
  Future<int> insertLeaveRequest(LeaveRequest request) async {
    final db = await instance.database;
    return await db.insert('leave_requests', request.toMap());
  }

  Future<int> updateLeaveRequest(LeaveRequest request) async {
    final db = await instance.database;
    return await db.update(
      'leave_requests',
      request.toMap(),
      where: 'id = ?',
      whereArgs: [request.id],
    );
  }

  Future<List<LeaveRequest>> getUserLeaveRequests(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT lr.*, u.full_name as user_name, u.avatar_url as user_avatar,
             d.name as department_name, app.full_name as approver_name
      FROM leave_requests lr
      JOIN users u ON lr.user_id = u.id
      JOIN departments d ON u.department_id = d.id
      LEFT JOIN users app ON lr.approver_id = app.id
      WHERE lr.user_id = ?
      ORDER BY lr.id DESC
    ''', [userId]);

    return result.map((e) => LeaveRequest.fromMap(e)).toList();
  }

  Future<List<LeaveRequest>> getAllPendingRequestsForManager(int deptId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT lr.*, u.full_name as user_name, u.avatar_url as user_avatar,
             d.name as department_name, app.full_name as approver_name
      FROM leave_requests lr
      JOIN users u ON lr.user_id = u.id
      JOIN departments d ON u.department_id = d.id
      LEFT JOIN users app ON lr.approver_id = app.id
      WHERE u.department_id = ?
      ORDER BY CASE WHEN lr.status = 'PENDING' THEN 1 ELSE 2 END, lr.id DESC
    ''', [deptId]);

    return result.map((e) => LeaveRequest.fromMap(e)).toList();
  }

  Future<void> batchApproveRequests(List<int> requestIds, int approverId) async {
    final db = await instance.database;
    final batch = db.batch();
    for (final id in requestIds) {
      batch.update(
        'leave_requests',
        {
          'status': 'APPROVED',
          'approver_id': approverId,
          'manager_comment': 'Đã duyệt hàng loạt bởi Quản lý',
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  // SHIFTS
  Future<List<UserShiftAssignment>> getUserShifts(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT usa.*, s.name as shift_name, s.start_time, s.end_time
      FROM user_shift_assignments usa
      JOIN shifts s ON usa.shift_code = s.code
      WHERE usa.user_id = ?
      ORDER BY usa.date ASC
    ''', [userId]);

    return result.map((e) => UserShiftAssignment.fromMap(e)).toList();
  }

  // TASKS (MEMBER 3: P.ANH)
  Future<int> insertTask(TaskItem task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(TaskItem task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<List<TaskItem>> getTasksByDepartment(int deptId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT t.*, 
             assignee.full_name as assignee_name, assignee.avatar_url as assignee_avatar,
             creator.full_name as creator_name,
             d.name as department_name,
             (SELECT COUNT(*) FROM task_comments tc WHERE tc.task_id = t.id) as comment_count
      FROM tasks t
      JOIN users assignee ON t.assignee_id = assignee.id
      JOIN users creator ON t.creator_id = creator.id
      JOIN departments d ON t.department_id = d.id
      WHERE t.department_id = ?
      ORDER BY t.id DESC
    ''', [deptId]);

    return result.map((e) => TaskItem.fromMap(e)).toList();
  }

  Future<List<TaskComment>> getCommentsForTask(int taskId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT tc.*, u.full_name as user_name, u.avatar_url as user_avatar
      FROM task_comments tc
      JOIN users u ON tc.user_id = u.id
      WHERE tc.task_id = ?
      ORDER BY tc.id ASC
    ''', [taskId]);

    return result.map((e) => TaskComment.fromMap(e)).toList();
  }

  Future<int> insertTaskComment(TaskComment comment) async {
    final db = await instance.database;
    return await db.insert('task_comments', comment.toMap());
  }

  Future<List<TaskReminder>> getRemindersForTask(int taskId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT tr.*, t.title as task_title
      FROM task_reminders tr
      JOIN tasks t ON tr.task_id = t.id
      WHERE tr.task_id = ?
      ORDER BY tr.reminder_time ASC
    ''', [taskId]);

    return result.map((e) => TaskReminder.fromMap(e)).toList();
  }

  Future<int> insertTaskReminder(TaskReminder reminder) async {
    final db = await instance.database;
    return await db.insert('task_reminders', reminder.toMap());
  }

  Future<int> deleteTaskReminder(int reminderId) async {
    final db = await instance.database;
    return await db.delete('task_reminders', where: 'id = ?', whereArgs: [reminderId]);
  }
}
