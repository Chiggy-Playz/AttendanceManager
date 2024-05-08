class Attendance {
  String teacherId;
  String classId;
  List<String> presentStudentIds;
  DateTime date;

  Attendance({
    required this.teacherId,
    required this.classId,
    required this.presentStudentIds,
    required this.date,
  });

  Attendance copyWith({
    String? teacherId,
    String? classId,
    List<String>? presentStudentIds,
    DateTime? date,
  }) {
    return Attendance(
      teacherId: teacherId ?? this.teacherId,
      classId: classId ?? this.classId,
      presentStudentIds: presentStudentIds ?? this.presentStudentIds,
      date: date ?? this.date,
    );
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      teacherId: json['teacherId'],
      classId: json['classId'],
      presentStudentIds: List<String>.from(json['presentStudentIds']),
      date: DateTime.parse(json['date']),
    );
  }
}
