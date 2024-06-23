import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:task_management/login_view.dart';
import 'package:task_management/user_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _username;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _username = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Register',
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: Scaffold(
          body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100.0),
        child: Column(children: [
          const Text(
            'Register',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xff02802d)),
          ),
          const Padding(
            padding: EdgeInsets.only(
              top: 70.0,
              left: 40.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Enter your Email',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(0, 0, 0, 50)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, left: 25.0, right: 25.0, bottom: 25.0),
            child: TextField(
              controller: _email,
              decoration: InputDecoration(
                  labelText: 'Email address',
                  labelStyle: const TextStyle(
                      fontFamily: 'Montserrat-Regular', fontSize: 13.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: 40.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Enter your Username',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(0, 0, 0, 50)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, left: 25.0, right: 25.0, bottom: 25.0),
            child: TextField(
              controller: _username,
              decoration: InputDecoration(
                  labelText: 'username',
                  labelStyle: const TextStyle(
                      fontFamily: 'Montserrat-Regular', fontSize: 13.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: 40.0,
              top: 5.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Enter your password ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(0, 0, 0, 50)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
            child: TextField(
              controller: _password,
              enableSuggestions: false,
              autocorrect: false,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                      fontFamily: 'Montserrat-Regular', fontSize: 13.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
            ),
          ),
          Column(
            children: [
              Padding(
                  padding:
                      const EdgeInsets.only(top: 60.0, left: 25.0, right: 25.0),
                  child: SizedBox(
                    width: 350.0,
                    height: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff02802d),
                      ),
                      onPressed: () async {
                        final email = _email.text.trim();
                        final password = _password.text.trim();
                        final username = _username.text.trim();

                        if (email.isEmpty || !email.contains('@')) {
                          Get.snackbar(
                              "Invalid", "Enter the correct email address",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.1),
                              colorText: Colors.green);
                          return;
                        }
                        if (password.isEmpty || password.length < 6) {
                          Get.snackbar("Password invalid",
                              "Your password cannot be empty and not less than 6 characters",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.1),
                              colorText: Colors.green);
                        }
                        if (username.isEmpty) {
                          Get.snackbar("Username invalid", "Enter the username",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.1),
                              colorText: Colors.green);
                        }
                        try {
                          final existingUser = await FirebaseFirestore.instance
                              .collection('Users')
                              .where('Email', isEqualTo: email)
                              .get();

                          if (existingUser.docs.isNotEmpty) {
                            Get.snackbar(
                              "Email Exists",
                              "The email address is already registered.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.1),
                              colorText: Colors.green,
                            );
                            return;
                          }
                          final authResult = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          final user = authResult.user;
                          final userModel = UserModel(
                            username: username,
                            email: email,
                          );

                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(user?.uid)
                              .set(userModel.toJson());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginView(),
                            ),
                          );
                          print("account successfully created");
                        } catch (error) {
                          // Handle errors from Firebase Authentication
                          print("Error ${error.toString()}");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${error.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(color: Color(0xffFFFFFF)),
                      ),
                    ),
                  )),
              Padding(
                padding:
                    const EdgeInsets.only(top: 30.0, left: 25.0, right: 25.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginView()));
                  },
                  child: Text(
                    'Already have an account? login here',
                  ),
                ),
              ),
            ],
          ),
        ]),
      )),
    );
  }
}
