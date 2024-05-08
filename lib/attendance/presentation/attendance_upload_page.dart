import 'package:attendance_manager/classes/data/provider/class_page_provider.dart';
import 'package:attendance_manager/student/data/models/student.dart';
import 'package:attendance_manager/student/data/providers/student_form_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceUploadPage extends StatefulWidget {
  const AttendanceUploadPage({super.key, required this.formData});

  final Map<String, dynamic> formData;

  @override
  State<AttendanceUploadPage> createState() => _AttendanceUploadPageState();
}

class _AttendanceUploadPageState extends State<AttendanceUploadPage> {
  Map<String, bool> attendance = {};
  bool hasRan = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Upload Attendance'),
        ),
        body: FutureBuilder(
          future: takeAttendance(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Error taking attendance'),
              );
            }

            if (attendance.isEmpty) {
              return const Center(
                child: Text('No students found'),
              );
            }

            var studentAttendance = attendance.entries.toList();
            return ListView.builder(
              itemCount: attendance.length,
              itemBuilder: (context, index) {
                var mapEntry = studentAttendance[index];
                var studentId = mapEntry.key;
                var student = snapshot.data![studentId] as Student;
                var present = mapEntry.value;

                return Card(
                  child: CheckboxListTile(
                    title: Text(student.name),
                    subtitle: Text(student.rollNo),
                    value: present,
                    onChanged: (value) {
                      setState(() {
                        attendance[studentId] = value!;
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: uploadAttendance,
          child: const Icon(Icons.upload),
        ));
  }

  Future<Map<String, Student>> takeAttendance() async {
    final students = await context.read<ClassPageProvider>().getStudents();

    if (hasRan) {
      Map<String, Student> result = {};
      for (var student in students) {
        result[student.id] = student;
      }
      return result;
    }

    // Take the attendance
    final dio = Dio(BaseOptions(
      validateStatus: (status) => true,
    ));

    final response = await dio.post(
      'https://abs.chiggydoes.tech/get_class_encodings',
      data: FormData.fromMap(widget.formData),
    );

    if (response.statusCode != 200) {
      throw UnknownError();
    }

    var data = List<String>.from(response.data);

    var presentStudents = <Student>[];

    for (var i = 0; i < data.length; i++) {
      var faceEncoding = data[i];
      // Find student with this face encoding
      Student? s;
      for (var student in students) {
        if (student.faceEncoding == faceEncoding) {
          s = student;
          break;
        }
      }

      if (s != null) {
        presentStudents.add(s);
      }
    }

    var present_student_ids =
        presentStudents.map((student) => student.id).toList();
    var absent_student_ids = students
        .map((student) => student.id)
        .where((id) => !present_student_ids.contains(id))
        .toList();
    var absent_students = students
        .where((student) => absent_student_ids.contains(student.id))
        .toList();

    for (var student in presentStudents) {
      attendance[student.id] = true;
    }
    for (var student in absent_students) {
      attendance[student.id] = false;
    }

    Map<String, Student> result = {};
    for (var student in students) {
      result[student.id] = student;
    }

    hasRan = true;
    return result;
  }

  Future<void> uploadAttendance() async {
    if (attendance.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students found'),
        ),
      );
    }

    // Upload the attendance
    final class_ = await context.read<ClassPageProvider>().class_;

    var presentStudents = attendance.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    FirebaseFirestore.instance.collection("attendance").add({
      "teacherId": FirebaseAuth.instance.currentUser!.uid,
      "classId": class_.id,
      "presentStudentIds": presentStudents,
      "date": DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance uploaded'),
      ),
    );

    Navigator.of(context).pop();
  }
}
