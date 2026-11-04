import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/models/user_model.dart';
import 'package:hrm_app/core/models/leave_request_model.dart';
import 'package:hrm_app/features/leave_requests/services/leave_calculator.dart';

void main() {
  group('Business Rules Tests - Leave Quota & Calculation (Member 2: Uyên)', () {
    final uyenUser = User(
      id: 2,
      email: 'uyen@company.com',
      fullName: 'Uyên',
      avatarUrl: '',
      role: 'EMPLOYEE',
      departmentId: 1,
      position: 'Flutter Developer',
      startDate: '2026-07-12',
      annualLeaveQuota: 12,
    );

    final approvedRequests = [
      LeaveRequest(
        id: 1,
        userId: 2,
        requestType: 'ANNUAL_LEAVE',
        fromDate: '2026-08-20',
        toDate: '2026-08-20',
        totalDays: 1.0,
        reason: 'Việc gia đình',
        status: 'APPROVED',
        createdAt: '2026-08-15 09:30:00',
      ),
      LeaveRequest(
        id: 2,
        userId: 2,
        requestType: 'ANNUAL_LEAVE',
        fromDate: '2026-09-15',
        toDate: '2026-09-15',
        totalDays: 1.0,
        reason: 'Khám sức khỏe',
        status: 'APPROVED',
        createdAt: '2026-09-12 14:00:00',
      ),
    ];

    test('Uyên làm việc 3 tháng: Quota tích lũy 3 ngày, đã nghỉ 2 ngày -> Còn lại đúng 1 ngày', () {
      final balance = LeaveCalculatorEngine.calculateBalance(uyenUser, approvedRequests);

      expect(balance.tenureMonths, 3);
      expect(balance.accruedDays, 3.0);
      expect(balance.usedDays, 2.0);
      expect(balance.remainingDays, 1.0);
      expect(balance.pendingDays, 0.0);
      expect(balance.seniorityBonusDays, 0);
    });

    test('Chặn nộp đơn khi số ngày xin nghỉ (2 ngày) vượt quá hạn mức khả dụng (1 ngày)', () {
      final error = LeaveCalculatorEngine.validateLeaveSubmission(
        requestType: 'ANNUAL_LEAVE',
        requestedDays: 2.0,
        remainingDays: 1.0,
        fromDate: DateTime(2026, 10, 20),
        toDate: DateTime(2026, 10, 21),
        existingRequests: approvedRequests,
      );

      expect(error, isNotNull);
      expect(error!.contains('Không đủ quỹ phép'), isTrue);
    });

    test('Cho phép nộp đơn hợp lệ khi số ngày xin nghỉ (1 ngày) <= hạn mức khả dụng (1 ngày)', () {
      final error = LeaveCalculatorEngine.validateLeaveSubmission(
        requestType: 'ANNUAL_LEAVE',
        requestedDays: 1.0,
        remainingDays: 1.0,
        fromDate: DateTime(2026, 10, 20),
        toDate: DateTime(2026, 10, 20),
        existingRequests: approvedRequests,
      );

      expect(error, isNull);
    });

    test('Chặn nộp đơn nếu thời gian bị trùng lặp với đơn khác đã được duyệt', () {
      final error = LeaveCalculatorEngine.validateLeaveSubmission(
        requestType: 'ANNUAL_LEAVE',
        requestedDays: 1.0,
        remainingDays: 1.0,
        fromDate: DateTime(2026, 9, 15),
        toDate: DateTime(2026, 9, 15),
        existingRequests: approvedRequests,
      );

      expect(error, isNotNull);
      expect(error!.contains('bị trùng'), isTrue);
    });

    test('Quy tắc phê duyệt đa cấp: <= 2 ngày (1 cấp), > 2 ngày (2 cấp)', () {
      expect(LeaveCalculatorEngine.requiresMultiTierApproval(1.0), isFalse);
      expect(LeaveCalculatorEngine.requiresMultiTierApproval(2.0), isFalse);
      expect(LeaveCalculatorEngine.requiresMultiTierApproval(2.5), isTrue);
      expect(LeaveCalculatorEngine.requiresMultiTierApproval(3.0), isTrue);
    });

    // TEST MỚI: QUY TẮC THÂM NIÊN LÂU NĂM (>= 2 NĂM ĐƯỢC THƯỞNG THÊM PHÉP)
    test('Nhân viên thâm niên 2 năm (Duy Ngọc - start 2024-01-15): Thưởng +2 ngày phép -> Tổng 14 ngày phép', () {
      final duyNgocUser = User(
        id: 1,
        email: 'duyngoc@company.com',
        fullName: 'Duy Ngọc',
        avatarUrl: '',
        role: 'MANAGER',
        departmentId: 1,
        position: 'Trưởng bộ phận Kỹ thuật IT',
        startDate: '2024-01-15', // Làm được hơn 2 năm (> 24 tháng)
        annualLeaveQuota: 12,
      );

      final balance = LeaveCalculatorEngine.calculateBalance(duyNgocUser, []);

      expect(balance.tenureMonths >= 24, isTrue);
      expect(balance.seniorityBonusDays, 2);
      expect(balance.accruedDays, 14.0); // 12 ngày cơ bản + 2 ngày thâm niên = 14 ngày
      expect(balance.remainingDays, 14.0);
    });

    test('Nhân viên thâm niên 3 năm (Trần Thảo - start 2023-03-01): Thưởng +3 ngày phép -> Tổng 15 ngày phép', () {
      final tranThaoUser = User(
        id: 4,
        email: 'tranhr@company.com',
        fullName: 'Trần Thảo',
        avatarUrl: '',
        role: 'MANAGER',
        departmentId: 2,
        position: 'Giám đốc Nhân sự',
        startDate: '2023-03-01', // Làm được hơn 3 năm (> 36 tháng)
        annualLeaveQuota: 12,
      );

      final balance = LeaveCalculatorEngine.calculateBalance(tranThaoUser, []);

      expect(balance.tenureMonths >= 36, isTrue);
      expect(balance.seniorityBonusDays, 3);
      expect(balance.accruedDays, 15.0); // 12 ngày cơ bản + 3 ngày thâm niên = 15 ngày
      expect(balance.remainingDays, 15.0);
    });

    test('Nhân viên thâm niên 2 năm (Hoàng Nam - start 2024-10-15): Thưởng +2 ngày phép -> Tổng 14 ngày phép (nhiều hơn Uyên 3 ngày phép)', () {
      final hoangNamUser = User(
        id: 5,
        email: 'hoangnam@company.com',
        fullName: 'Hoàng Nam',
        avatarUrl: '',
        role: 'EMPLOYEE',
        departmentId: 1,
        position: 'Senior Mobile Developer (Thâm niên 2 năm)',
        startDate: '2024-10-15',
        annualLeaveQuota: 12,
      );

      final hoangNamRequests = [
        LeaveRequest(
          id: 6,
          userId: 5,
          requestType: 'ANNUAL_LEAVE',
          fromDate: '2026-08-10',
          toDate: '2026-08-11',
          totalDays: 2.0,
          reason: 'Nghỉ mát hè cùng gia đình',
          status: 'APPROVED',
          createdAt: '2026-08-05 08:30:00',
        ),
        LeaveRequest(
          id: 7,
          userId: 5,
          requestType: 'ANNUAL_LEAVE',
          fromDate: '2026-09-22',
          toDate: '2026-09-22',
          totalDays: 1.0,
          reason: 'Giải quyết thủ tục hành chính',
          status: 'APPROVED',
          createdAt: '2026-09-18 10:15:00',
        ),
      ];

      final balance = LeaveCalculatorEngine.calculateBalance(hoangNamUser, hoangNamRequests);

      expect(balance.tenureMonths, 24);
      expect(balance.seniorityBonusDays, 2);
      expect(balance.accruedDays, 14.0); // 12 ngày cơ sở + 2 ngày thưởng thâm niên
      expect(balance.usedDays, 3.0);
      expect(balance.remainingDays, 11.0);
      // Khẳng định rõ ràng: Hoàng Nam (14 ngày) > Uyên (3 ngày)
      expect(balance.accruedDays > 3.0, isTrue);
    });
  });
}
