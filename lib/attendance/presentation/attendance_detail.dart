import 'package:attendance_manager/student/data/models/student.dart';
import 'package:flutter/material.dart';

class AttendanceDetailPage extends StatefulWidget {
  const AttendanceDetailPage({super.key, required this.students});

  final List<Student> students;

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Detail'),
      ),
      body: ListView.builder(
        itemCount: widget.students.length,
        itemBuilder: (context, index) {
          var student = widget.students[index];
          return Card(
            child: ListTile(
              title: Text(student.name),
              subtitle: Text(student.rollNo),
            ),
          );
        },
      ),
    );
  }
}
