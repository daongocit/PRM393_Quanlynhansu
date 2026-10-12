class User {
  final int id;
  final String email;
  final String fullName;
  final String avatarUrl;
  final String role; // 'EMPLOYEE' or 'MANAGER'
  final int departmentId;
  final String position;
  final String startDate; // 'YYYY-MM-DD' - dùng để tính thâm niên (Business Rule)
  final int annualLeaveQuota; // Quỹ phép cơ bản (mặc định 12 ngày/năm)
  final String? phone;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.role,
    required this.departmentId,
    required this.position,
    required this.startDate,
    this.annualLeaveQuota = 12,
    this.phone,
  });

  bool get isManager => role == 'MANAGER';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
      'department_id': departmentId,
      'position': position,
      'start_date': startDate,
      'annual_leave_quota': annualLeaveQuota,
      'phone': phone,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      email: map['email'] as String,
      fullName: map['full_name'] as String,
      avatarUrl: map['avatar_url'] as String,
      role: map['role'] as String,
      departmentId: map['department_id'] as int,
      position: map['position'] as String,
      startDate: map['start_date'] as String,
      annualLeaveQuota: map['annual_leave_quota'] as int? ?? 12,
      phone: map['phone'] as String?,
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? role,
    int? departmentId,
    String? position,
    String? startDate,
    int? annualLeaveQuota,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      annualLeaveQuota: annualLeaveQuota ?? this.annualLeaveQuota,
      phone: phone ?? this.phone,
    );
  }
}
