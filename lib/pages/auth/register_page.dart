// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_button.dart';
import 'package:nonghai/components/custom_text_field.dart';
// import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // String apiUrl = "", token = "";

  // void getEnv() async {
  //   await dotenv.load(fileName: ".env");
  //   apiUrl = dotenv.env['API_URL']!;
  //   token = dotenv.env['TOKEN']!;
  //   print(apiUrl);
  // }

  void createAccount(BuildContext context) async {
    if (passwordController.text == confirmPasswordController.text &&
        passwordController.text.length >= 6) {
      final email = emailController.text;
      final FirebaseAuth auth = FirebaseAuth.instance;

      try {
        // Sign up with Firebase Authentication
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: email,
          password: passwordController.text,
        );

        // Get the Firebase User's UID
        String uid = userCredential.user?.uid ?? "";

        // Prepare user data for the next step
        final userData = {
          "id": uid,
          "username": usernameController.text,
          "name": "-",
          "surname": "-",
          "email": email,
          "password": passwordController.text,
          "phone": "-",
          "address": "-",
          "latitude": 13.7540,
          "longitude": 100.5014, // latitude / longitude of TH
          "image": ""
        };

        // Navigate to Add Profile Image page and pass userData
        Navigator.pushNamed(context, '/addProfileImage', arguments: userData);
      } on FirebaseAuthException catch (e) {
        // Handle errors like email already in use
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage =
              'The provided email is already registered. Please use a different email.';
        } else {
          errorMessage = e.message ?? 'An error occurred. Please try again.';
        }
        // Show the error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Handle password mismatch or length issues
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid Password'),
          content: const Text(
              'Please ensure your password has at least 6 characters and matches.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // getEnv();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.chat, size: 100),

                const Text('Register', style: TextStyle(fontSize: 30)),
                // Email
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                    hintStyle: Theme.of(context).textTheme.displayLarge,
                  ),
                ),

                //Username
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                    controller: usernameController,
                    hintText: "Username",
                    obscureText: false,
                    hintStyle: Theme.of(context).textTheme.displayLarge,
                  ),
                ),

                // Password
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                    hintStyle: Theme.of(context).textTheme.displayLarge,
                  ),
                ),

                // Confirm Password
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    obscureText: true,
                    hintStyle: Theme.of(context).textTheme.displayLarge,
                  ),
                ),

                //register button
                const SizedBox(height: 50),
                CustomButton1(
                  text: "Register",
                  onTap: () => createAccount(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: widget.onTap,
                      // onPressed: () => {
                      //   Navigator.pop(context)
                      // (Navigator.canPop(context))
                      //     ? Navigator.pop(context)
                      //     : Navigator.pushNamed(context, '/loginOrRegister'),
                      // },
                      child: const Text("Sign In",
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
