class Attendance {
  final int? id;
  final int userId;
  final String date; // 'YYYY-MM-DD'
  final String? checkInTime; // 'HH:mm:ss'
  final String? checkOutTime; // 'HH:mm:ss'
  final String status; // 'ON_TIME', 'LATE', 'EARLY_LEAVE', 'ABSENT'
  final double workHours;
  final String? note;
  final String shiftCode; // 'CA01', 'CA02'

  // Non-persisted join field
  final String? userName;
  final String? userAvatar;

  Attendance({
    this.id,
    required this.userId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.workHours = 0.0,
    this.note,
    this.shiftCode = 'CA01',
    this.userName,
    this.userAvatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'status': status,
      'work_hours': workHours,
      'note': note,
      'shift_code': shiftCode,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      date: map['date'] as String,
      checkInTime: map['check_in_time'] as String?,
      checkOutTime: map['check_out_time'] as String?,
      status: map['status'] as String? ?? 'ON_TIME',
      workHours: (map['work_hours'] is int)
          ? (map['work_hours'] as int).toDouble()
          : (map['work_hours'] as double? ?? 0.0),
      note: map['note'] as String?,
      shiftCode: map['shift_code'] as String? ?? 'CA01',
      userName: map['full_name'] as String?,
      userAvatar: map['avatar_url'] as String?,
    );
  }

  Attendance copyWith({
    int? id,
    int? userId,
    String? date,
    String? checkInTime,
    String? checkOutTime,
    String? status,
    double? workHours,
    String? note,
    String? shiftCode,
    String? userName,
    String? userAvatar,
  }) {
    return Attendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      workHours: workHours ?? this.workHours,
      note: note ?? this.note,
      shiftCode: shiftCode ?? this.shiftCode,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }
}
