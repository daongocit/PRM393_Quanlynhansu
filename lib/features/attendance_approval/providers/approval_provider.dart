import 'package:flutter/foundation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/leave_request_model.dart';

class ApprovalProvider extends ChangeNotifier {
  List<LeaveRequest> _allRequests = [];
  final Set<int> _selectedIds = {};
  bool _isLoading = false;

  List<LeaveRequest> get allRequests => _allRequests;
  Set<int> get selectedIds => _selectedIds;
  bool get isLoading => _isLoading;

  List<LeaveRequest> get pendingRequests =>
      _allRequests.where((r) => r.status == 'PENDING' || r.status == 'PENDING_TIER_2').toList();

  List<LeaveRequest> get processedRequests =>
      _allRequests.where((r) => r.status != 'PENDING' && r.status != 'PENDING_TIER_2').toList();

  Future<void> loadManagerRequests(int deptId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allRequests = await AppDatabase.instance.getAllPendingRequestsForManager(deptId);
      _selectedIds.clear();
    } catch (e) {
      debugPrint('Load manager requests error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSelection(int requestId) {
    if (_selectedIds.contains(requestId)) {
      _selectedIds.remove(requestId);
    } else {
      _selectedIds.add(requestId);
    }
    notifyListeners();
  }

  void selectAllPending() {
    _selectedIds.clear();
    for (final r in pendingRequests) {
      if (r.id != null) _selectedIds.add(r.id!);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  /// Phê duyệt đơn:
  /// - Đơn > 2 ngày: Duy Ngọc (Trưởng phòng) thẩm định Cấp 1 -> Chuyển sang PENDING_TIER_2.
  /// - Trần Thảo (Giám đốc) phê chuẩn Cấp 2 -> Chuyển sang APPROVED hoàn tất.
  /// - Đơn <= 2 ngày: Trưởng phòng duyệt 1 cấp là APPROVED.
  Future<bool> approveSingle(
    int requestId,
    int managerId, {
    String? comment,
    bool isDirector = false,
    String approverName = 'Quản lý',
  }) async {
    final idx = _allRequests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return false;

    final currentReq = _allRequests[idx];
    final bool requiresTier2 = currentReq.totalDays > 2;

    final String newStatus;
    final String finalComment;

    if (requiresTier2 && !isDirector && currentReq.status == 'PENDING') {
      // Cấp 1: Trưởng bộ phận IT (Duy Ngọc) thẩm định đơn > 2 ngày
      newStatus = 'PENDING_TIER_2';
      final note = (comment != null && comment.trim().isNotEmpty) ? comment.trim() : 'Đồng ý thẩm định';
      finalComment = 'Cấp 1 ($approverName thẩm định): "$note" → Chờ Giám đốc Trần Thảo phê chuẩn';
    } else {
      // Cấp 2 (Trần Thảo) HOẶC Đơn <= 2 ngày (Duy Ngọc duyệt 1 cấp)
      newStatus = 'APPROVED';
      final note = (comment != null && comment.trim().isNotEmpty) ? comment.trim() : 'Đã phê chuẩn hoàn tất.';
      if (currentReq.status == 'PENDING_TIER_2') {
        finalComment = '${currentReq.managerComment ?? ""}\n• Cấp 2 ($approverName - Giám đốc): "$note"';
      } else {
        finalComment = note;
      }
    }

    final updated = currentReq.copyWith(
      status: newStatus,
      approverId: managerId,
      managerComment: finalComment,
    );

    await AppDatabase.instance.updateLeaveRequest(updated);
    _allRequests[idx] = updated;
    _selectedIds.remove(requestId);
    notifyListeners();
    return true;
  }

  Future<bool> rejectSingle(
    int requestId,
    int managerId, {
    required String reason,
    String approverName = 'Quản lý',
  }) async {
    final idx = _allRequests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return false;

    final currentReq = _allRequests[idx];
    final String finalComment = currentReq.status == 'PENDING_TIER_2'
        ? '${currentReq.managerComment ?? ""}\n• Cấp 2 ($approverName - Giám đốc từ chối): "$reason"'
        : 'Từ chối bởi $approverName: "$reason"';

    final updated = currentReq.copyWith(
      status: 'REJECTED',
      approverId: managerId,
      managerComment: finalComment,
    );

    await AppDatabase.instance.updateLeaveRequest(updated);
    _allRequests[idx] = updated;
    _selectedIds.remove(requestId);
    notifyListeners();
    return true;
  }

  Future<bool> approveBatch(
    int managerId, {
    bool isDirector = false,
    String approverName = 'Quản lý',
  }) async {
    if (_selectedIds.isEmpty) return false;

    final idsToApprove = _selectedIds.toList();
    for (final id in idsToApprove) {
      await approveSingle(id, managerId, isDirector: isDirector, approverName: approverName);
    }

    _selectedIds.clear();
    notifyListeners();
    return true;
  }
}
