import 'package:attendance_manager/classes/data/models/class_model.dart';
import 'package:attendance_manager/student/data/models/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClassPageProvider extends ChangeNotifier {
  ClassPageProvider({required this.class_});

  Class class_;

  Future<void> editClassName(String name) async {
    await FirebaseFirestore.instance
        .collection("classes")
        .doc(class_.id)
        .update({
      "name": name,
    });

    class_ = class_.copyWith(name: name);
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    await FirebaseFirestore.instance
        .collection("classes")
        .doc(class_.id)
        .update({
      "students": FieldValue.arrayUnion([student.id]),
    });

    class_ = class_.copyWith(students: [...class_.students, student.id]);
    notifyListeners();
  }

  Future<List<Student>> getStudents() async {
    var students = <Student>[];

    for (var studentId in class_.students) {
      var studentSnapshot = await FirebaseFirestore.instance
          .collection("students")
          .doc(studentId)
          .get();

      var data = studentSnapshot.data();
      data!["id"] = studentSnapshot.id;

      students.add(Student.fromJson(data));
    }

    return students;
  }

  Future<void> deleteStudent(Student student) async {
    await FirebaseFirestore.instance
        .collection("classes")
        .doc(class_.id)
        .update({
      "students": FieldValue.arrayRemove([student.id]),
    });

    class_ = class_.copyWith(
      students: class_.students.where((id) => id != student.id).toList(),
    );
    notifyListeners();
  }
}
