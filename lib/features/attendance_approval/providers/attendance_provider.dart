import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
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
      _todayAttendance = await DatabaseHelper.instance.getTodayAttendance(userId, todayDateStr);
      _history = await DatabaseHelper.instance.getUserAttendanceHistory(userId);
      _deptTodayAttendance = await DatabaseHelper.instance.getDepartmentTodayAttendance(deptId, todayDateStr);
    } catch (e) {
      debugPrint('Load attendance error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn(int userId, String shiftCode) async {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss').format(now);

    // Business Rule kiểm tra đi trễ:
    // Ca CA01 (8:00 - 17:00), sau 8:15 coi là đi trễ LATE
    String status = 'ON_TIME';
    if (shiftCode == 'CA01') {
      final hour = now.hour;
      final minute = now.minute;
      if (hour > 8 || (hour == 8 && minute > 15)) {
        status = 'LATE';
      }
    }

    final newAttendance = Attendance(
      userId: userId,
      date: todayDateStr,
      checkInTime: timeStr,
      status: status,
      shiftCode: shiftCode,
      note: status == 'LATE' ? 'Đi trễ sau 08:15 (Yêu cầu giải trình)' : 'Chấm công đúng giờ',
    );

    final id = await DatabaseHelper.instance.insertAttendance(newAttendance);
    _todayAttendance = newAttendance.copyWith(id: id);
    _history.insert(0, _todayAttendance!);

    notifyListeners();
    return true;
  }

  Future<bool> checkOut() async {
    if (_todayAttendance == null) return false;

    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss').format(now);

    // Tính số giờ làm
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

    final updated = _todayAttendance!.copyWith(
      checkOutTime: timeStr,
      workHours: workHours > 0 ? workHours : 8.0,
    );

    await DatabaseHelper.instance.updateAttendance(updated);
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
