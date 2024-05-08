import 'package:attendance_manager/classes/data/models/class_model.dart';
import 'package:attendance_manager/classes/data/provider/class_page_provider.dart';
import 'package:attendance_manager/classes/presentation/pages/class_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassListtileWidget extends StatelessWidget {
  const ClassListtileWidget({super.key, required this.class_});

  final Class class_;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return ChangeNotifierProvider(
                create: (context) => ClassPageProvider(class_: class_),
                child: const ClassPage(),
              );
            }),
          );
        },
        title: Text(class_.name),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person),
            Text(class_.students.length.toString()),
          ],
        ),
      ),
    );
  }
}
