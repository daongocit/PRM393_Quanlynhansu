import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  Attendance? _todayAttendance;
  List<Attendance> _history = [];
  List<Attendance> _deptTodayAttendance = [];
  bool _isLoading = false;

  Attendance? get todayAttendance => _todayAttendance;
  List<Attendance> get history => _history;
  List<Attendance> get deptTodayAttendance => _deptTodayAttendance;
  bool get isLoading => _isLoading;

  String get todayDateStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> loadUserAttendance(int userId, int deptId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayAttendance = await AppDatabase.instance.getTodayAttendance(userId, todayDateStr);
      _history = await AppDatabase.instance.getUserAttendanceHistory(userId);
      _deptTodayAttendance = await AppDatabase.instance.getDepartmentTodayAttendance(deptId, todayDateStr);
    } catch (e) {
      debugPrint('Load attendance error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDepartmentAttendanceForDate(int deptId, String date) async {
    try {
      _deptTodayAttendance = await AppDatabase.instance.getDepartmentTodayAttendance(deptId, date);
      notifyListeners();
    } catch (e) {
      debugPrint('Load dept attendance for date error: $e');
    }
  }

  Future<bool> checkIn(int userId, String shiftCode) async {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss').format(now);

    // Business Rule kiểm tra đi trễ theo từng ca làm việc:
    // Ca CA01 (08:00 - 17:00), sau 08:15 coi là đi trễ LATE
    // Ca CA02 (14:00 - 22:00), sau 14:15 coi là đi trễ LATE
    String status = 'ON_TIME';
    String note = 'Chấm công đúng giờ';

    final hour = now.hour;
    final minute = now.minute;

    if (shiftCode == 'CA01') {
      if (hour > 8 || (hour == 8 && minute > 15)) {
        status = 'LATE';
        note = 'Đi trễ sau 08:15 (Yêu cầu giải trình)';
      }
    } else if (shiftCode == 'CA02') {
      if (hour > 14 || (hour == 14 && minute > 15)) {
        status = 'LATE';
        note = 'Đi trễ sau 14:15 (Yêu cầu giải trình)';
      }
    }

    final newAttendance = Attendance(
      userId: userId,
      date: todayDateStr,
      checkInTime: timeStr,
      status: status,
      shiftCode: shiftCode,
      note: note,
    );

    final id = await AppDatabase.instance.insertAttendance(newAttendance);
    _todayAttendance = newAttendance.copyWith(id: id);
    _history.insert(0, _todayAttendance!);

    notifyListeners();
    return true;
  }

  Future<bool> checkOut() async {
    if (_todayAttendance == null) return false;

    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss').format(now);

    // Tính số giờ làm thực tế
    double workHours = 8.0;
    if (_todayAttendance!.checkInTime != null) {
      try {
        final checkInParts = _todayAttendance!.checkInTime!.split(':');
        final inTime = DateTime(
          now.year, now.month, now.day,
          int.parse(checkInParts[0]),
          int.parse(checkInParts[1]),
        );
        final diffMinutes = now.difference(inTime).inMinutes;
        workHours = double.parse((diffMinutes / 60.0).toStringAsFixed(1));
      } catch (_) {}
    }

    String status = _todayAttendance!.status;
    String note = _todayAttendance!.note ?? '';

    // Business Rule kiểm tra ra về sớm:
    // Ca CA01 kết thúc lúc 17:00, nếu checkout trước 17:00
    // Ca CA02 kết thúc lúc 22:00, nếu checkout trước 22:00
    final shiftCode = _todayAttendance!.shiftCode;
    bool isEarly = false;
    if (shiftCode == 'CA01' && now.hour < 17) {
      isEarly = true;
    } else if (shiftCode == 'CA02' && now.hour < 22) {
      isEarly = true;
    }

    if (isEarly && status == 'ON_TIME') {
      status = 'EARLY_LEAVE';
      note = 'Về sớm trước giờ kết thúc ca (ra lúc $timeStr)';
    }

    final updated = _todayAttendance!.copyWith(
      checkOutTime: timeStr,
      workHours: workHours > 0 ? workHours : 8.0,
      status: status,
      note: note,
    );

    await AppDatabase.instance.updateAttendance(updated);
    _todayAttendance = updated;

    // Cập nhật lại trong history
    final idx = _history.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      _history[idx] = updated;
    }

    notifyListeners();
    return true;
  }
}
