// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_button.dart';
import 'package:nonghai/components/custom_text_field.dart';
import 'package:nonghai/components/validate_text_field.dart';
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
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      // Show error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return; // Return early if validation fails
    }

    if (!isValidEmail(email)) {
      // Show error if the email is not valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    if (password != confirmPassword) {
      // Show error if passwords don't match
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    if (password.length < 6) {
      // Show error if password is less than 6 characters
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters long.')),
      );
      return;
    }

    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      // Sign up with Firebase Authentication
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the Firebase User's UID
      String uid = userCredential.user?.uid ?? "";

      // Prepare user data for the next step
      final userData = {
        "id": uid,
        "username": username,
        "name": "-",
        "surname": "-",
        "email": email,
        "password": password,
        "phone": "-",
        "address": "-",
        "latitude": 13.7540,
        "longitude": 100.5014, // latitude / longitude of TH
        "image": ""
      };

      // Navigate to Add Profile Image page and pass userData
      if (mounted) {
        // Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/addProfileImage',
            arguments: userData);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage =
            'The provided email is already registered. Please use a different email.';
      } else {
        errorMessage = e.message ?? 'An error occurred. Please try again.';
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Error',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: const Color(0xff333333)),
            ),
            content: Text(
              errorMessage,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffC8A48A)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Row(
                  children: [
                    Spacer(),
                    Text(
                      'OK',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xffFFFFFF),
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w500),
                    ),
                    Spacer()
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  bool isValidEmail(String email) {
    // Regular expression for validating email format
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    // getEnv();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f2),
        title: const Text(
          "Create an account",
          style: TextStyle(
              fontFamily: "Fredoka",
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: Color(0xff57677C)),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 65, 40, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Email
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ValidateTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                    hintStyle: Theme.of(context).textTheme.displayLarge,
                    // Validate email format when the user submits the form or on a button click
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      } else if (!isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
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
                // const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButton1(
                    text: "Register",
                    onTap: () => createAccount(context),
                  ),
                ),
                const SizedBox(height: 140),
                const Text(
                  "Already have an account?",
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontFamily: 'Fredoka',
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
                TextButton(
                  onPressed: widget.onTap,
                  // onPressed: () => {
                  //   Navigator.pop(context)
                  // (Navigator.canPop(context))
                  //     ? Navigator.pop(context)
                  //     : Navigator.pushNamed(context, '/loginOrRegister'),
                  // },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Color(0xff57687C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
