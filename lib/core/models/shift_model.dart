class Shift {
  final int id;
  final String code; // 'CA01', 'CA02', 'CA03'
  final String name; // Ca hành chính, Ca chiều/tối, Ca đêm
  final String startTime; // '08:00'
  final String endTime; // '17:00'
  final String colorHex;

  Shift({
    required this.id,
    required this.code,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.colorHex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'color_hex': colorHex,
    };
  }

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] as int,
      code: map['code'] as String,
      name: map['name'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      colorHex: map['color_hex'] as String? ?? '0xFF1E3A8A',
    );
  }
}

class UserShiftAssignment {
  final int? id;
  final int userId;
  final String shiftCode;
  final String date; // 'YYYY-MM-DD'
  final String? note;

  // Joined display attributes
  final String? shiftName;
  final String? startTime;
  final String? endTime;

  UserShiftAssignment({
    this.id,
    required this.userId,
    required this.shiftCode,
    required this.date,
    this.note,
    this.shiftName,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'shift_code': shiftCode,
      'date': date,
      'note': note,
    };
  }

  factory UserShiftAssignment.fromMap(Map<String, dynamic> map) {
    return UserShiftAssignment(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      shiftCode: map['shift_code'] as String,
      date: map['date'] as String,
      note: map['note'] as String?,
      shiftName: map['shift_name'] as String?,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
    );
  }
}
