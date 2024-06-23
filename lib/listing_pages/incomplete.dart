import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management/update_task.dart';

class IncompleteTask extends StatefulWidget {
  final VoidCallback onSaveCallback;
  const IncompleteTask({super.key, required this.onSaveCallback});

  @override
  State<IncompleteTask> createState() => _IncompleteTaskState();
}

class _IncompleteTaskState extends State<IncompleteTask> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            widget.onSaveCallback();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('tasks')
              .where('status', isEqualTo: 'Uncompleted')
              .where('userId', isEqualTo: _currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No incomplete tasks found.'));
            } else {
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> task =
                      doc.data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateTask(
                            taskId: doc.id,
                            initialTitle: task['title'],
                            initialDescription: task['description'],
                            initialStatus: task['status'],
                            initialPriority: _parsePriority(task['priority']),
                            onSaveCallback: () {},
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xff02802D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task['description'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }

  Priority _parsePriority(String? priorityString) {
    switch (priorityString) {
      case 'High':
        return Priority.High;
      case 'Medium':
        return Priority.Medium;
      case 'Low':
        return Priority.Low;
      default:
        return Priority.Medium;
    }
  }
}
