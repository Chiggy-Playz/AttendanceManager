import 'package:attendance_manager/attendance/data/attendance_model.dart';
import 'package:attendance_manager/attendance/presentation/attendance_detail.dart';
import 'package:attendance_manager/classes/data/provider/class_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

class ViewAttendanceList extends StatefulWidget {
  const ViewAttendanceList({super.key, required this.attendanceList});

  final List<Attendance> attendanceList;

  @override
  State<ViewAttendanceList> createState() => _ViewAttendanceListState();
}

class _ViewAttendanceListState extends State<ViewAttendanceList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance List'),
      ),
      body: widget.attendanceList.isEmpty
          ? const Center(child: Text("No attendance found"))
          : ListView.builder(
              itemCount: widget.attendanceList.length,
              itemBuilder: (context, index) {
                var attendance = widget.attendanceList[index];
                return Card(
                  child: ListTile(
                    title: Text(dateFormat.format(attendance.date)),
                    onTap: () async {
                      var allClassStudents =
                          await context.read<ClassPageProvider>().getStudents();
                      var presentStudentIds = attendance.presentStudentIds;
                      var presentStudents = allClassStudents
                          .where((student) =>
                              presentStudentIds.contains(student.id))
                          .toList();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) {
                            return AttendanceDetailPage(
                              students: presentStudents,
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
