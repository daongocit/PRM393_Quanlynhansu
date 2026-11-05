class LeaveRequest {
  final int? id;
  final int userId;
  final String requestType; // 'ANNUAL_LEAVE', 'SICK_LEAVE', 'UNPAID_LEAVE', 'LATE_EXPLANATION', 'SHIFT_SWAP'
  final String fromDate; // 'YYYY-MM-DD'
  final String toDate; // 'YYYY-MM-DD'
  final double totalDays;
  final String reason;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'
  final int? approverId;
  final String? managerComment;
  final String createdAt;

  // Joined display attributes
  final String? userName;
  final String? userAvatar;
  final String? departmentName;
  final String? approverName;

  LeaveRequest({
    this.id,
    required this.userId,
    required this.requestType,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.reason,
    this.status = 'PENDING',
    this.approverId,
    this.managerComment,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.departmentName,
    this.approverName,
  });

  String get typeDisplay {
    switch (requestType) {
      case 'ANNUAL_LEAVE':
        return 'Nghỉ phép năm';
      case 'SICK_LEAVE':
        return 'Nghỉ ốm hưởng BHXH';
      case 'UNPAID_LEAVE':
        return 'Nghỉ không lương';
      case 'LATE_EXPLANATION':
        return 'Giải trình quên quẹt thẻ / đi trễ';
      case 'SHIFT_SWAP':
        return 'Xin đổi ca làm việc';
      default:
        return 'Đơn từ khác';
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'PENDING':
        return 'Chờ phê duyệt';
      case 'PENDING_TIER_2':
        return 'Chờ Giám đốc phê chuẩn (Cấp 2)';
      case 'APPROVED':
        return 'Đã phê duyệt';
      case 'REJECTED':
        return 'Từ chối';
      case 'CANCELLED':
        return 'Đã hủy đơn';
      default:
        return status;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'request_type': requestType,
      'from_date': fromDate,
      'to_date': toDate,
      'total_days': totalDays,
      'reason': reason,
      'status': status,
      'approver_id': approverId,
      'manager_comment': managerComment,
      'created_at': createdAt,
    };
  }

  factory LeaveRequest.fromMap(Map<String, dynamic> map) {
    return LeaveRequest(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      requestType: map['request_type'] as String,
      fromDate: map['from_date'] as String,
      toDate: map['to_date'] as String,
      totalDays: (map['total_days'] is int)
          ? (map['total_days'] as int).toDouble()
          : (map['total_days'] as double? ?? 1.0),
      reason: map['reason'] as String? ?? '',
      status: map['status'] as String? ?? 'PENDING',
      approverId: map['approver_id'] as int?,
      managerComment: map['manager_comment'] as String?,
      createdAt: map['created_at'] as String,
      userName: map['user_name'] as String?,
      userAvatar: map['user_avatar'] as String?,
      departmentName: map['department_name'] as String?,
      approverName: map['approver_name'] as String?,
    );
  }

  LeaveRequest copyWith({
    int? id,
    int? userId,
    String? requestType,
    String? fromDate,
    String? toDate,
    double? totalDays,
    String? reason,
    String? status,
    int? approverId,
    String? managerComment,
    String? createdAt,
    String? userName,
    String? userAvatar,
    String? departmentName,
    String? approverName,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      requestType: requestType ?? this.requestType,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      totalDays: totalDays ?? this.totalDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approverId: approverId ?? this.approverId,
      managerComment: managerComment ?? this.managerComment,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      departmentName: departmentName ?? this.departmentName,
      approverName: approverName ?? this.approverName,
    );
  }
}
