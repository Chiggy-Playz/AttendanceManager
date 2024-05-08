class Class {
  final String id;
  final String name;
  final List<String> students;

  Class({
    required this.id,
    required this.name,
    required this.students,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json["id"],
      name: json["name"],
      students: List<String>.from(json["students"]),
    );
  }

  Class copyWith({
    String? id,
    String? name,
    List<String>? students,
  }) {
    return Class(
      id: id ?? this.id,
      name: name ?? this.name,
      students: students ?? this.students,
    );
  }
}
