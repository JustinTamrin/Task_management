import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_management/home_view.dart';
import 'package:task_management/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please enter both email and password"),
            backgroundColor: Colors.redAccent.withOpacity(0.1),
          ),
        );
        return;
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                "Failed to login. Please check your credentials.",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent.withOpacity(0.1),
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Credentials",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      padding: const EdgeInsets.only(top: 100.0),
      child: Column(children: [
        const Text(
          'Login to your Account',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xff02802d)),
        ),
        const Text(
          'Welcome! Login using your existing account',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: Color(0xff02802d)),
          textAlign: TextAlign.center,
        ),
        const Padding(
          padding: EdgeInsets.only(
            left: 40.0,
            top: 25.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Email',
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
            controller: _emailController,
            decoration: InputDecoration(
                labelText: 'email',
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
                'Password ',
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
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(fontSize: 13.0),
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
                    onPressed: _login,
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Color(0xffFFFFFF)),
                    ),
                  ),
                )),
            Padding(
                padding:
                    const EdgeInsets.only(top: 30.0, left: 25.0, right: 25.0),
                child: SizedBox(
                  width: 350.0,
                  height: 50.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shadowColor: Colors.black, elevation: 10.0),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterView()));
                    },
                    child: const Text(
                      'Dont have an account? sign in here',
                    ),
                  ),
                )),
          ],
        ),
      ]),
    ));
  }
}
