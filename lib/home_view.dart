import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_management/listing_pages/completed.dart';
import 'package:task_management/listing_pages/high_priority.dart';
import 'package:task_management/listing_pages/in_progress.dart';
import 'package:task_management/listing_pages/incomplete.dart';
import 'package:task_management/listing_pages/low_priority.dart';
import 'package:task_management/listing_pages/medium_priority.dart';
import 'package:task_management/listing_pages/pending_task.dart';
import 'package:task_management/listing_pages/total.dart';
import 'package:task_management/new_task.dart';
import 'package:task_management/retrieve_number.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? _userName;
  final TaskService _taskService = TaskService();
  bool _shouldRefresh = false;

  void _refreshHomePage() {
    setState(() {
      _shouldRefresh = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          setState(() {
            _userName = snapshot.data()?['Username'];
          });
        } else {
          print('User does not exist in the database');
        }
      } catch (e) {
        print('error fetching user data: $e');
      }
    }
  }

  Future<int> fetchTaskCountByStatus(String status) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection('tasks')
            .where('status', isEqualTo: status)
            .get();

        return snapshot
            .size; // Return the number of documents matching the query
      } catch (e) {
        print('Error fetching task count: $e');
        return 0; // Return 0 or handle the error as per your application's logic
      }
    }
    return 0; // Return 0 if user is null (though ideally, handle authentication properly)
  }

  Future<int> fetchTaskCountByPriority(String priority) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('priority', isEqualTo: priority)
          .get();

      return querySnapshot.size;
    } catch (e) {
      print('Error fetching task count by priority: $e');
      return 0; // Return 0 or handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Montserrat'),
        home: Scaffold(
            appBar: AppBar(
              title: Column(
                children: [
                  Text(
                    'Hello ${_userName ?? ''}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  ),
                  const Text(
                    "What's your plan today?",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 13),
                  ),
                ],
              ),
              centerTitle: true,
              toolbarHeight: 80,
              elevation: 0.0,
              backgroundColor: const Color(0xff02802D),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0)),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TotalTask(
                                        onSaveCallback: _refreshHomePage)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Container(
                                width: 141,
                                height: 122,
                                decoration: BoxDecoration(
                                  color: const Color(0xff02802D),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: FutureBuilder<int>(
                                  future: _taskService.fetchTotalTaskCount(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}'),
                                      );
                                    } else {
                                      return Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          Text(
                                            'Total tasks',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            child: Text(
                                              '${snapshot.data ?? 0}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CompletedTask(
                                            onSaveCallback: _refreshHomePage)));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffD02C09),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Text(
                                          'Completed\ntasks',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        FutureBuilder<int>(
                                          future: fetchTaskCountByStatus(
                                              'Completed'), // Replace with your method to fetch completed tasks count
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator(); // Placeholder while loading
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}'); // Error handling
                                            } else {
                                              return Positioned(
                                                bottom: 10,
                                                child: Text(
                                                  '${snapshot.data ?? 0}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                InProgressTask(
                                                    onSaveCallback:
                                                        _refreshHomePage)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffD02C09),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.topCenter,
                                          children: [
                                            Text(
                                              'In progress\ntasks',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              child: FutureBuilder<int>(
                                                future: fetchTaskCountByStatus(
                                                    'In progress'),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator();
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    return Text(
                                                      '${snapshot.data ?? 0}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24,
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                IncompleteTask(
                                                    onSaveCallback:
                                                        _refreshHomePage)));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffD02C09),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.topCenter,
                                          children: [
                                            Text(
                                              'Incomplete\ntasks',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              child: FutureBuilder<int>(
                                                // Replace this with your actual future function
                                                future: fetchTaskCountByStatus(
                                                    'Uncompleted'),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator();
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    return Text(
                                                      '${snapshot.data ?? 0}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24,
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HighPriority(
                                            onSaveCallback: _refreshHomePage)));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff50B8FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Text(
                                          'High-priority\ntask',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          child: FutureBuilder<int>(
                                            // Replace this with your actual future function
                                            future: fetchTaskCountByPriority(
                                                'High'),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else {
                                                return Text(
                                                  '${snapshot.data ?? 0}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MediumPriority(
                                            onSaveCallback: _refreshHomePage)));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff50B8FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Text(
                                          'Med-priority\ntasks',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          child: FutureBuilder<int>(
                                            // Replace this with your actual future function
                                            future: fetchTaskCountByPriority(
                                                'Medium'),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else {
                                                return Text(
                                                  '${snapshot.data ?? 0}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LowPriority(
                                            onSaveCallback: _refreshHomePage)));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff50B8FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Text(
                                          'Low-priority\ntasks',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          child: FutureBuilder<int>(
                                            // Replace this with your actual future function
                                            future:
                                                fetchTaskCountByPriority('Low'),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else {
                                                return Text(
                                                  '${snapshot.data ?? 0}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PendingTask(
                                        onSaveCallback: _refreshHomePage)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Center(
                              child: Container(
                                width: 300,
                                decoration: BoxDecoration(
                                  color: const Color(0xffEC9C00),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: FutureBuilder<List<String>>(
                                  future: _taskService.fetchPendingTasks(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}'),
                                      );
                                    } else {
                                      List<String> pendingTasks =
                                          snapshot.data ?? [];
                                      return Column(
                                        mainAxisSize: MainAxisSize
                                            .min, // Ensure the column occupies minimum height
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Pending tasks',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          ListView.builder(
                                            shrinkWrap:
                                                true, // Allow ListView to occupy only the space it needs
                                            physics:
                                                NeverScrollableScrollPhysics(), // Disable scrolling
                                            itemCount: pendingTasks.length,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                title: Text(
                                                  '${index + 1}. ${pendingTasks[index]}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: const Color(0xff02802D),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.logout,
                  ),
                  label: 'Logout',
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ],
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                      backgroundColor: const Color(0xff02802D),
                      elevation: 0.0,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewTask(
                                      onSaveCallback: () {
                                        setState(() {
                                          // Refresh task list or UI
                                        });
                                      },
                                    )));
                      },
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 3, color: Colors.red),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      )),
                  const Text(
                    'Add Task',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )));
  }
}
