class Student {
  final String id;
  final String name;
  final String rollNo;
  final String faceEncoding;

  Student({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.faceEncoding,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json["id"],
      name: json["name"],
      rollNo: json["rollNo"],
      faceEncoding: json["faceEncoding"],
    );
  }

  Student copyWith({
    String? id,
    String? name,
    String? rollNo,
    String? faceEncoding,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNo: rollNo ?? this.rollNo,
      faceEncoding: faceEncoding ?? this.faceEncoding,
    );
  }  
}
