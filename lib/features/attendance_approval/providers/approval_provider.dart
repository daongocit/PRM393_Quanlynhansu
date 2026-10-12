import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/leave_request_model.dart';

class ApprovalProvider extends ChangeNotifier {
  List<LeaveRequest> _allRequests = [];
  final Set<int> _selectedIds = {};
  bool _isLoading = false;

  List<LeaveRequest> get allRequests => _allRequests;
  Set<int> get selectedIds => _selectedIds;
  bool get isLoading => _isLoading;

  List<LeaveRequest> get pendingRequests =>
      _allRequests.where((r) => r.status == 'PENDING').toList();

  List<LeaveRequest> get processedRequests =>
      _allRequests.where((r) => r.status != 'PENDING').toList();

  Future<void> loadManagerRequests(int deptId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allRequests = await DatabaseHelper.instance.getAllPendingRequestsForManager(deptId);
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

  Future<bool> approveSingle(int requestId, int managerId, {String? comment}) async {
    final idx = _allRequests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return false;

    final updated = _allRequests[idx].copyWith(
      status: 'APPROVED',
      approverId: managerId,
      managerComment: comment ?? 'Quản lý đã phê duyệt thành công.',
    );

    await DatabaseHelper.instance.updateLeaveRequest(updated);
    _allRequests[idx] = updated;
    _selectedIds.remove(requestId);
    notifyListeners();
    return true;
  }

  Future<bool> rejectSingle(int requestId, int managerId, {required String reason}) async {
    final idx = _allRequests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return false;

    final updated = _allRequests[idx].copyWith(
      status: 'REJECTED',
      approverId: managerId,
      managerComment: reason,
    );

    await DatabaseHelper.instance.updateLeaveRequest(updated);
    _allRequests[idx] = updated;
    _selectedIds.remove(requestId);
    notifyListeners();
    return true;
  }

  Future<bool> approveBatch(int managerId) async {
    if (_selectedIds.isEmpty) return false;

    final idsToApprove = _selectedIds.toList();
    await DatabaseHelper.instance.batchApproveRequests(idsToApprove, managerId);

    for (int i = 0; i < _allRequests.length; i++) {
      if (idsToApprove.contains(_allRequests[i].id)) {
        _allRequests[i] = _allRequests[i].copyWith(
          status: 'APPROVED',
          approverId: managerId,
          managerComment: 'Duyệt hàng loạt bởi Quản lý',
        );
      }
    }

    _selectedIds.clear();
    notifyListeners();
    return true;
  }
}
