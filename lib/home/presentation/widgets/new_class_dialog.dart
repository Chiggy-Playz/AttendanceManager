import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewClassDialog extends StatefulWidget {
  const NewClassDialog({super.key});

  @override
  State<NewClassDialog> createState() => _NewClassDialogState();
}

class _NewClassDialogState extends State<NewClassDialog> {
  String name = "";

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Class"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: formKey,
            child: TextFormField(
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
          child: const Text("Add"),
          onPressed: () async {
            if (!formKey.currentState!.validate()) {
              return;
            }

            await FirebaseFirestore.instance.collection("classes").add({
              "name": name,
              "students": <String>[],
            });
            if (!mounted) return;
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
