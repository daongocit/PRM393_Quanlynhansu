import '../../../core/models/user_model.dart';
import '../../../core/models/leave_request_model.dart';

class LeaveBalanceResult {
  final int tenureMonths; // Số tháng làm việc
  final double accruedDays; // Tổng ngày phép được hưởng theo thâm niên
  final double usedDays; // Số ngày phép đã nghỉ (được duyệt)
  final double remainingDays; // Số ngày phép khả dụng còn lại
  final double pendingDays; // Số ngày phép đang chờ duyệt

  LeaveBalanceResult({
    required this.tenureMonths,
    required this.accruedDays,
    required this.usedDays,
    required this.remainingDays,
    required this.pendingDays,
  });
}

class LeaveCalculatorEngine {
  /// BUSINESS RULE CỐT LÕI TỪ ĐỀ BÀI:
  /// - Mỗi tháng làm việc tích lũy 1 ngày phép năm (Tối đa 12 ngày/năm).
  /// - Ví dụ: Làm 3 tháng thì tối đa nghỉ 3 ngày.
  /// - Nếu đã nghỉ 2 ngày -> Còn lại 1 ngày.
  static LeaveBalanceResult calculateBalance(User user, List<LeaveRequest> requests) {
    int tenureMonths = 0;
    try {
      final start = DateTime.parse(user.startDate);
      final now = DateTime.now();
      final diffDays = now.difference(start).inDays;
      tenureMonths = (diffDays / 30).floor();
      if (tenureMonths < 0) tenureMonths = 0;
    } catch (_) {
      tenureMonths = 3; // fallback an toàn
    }

    // Tích lũy tối đa không vượt quá quota cả năm (12 ngày)
    final double accruedDays = tenureMonths > user.annualLeaveQuota
        ? user.annualLeaveQuota.toDouble()
        : tenureMonths.toDouble();

    // Tính tổng số ngày phép năm đã APPROVED
    double usedDays = 0.0;
    double pendingDays = 0.0;

    for (final req in requests) {
      if (req.requestType == 'ANNUAL_LEAVE') {
        if (req.status == 'APPROVED') {
          usedDays += req.totalDays;
        } else if (req.status == 'PENDING') {
          pendingDays += req.totalDays;
        }
      }
    }

    final double remainingDays = (accruedDays - usedDays) > 0 ? (accruedDays - usedDays) : 0.0;

    return LeaveBalanceResult(
      tenureMonths: tenureMonths,
      accruedDays: accruedDays,
      usedDays: usedDays,
      remainingDays: remainingDays,
      pendingDays: pendingDays,
    );
  }

  /// BUSINESS RULE VALIDATION KHI TẠO ĐƠN:
  /// 1. Kiểm tra quỹ phép nếu là Nghỉ phép năm
  /// 2. Kiểm tra trùng lặp ngày với các đơn trước đó
  static String? validateLeaveSubmission({
    required String requestType,
    required double requestedDays,
    required double remainingDays,
    required DateTime fromDate,
    required DateTime toDate,
    required List<LeaveRequest> existingRequests,
  }) {
    // 1. Quỹ phép
    if (requestType == 'ANNUAL_LEAVE') {
      if (requestedDays > remainingDays) {
        return 'Không đủ quỹ phép! Bạn chỉ còn $remainingDays ngày phép khả dụng (xin $requestedDays ngày). Vui lòng chuyển sang loại "Nghỉ không lương" hoặc giảm số ngày.';
      }
    }

    // 2. Kiểm tra trùng ngày
    for (final req in existingRequests) {
      if (req.status == 'APPROVED' || req.status == 'PENDING') {
        try {
          final reqFrom = DateTime.parse(req.fromDate);
          final reqTo = DateTime.parse(req.toDate);

          // Kiểm tra giao thoa giữa 2 khoảng thời gian
          final isOverlap = !(toDate.isBefore(reqFrom) || fromDate.isAfter(reqTo));
          if (isOverlap) {
            return 'Thời gian xin nghỉ (${req.fromDate} đến ${req.toDate}) bị trùng với đơn khác đã nộp (${req.typeDisplay} - Trạng thái: ${req.statusDisplay})!';
          }
        } catch (_) {}
      }
    }

    return null; // Hợp lệ
  }

  /// BUSINESS RULE DUYỆT PHÂN CẤP:
  /// - Đơn <= 2 ngày: Trưởng phòng duyệt trực tiếp (1 cấp)
  /// - Đơn > 2 ngày: Cần phê duyệt 2 cấp (Trưởng phòng -> Giám đốc)
  static bool requiresMultiTierApproval(double totalDays) {
    return totalDays > 2.0;
  }
}
