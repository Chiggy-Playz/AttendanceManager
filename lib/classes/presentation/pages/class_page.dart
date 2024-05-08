import 'dart:convert';
import 'dart:io';

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
                IconButton(
                  onPressed: takeAttendance,
                  icon: const Icon(Icons.calendar_month),
                )
              ],
            ),
            body: FutureBuilder(
              future: getStudents(provider),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var students = snapshot.data as List<Student>;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      var student = students[index];
                      return Card(
                        child: ListTile(
                          title: Text(student.name),
                          subtitle: Text(student.rollNo),
                          onTap: () => routeToStudentPage(student),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => routeToStudentPage(null),
              child: const Icon(Icons.add),
            ));
      },
    );
  }

  Future<List<Student>> getStudents(ClassPageProvider provider) async {
    // Get the students from the database
    return provider.getStudents();
  }

  Future<void> routeToStudentPage(Student? student) async {
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

    final dio = Dio(BaseOptions(
      validateStatus: (status) => true,
    ));

    FormData formData = FormData.fromMap({
      "class_photo_image": await MultipartFile.fromFile(imageFile.path),
      "known_encodings": encodings,
      "bounding_boxes_raw":
          boundingBoxes.map((e) => jsonEncode(e)).toList().toString(),
    });

    final response = await dio.post(
      'https://abs.chiggydoes.tech/get_class_encodings',
      data: formData,
    );

    print(response);

    if (response.statusCode != 200) {
      throw UnknownError();
    }

    var data = List<String>.from(response.data);

    var presentStudents = <Student>[];

    for (var i = 0; i < data.length; i++) {
      var faceEncoding = data[i];
      // Find student with this face encoding
      Student? s = null;
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

    print("Here");
  }
}
