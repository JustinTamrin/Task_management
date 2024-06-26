// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamCompletedTasksFromFirestore() {
    return _firestore
        .collection('tasks')
        .where('status', isEqualTo: 'Completed')
        .snapshots()
        .map((QuerySnapshot query) {
      return query.docs.map((doc) {
        return {
          'title': doc['title'],
          'description': doc['description'],
          'status': doc['status'],
          'priority': doc['priority'],
        };
      }).toList();
    });
  }

  Future<void> createTask(
      String title, String description, String status, String priority) async {
    try {
      await _firestore.collection('tasks').add({
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
      });
    } catch (e) {
      print('Error creating task: $e');
      throw e;
    }
  }

  Future<void> updateTask(String taskId, String title, String description,
      String status, String priority) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
      });
    } catch (e) {
      print('Error updating task: $e');
      throw e;
    }
  }

  Future<List<String>> fetchPendingTasks() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is logged in.');
      return [];
    }

    try {
      List<String> pendingTasks = [];

      // Fetch tasks with status 'In progress' for the current user
      QuerySnapshot<Map<String, dynamic>> inProgressSnapshot =
          await FirebaseFirestore.instance
              .collection('tasks')
              .where('status', isEqualTo: 'In progress')
              .where('userId', isEqualTo: user.uid) // Filter by user ID
              .get();

      inProgressSnapshot.docs.forEach((doc) {
        pendingTasks.add(doc.data()['title']);
      });

      // Fetch tasks with status 'Uncompleted' for the current user
      QuerySnapshot<Map<String, dynamic>> incompleteSnapshot =
          await FirebaseFirestore.instance
              .collection('tasks')
              .where('status', isEqualTo: 'Uncompleted')
              .where('userId', isEqualTo: user.uid) // Filter by user ID
              .get();

      incompleteSnapshot.docs.forEach((doc) {
        pendingTasks.add(doc.data()['title']);
      });

      return pendingTasks;
    } catch (e) {
      print('Error fetching pending tasks: $e');
      return [];
    }
  }

  Future<int> fetchTotalTaskCount() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No user is logged in.');
      return 0;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid) // Filter by user ID
          .get();

      return querySnapshot.size;
    } catch (e) {
      print('Error fetching total task count: $e');
      return 0;
    }
  }

  Future<int> fetchTaskCountByStatus(String status) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('tasks')
          .where('status', isEqualTo: status)
          .get();
      return querySnapshot.size;
    } catch (e) {
      print('Error fetching task count by status: $e');
      return 0;
    }
  }

  Future<int> fetchTaskCountByPriority(String priority) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('tasks')
          .where('priority', isEqualTo: priority)
          .get();
      return querySnapshot.size;
    } catch (e) {
      print('Error fetching task count by priority: $e');
      return 0;
    }
  }

  // Future<Map<String, int>> fetchTaskCounts() async {
  //   try {
  //     int totalTasks = await fetchTotalTaskCount();
  //     int completedTasks = await fetchTaskCountByStatus('Completed');
  //     int inProgressTasks = await fetchTaskCountByStatus('In progress');
  //     int incompleteTasks = await fetchTaskCountByStatus('Uncompleted');
  //     int highPriorityTasks = await fetchTaskCountByPriority('High');
  //     int mediumPriorityTasks = await fetchTaskCountByPriority('Medium');
  //     int lowPriorityTasks = await fetchTaskCountByPriority('Low');

  //     return {
  //       'totalTasks': totalTasks,
  //       'completedTasks': completedTasks,
  //       'inProgressTasks': inProgressTasks,
  //       'incompleteTasks': incompleteTasks,
  //       'highPriorityTasks': highPriorityTasks,
  //       'mediumPriorityTasks': mediumPriorityTasks,
  //       'lowPriorityTasks': lowPriorityTasks,
  //     };
  //   } catch (e) {
  //     print('Error fetching task counts: $e');
  //     return {
  //       'totalTasks': 0,
  //       'completedTasks': 0,
  //       'inProgressTasks': 0,
  //       'incompleteTasks': 0,
  //       'highPriorityTasks': 0,
  //       'mediumPriorityTasks': 0,
  //       'lowPriorityTasks': 0,
  //     };
  //   }
  // }

  // Future<List<Map<String, dynamic>>> fetchCompletedTasks() async {
  //   try {
  //     List<Map<String, dynamic>> completedTasks = [];

  //     QuerySnapshot<Map<String, dynamic>> completedSnapshot = await _firestore
  //         .collection('tasks')
  //         .where('status', isEqualTo: 'Completed')
  //         .get();

  //     completedSnapshot.docs.forEach((doc) {
  //       completedTasks.add({
  //         'title': doc.data()['title'],
  //         'description': doc.data()['description'],
  //       });
  //     });

  //     return completedTasks;
  //   } catch (e) {
  //     print('Error fetching completed tasks: $e');
  //     return [];
  //   }
  // }
}
