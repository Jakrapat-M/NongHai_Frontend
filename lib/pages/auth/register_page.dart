import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_button.dart';
import 'package:nonghai/components/custom_text_field.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nonghai/services/caller.dart';
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

  void createAccount(BuildContext context) {
    if (passwordController.text == confirmPasswordController.text) {
      final userData = {
        "id": "",
        "username": usernameController.text,
        "name": "mairu",
        "surname": "maiiiiru",
        "email": emailController.text,
        "phone": "123456789",
        "address": "kmutt",
        "latitude": 40.712776,
        "longitude": -74.005974,
        "image": ""
      };
      // Navigate to Add Profile Image page and pass userData
      Navigator.pushNamed(context, '/addProfileImage', arguments: userData);
    } else {
      // Handle password mismatch
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Password does not match'),
                  content: const Text('Please ensure your passwords match.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
      }
    }
  }

  void signUp(BuildContext context) async {
    // getEnv();
    // print(apiUrl);
    if (passwordController.text == confirmPasswordController.text) {
      // Get auth service
      final authService = AuthService();
      try {
        // Sign up with Firebase
        UserCredential userCredential =
            await authService.signUpWithEmailandPassword(
                emailController.text, passwordController.text);

        // Get the Firebase User's UID
        String uid = userCredential.user!.uid;

        // Prepare the data for the createUser API
        final userData = {
          "id": uid,
          "username":
              emailController.text.split('@')[0], // Example username from email
          "name": "mairu",
          "surname": "maiiiiru",
          "email": emailController.text,
          "phone": "123456789",
          "address": "kmutt",
          "latitude": 40.712776,
          "longitude": -74.005974,
          "image": ""
        };

        // Call the createUser API
        final response = await Caller.dio.post(
          ("/user/createUser"), // Adjust to your API URL
          data: userData,
        );

        // Check if API call was successful
        if (response.statusCode == 201) {
          print('resp: ${response.data}');
          Navigator.pushNamed(context, '/home');
        } else {
          // Handle error from API
          if (mounted) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('API Error'),
                      content: Text(response.data),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ));
          }
        }
      } catch (e) {
        // Handle Firebase sign-up error
        print('Error occurred: ${e.toString()}');
      }
    } else {
      // Handle password mismatch
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Password does not match'),
                  content: const Text('Please ensure your passwords match.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
      }
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
                      onPressed: () => {
                        (Navigator.canPop(context))
                            ? Navigator.pop(context)
                            : Navigator.pushNamed(context, '/login'),
                      },
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
