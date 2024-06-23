import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum Priority { High, Medium, Low }

class UpdateTask extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final String? initialStatus;
  final Priority? initialPriority;
  final String? taskId;
  final void Function() onSaveCallback;
  const UpdateTask({
    Key? key,
    this.initialTitle,
    this.initialDescription,
    this.initialStatus,
    this.initialPriority,
    this.taskId,
    required this.onSaveCallback,
  }) : super(key: key);

  @override
  State<UpdateTask> createState() => _UpdateTaskState();
}

class _UpdateTaskState extends State<UpdateTask> {
  Priority _selectedPriority = Priority.Medium;
  final List<String> _dropdownItems = [
    'Uncompleted',
    'Completed',
    'In progress',
  ];
  String _selectedDropDownItem = 'Uncompleted';
  late TextEditingController _titleController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
    _selectedDropDownItem = widget.initialStatus ?? 'Uncompleted';
    _selectedPriority = widget.initialPriority ?? Priority.Medium;
  }

  void updateTask() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('No user is logged in.');
      return;
    }

    if (title.isNotEmpty && description.isNotEmpty && widget.taskId != null) {
      try {
        DocumentReference taskRef =
            FirebaseFirestore.instance.collection('tasks').doc(widget.taskId);

        DocumentSnapshot taskSnapshot = await taskRef.get();

        if (taskSnapshot.exists) {
          var taskData = taskSnapshot.data() as Map<String, dynamic>;

          if (taskData['userId'] == userId) {
            await taskRef.update({
              'title': title,
              'description': description,
              'status': _selectedDropDownItem,
              'priority': _selectedPriority.toString().split('.').last,
              'userId': userId,
            });

            print('Task updated successfully!');
            widget.onSaveCallback();
          }
        }
      } catch (e) {
        print('Failed to update task: $e');
      }
    } else {
      print('Title and description cannot be empty');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.green,
                title: const Text(
                  'Update task',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    updateTask();
                    Navigator.of(context).pop();
                  },
                )),
            body: SingleChildScrollView(
                child: Column(children: [
              TextField(
                controller: _titleController,
                onChanged: (value) {},
                decoration: InputDecoration(
                    hintText: 'Enter the title...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextField(
                controller: _descriptionController,
                onChanged: (value) {},
                decoration: InputDecoration(
                    hintText: 'Type something...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                maxLines: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      value: _selectedDropDownItem,
                      icon: const Icon(Icons.arrow_right),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Color(0xff02802D)),
                      underline: Container(
                        height: 2,
                        color: const Color(0xff02802D),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDropDownItem = newValue ?? _dropdownItems[0];
                        });
                      },
                      items: _dropdownItems
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Priority:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio<Priority>(
                                  value: Priority.High,
                                  groupValue: _selectedPriority,
                                  onChanged: (Priority? value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedPriority = value;
                                      });
                                    }
                                  },
                                ),
                                const Text('High'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<Priority>(
                                  value: Priority.Medium,
                                  groupValue: _selectedPriority,
                                  onChanged: (Priority? value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedPriority = value;
                                      });
                                    }
                                  },
                                ),
                                const Text('Medium'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<Priority>(
                                  value: Priority.Low,
                                  groupValue: _selectedPriority,
                                  onChanged: (Priority? value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedPriority = value;
                                      });
                                    }
                                  },
                                ),
                                const Text('Low'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]))));
  }
}
