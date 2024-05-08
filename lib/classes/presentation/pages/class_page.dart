import 'dart:convert';
import 'dart:io';

import 'package:attendance_manager/attendance/presentation/attendance_list.dart';
import 'package:attendance_manager/attendance/presentation/attendance_upload_page.dart';
import 'package:attendance_manager/classes/data/provider/class_page_provider.dart';
import 'package:attendance_manager/home/presentation/widgets/edit_class_dialog.dart';
import 'package:attendance_manager/student/data/models/student.dart';
import 'package:attendance_manager/student/data/providers/student_form_provider.dart';
import 'package:attendance_manager/student/presentation/pages/student_form.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ClassPageProvider>(
      builder: (context, provider, child) {
        var class_ = provider.class_;
        return Scaffold(
            appBar: AppBar(
              title: Text(class_.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<ClassPageProvider>(),
                        child: const EditClassDialog(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: FilledButton(
                      onPressed: viewAttendance,
                      child: Text("View Attendance"),
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: FilledButton(
                      onPressed: takeAttendance,
                      child: Text("Take Attendance"),
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: getStudents(provider),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      var students = snapshot.data as List<Student>;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          var student = students[index];
                          return Card(
                            child: ListTile(
                              title: Text(student.name),
                              subtitle: Text(student.rollNo),
                              onTap: () => routeToUploadAttendancePage(student),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => routeToUploadAttendancePage(null),
              child: const Icon(Icons.add),
            ));
      },
    );
  }

  Future<void> viewAttendance() async {
    // View attendance
    // Get the attendance from the database
    var attendance = await context.read<ClassPageProvider>().getAttendance();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return ChangeNotifierProvider.value(
            value: context.read<ClassPageProvider>(),
            child: ViewAttendanceList(attendanceList: attendance),
          );
        },
      ),
    );
  }

  Future<List<Student>> getStudents(ClassPageProvider provider) async {
    // Get the students from the database
    return provider.getStudents();
  }

  Future<void> routeToUploadAttendancePage(Student? student) async {
    // Navigate to the add student page

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<StudentFormProvider>(
                create: (_) => StudentFormProvider(student: student),
              ),
              ChangeNotifierProvider<ClassPageProvider>.value(
                  value: context.read<ClassPageProvider>()),
            ],
            child: const StudentFormPage(),
          );
        },
      ),
    );
  }

  Future<void> takeAttendance() async {
    // Take attendance
    // Ask photo from gallery

    var imagePicker = ImagePicker();
    var image = await imagePicker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    File imageFile = File(image.path);

    // Get bounding boxes for faces usign mlkit

    final inputImage = InputImage.fromFilePath(imageFile.path);

    final options = FaceDetectorOptions();
    final faceDetector = FaceDetector(options: options);

    final faces = await faceDetector.processImage(inputImage);

    List<Map> boundingBoxes = faces
        .map((face) => face.boundingBox)
        .map(
          (e) => {
            "top": e.top,
            "left": e.left,
            "width": e.width,
            "height": e.height
          },
        )
        .toList();

    // Get students from the database
    var students = await context.read<ClassPageProvider>().getStudents();

    List<String> encodings = students.map((e) => e.faceEncoding).toList();

    Map<String, dynamic> formData = {
      "class_photo_image": await MultipartFile.fromFile(imageFile.path),
      "known_encodings": encodings,
      "bounding_boxes_raw":
          boundingBoxes.map((e) => jsonEncode(e)).toList().toString(),
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return ChangeNotifierProvider<ClassPageProvider>.value(
            value: context.read<ClassPageProvider>(),
            child: AttendanceUploadPage(formData: formData),
          );
        },
      ),
    );

    print("Here");
  }
}
