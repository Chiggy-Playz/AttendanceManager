import 'dart:io';

import 'package:attendance_manager/student/data/models/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class UnknownError extends Error {}

class FaceNotFound extends Error {}

class StudentFormProvider extends ChangeNotifier {
  Student? student;

  StudentFormProvider({this.student});

  final db = FirebaseFirestore.instance;

  Future<Student> saveStudent(
      String name, String rollNo, File? imageFile) async {
    // Save the student

    if (student == null) {
      return await createStudent(
        name: name,
        rollNo: rollNo,
        imageFile: imageFile!,
      );
    } else {
      return await updateStudent(
        name: name,
        rollNo: rollNo,
      );
    }
  }

  Future<Student> createStudent({
    required String name,
    required String rollNo,
    required File imageFile,
  }) async {
    // Now get the encoding of the image file and upload it to the storage
    // Send image to api
    final dio = Dio(BaseOptions(
      validateStatus: (status) => true,
    ));

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(imageFile.path),
    });

    try {
      final response = await dio.post(
        'https://abs.chiggydoes.tech/add_student',
        data: formData,
      );

      if (response.statusCode != 200) {
        throw UnknownError();
      }

      var data = response.data;
      if (data['encoding'] == "") {
        throw FaceNotFound();
      }

      var doc = await db.collection('students').add({
        'name': name,
        'rollNo': rollNo,
        'faceEncoding': data['encoding'],
      });

      notifyListeners();

      return Student(
        id: doc.id,
        name: name,
        rollNo: rollNo,
        faceEncoding: data['encoding'],
      );
    } catch (e) {
      if (e is FaceNotFound) {
        throw FaceNotFound();
      }

      throw UnknownError();
    }
  }

  Future<Student> updateStudent({
    required String name,
    required String rollNo,
  }) async {
    await db.collection('students').doc(student!.id).update({
      'name': name,
      'rollNo': rollNo,
    });

    notifyListeners();
    return student!;
  }

  Future<void> deleteStudent() async {
    // Delete the student
    await db.collection('students').doc(student!.id).delete();

    notifyListeners();
  }
}
