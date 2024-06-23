import 'package:cloud_firestore/cloud_firestore.dart';
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
    // Set the initial value for the dropdown
    // Initialize dropdown and priority values with initial values or default values
    _selectedDropDownItem = widget.initialStatus ?? 'Uncompleted';
    _selectedPriority = widget.initialPriority ?? Priority.Medium;
  }

  void updateTask() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty && widget.taskId != null) {
      try {
        await _firestore.collection('tasks').doc(widget.taskId).update({
          'title': title,
          'description': description,
          'status': _selectedDropDownItem,
          'priority': _selectedPriority.toString().split('.').last,
        });

        print('Task updated successfully!');
        widget.onSaveCallback();
      } catch (e) {
        print('Failed to update task: $e');
        // Handle error gracefully (e.g., show snackbar)
      }
    } else {
      print('Title and description cannot be empty');
      // Optionally, show a snackbar or dialog to inform the user
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
                onChanged: (value) {
                  // Optional: Trigger saveTask on title change
                  // saveTask(); // Uncomment if you want to save on every keystroke
                },
                decoration: InputDecoration(
                    hintText: 'Enter the title...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextField(
                controller: _descriptionController,
                onChanged: (value) {
                  // Optional: Trigger saveTask on description change
                  // saveTask(); // Uncomment if you want to save on every keystroke
                },
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
                      value:
                          _selectedDropDownItem, // Set the default selected value
                      icon: const Icon(Icons.arrow_right), // Dropdown icon
                      iconSize: 24, // Icon size
                      elevation: 16, // Elevation of the dropdown
                      style: const TextStyle(
                          color: Color(
                              0xff02802D)), // Text style of the dropdown items
                      underline: Container(
                        height: 2,
                        color: const Color(0xff02802D), // Underline color
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDropDownItem = newValue ??
                              _dropdownItems[0]; // Update the selected value
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
