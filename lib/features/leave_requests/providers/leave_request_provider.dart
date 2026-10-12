import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/leave_request_model.dart';
import '../../../core/models/shift_model.dart';
import '../services/leave_calculator.dart';

class LeaveRequestProvider extends ChangeNotifier {
  List<LeaveRequest> _userRequests = [];
  List<UserShiftAssignment> _userShifts = [];
  LeaveBalanceResult? _balance;
  bool _isLoading = false;

  List<LeaveRequest> get userRequests => _userRequests;
  List<UserShiftAssignment> get userShifts => _userShifts;
  LeaveBalanceResult? get balance => _balance;
  bool get isLoading => _isLoading;

  Future<void> loadUserData(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userRequests = await DatabaseHelper.instance.getUserLeaveRequests(user.id);
      _userShifts = await DatabaseHelper.instance.getUserShifts(user.id);
      _balance = LeaveCalculatorEngine.calculateBalance(user, _userRequests);
    } catch (e) {
      debugPrint('Load leave data error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Nộp đơn mới với Business Rules Validation
  Future<String?> submitLeaveRequest({
    required User user,
    required String requestType,
    required DateTime fromDate,
    required DateTime toDate,
    required double totalDays,
    required String reason,
  }) async {
    // 1. Validate Business Rules
    final validationError = LeaveCalculatorEngine.validateLeaveSubmission(
      requestType: requestType,
      requestedDays: totalDays,
      remainingDays: _balance?.remainingDays ?? 0.0,
      fromDate: fromDate,
      toDate: toDate,
      existingRequests: _userRequests,
    );

    if (validationError != null) {
      return validationError; // Trả về thông báo lỗi vi phạm quy tắc nghiệp vụ
    }

    final newReq = LeaveRequest(
      userId: user.id,
      requestType: requestType,
      fromDate: DateFormat('yyyy-MM-dd').format(fromDate),
      toDate: DateFormat('yyyy-MM-dd').format(toDate),
      totalDays: totalDays,
      reason: reason,
      status: 'PENDING',
      createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );

    final id = await DatabaseHelper.instance.insertLeaveRequest(newReq);
    _userRequests.insert(0, newReq.copyWith(id: id));
    _balance = LeaveCalculatorEngine.calculateBalance(user, _userRequests);

    notifyListeners();
    return null; // Thành công
  }

  Future<bool> cancelRequest(int requestId, User user) async {
    final idx = _userRequests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return false;

    final updated = _userRequests[idx].copyWith(status: 'CANCELLED');
    await DatabaseHelper.instance.updateLeaveRequest(updated);
    _userRequests[idx] = updated;
    _balance = LeaveCalculatorEngine.calculateBalance(user, _userRequests);

    notifyListeners();
    return true;
  }
}
