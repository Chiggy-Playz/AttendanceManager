import 'package:attendance_manager/classes/data/provider/class_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditClassDialog extends StatefulWidget {
  const EditClassDialog({super.key});

  @override
  State<EditClassDialog> createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<EditClassDialog> {
  String name = "";

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var class_ = context.read<ClassPageProvider>().class_;

    return AlertDialog(
      title: const Text("Edit Class"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: formKey,
            child: TextFormField(
              initialValue: class_.name,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return "Name cannot be empty";
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "Name",
              ),
              onChanged: (value) {
                name = value;
              },
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        FilledButton(
          child: const Text("Edit"),
          onPressed: () async {
            if (!formKey.currentState!.validate()) {
              return;
            }
            await context.read<ClassPageProvider>().editClassName(name);

            if (!mounted) return;
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
