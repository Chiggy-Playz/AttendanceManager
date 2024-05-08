import 'package:attendance_manager/auth/data/user_repository.dart';
import 'package:attendance_manager/classes/data/models/class_model.dart';
import 'package:attendance_manager/home/presentation/widgets/class_list_tile.dart';
import 'package:attendance_manager/home/presentation/widgets/new_class_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserRepository>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              user.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("classes").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            var classes = snapshot.data!.docs;

            if (classes.isEmpty) {
              return Center(
                child: Text(
                  "No classes found",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              );
            }

            return ListView.builder(
              itemCount: classes.length,
              itemBuilder: (context, index) {
                var data = classes[index].data();
                data["id"] = classes[index].id;
                var class_ = Class.fromJson(data);
                return ClassListtileWidget(class_: class_);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addClass,
        tooltip: "Add Class",
        child: const Icon(Icons.add),
      ),
    );
  }

  void addClass() async {
    showDialog(
      context: context,
      builder: (context) => const NewClassDialog(),
    );
  }
}
