import 'dart:io';

import 'package:attendance_manager/classes/data/provider/class_page_provider.dart';
import 'package:attendance_manager/student/data/models/student.dart';
import 'package:attendance_manager/student/data/providers/student_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final formKey = GlobalKey<FormState>();

  String name = '';
  String rollNo = '';
  File? imageFile;

  @override
  void initState() {
    super.initState();

    var student = context.read<StudentFormProvider>().student;
    if (student != null) {
      name = student.name;
      rollNo = student.rollNo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentFormProvider>(builder: (context, provider, child) {
      var student = provider.student;

      return PopScope(
        canPop: !changesMade(student),
        onPopInvoked: onPopInvoked,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Student Form'),
            actions: student == null
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await provider.deleteStudent();
                        context
                            .read<ClassPageProvider>()
                            .deleteStudent(student);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
          ),
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      initialValue: rollNo,
                      decoration: const InputDecoration(
                        labelText: 'Roll Number',
                      ),
                      onChanged: (value) {
                        setState(() {
                          rollNo = value;
                        });
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a roll number';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (student == null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FilledButton(
                          onPressed: () async =>
                              await chooseImage(ImageSource.gallery),
                          child: const Text("Select Image (Gallery)")),
                    ),
                  if (student == null && imageFile != null) ...[
                    getImageWidget(),
                  ]
                ],
              ),
            ),
          ),
          floatingActionButton: getFab(provider),
        ),
      );
    });
  }

  Future<void> chooseImage(ImageSource imageSource) async {
    // Choose image from gallery
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: imageSource,
      maxHeight: 480,
      maxWidth: 640,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Widget getImageWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.file(
        imageFile!,
        height: 200,
        width: 200,
      ),
    );
  }

  Widget? getFab(StudentFormProvider provider) {
    if (!changesMade(provider.student)) {
      return null;
    }
    var student = provider.student;
    return FloatingActionButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          if (!formKey.currentState!.validate()) {
            return;
          }
          formKey.currentState!.save();
          if (student != null) {
            // Just update name and roll number
            await provider.saveStudent(name, rollNo, null);
            context.read<ClassPageProvider>().notifyListeners();
            Navigator.of(context).pop();
            return;
          }

          if (imageFile == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please select an image',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onError),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            return;
          }

          formKey.currentState!.save();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              );
            },
          );

          try {
            var student = await provider.saveStudent(
              name,
              rollNo,
              imageFile!,
            );

            var classProvider = context.read<ClassPageProvider>();
            classProvider.addStudent(student);
          } catch (e) {
            if (!mounted) return;

            if (e is FaceNotFound) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Face not found in the image',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.onError),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
              Navigator.of(context).pop();
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'An unknown error occurred',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onError),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            Navigator.of(context).pop();

            return;
          }

          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      },
      child: const Icon(Icons.save),
    );
  }

  bool changesMade(Student? student) {
    if (student == null) {
      return name.isNotEmpty || rollNo.isNotEmpty;
    }

    return name != student.name || rollNo != student.rollNo;
  }

  void onPopInvoked(didPop) {
    if (didPop) {
      return;
    }

    var provider = context.read<StudentFormProvider>();
    if (changesMade(provider.student)) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Discard Changes?'),
            content:
                const Text('Are you sure you want to discard the changes?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Yes"),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}
