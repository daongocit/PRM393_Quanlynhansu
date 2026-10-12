class Department {
  final int id;
  final String name;
  final String code;
  final String description;

  Department({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
    };
  }

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'] as int,
      name: map['name'] as String,
      code: map['code'] as String,
      description: map['description'] ?? '',
    );
  }
}
