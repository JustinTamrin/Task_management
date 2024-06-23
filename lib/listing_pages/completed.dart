import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management/update_task.dart'; // Assuming UpdateTask is in update_task.dart

class CompletedTask extends StatefulWidget {
  final VoidCallback onSaveCallback;
  const CompletedTask({super.key, required this.onSaveCallback});

  @override
  State<CompletedTask> createState() => _CompletedTaskState();
}

class _CompletedTaskState extends State<CompletedTask> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
              .where('status', isEqualTo: 'Completed')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No completed tasks found.'));
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            task['description'],
                            style: TextStyle(color: Colors.white),
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
        return Priority.Medium; // Default to Medium if unknown
    }
  }
}
