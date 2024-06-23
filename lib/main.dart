import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_management/constants/routes.dart';
import 'package:task_management/home_view.dart';
import 'package:task_management/login_view.dart';
import 'package:task_management/new_task.dart';
import 'package:task_management/register_view.dart';
import 'package:task_management/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const RegisterView(),
    routes: {
      loginView: (context) => const LoginView(),
      registerView: (context) => const RegisterView(),
      homeView: (context) => const HomeView(),
      newTask: (context) => NewTask(onSaveCallback: () {
            // ignore: avoid_print
            print('object');
          }),
    },
  ));
}
