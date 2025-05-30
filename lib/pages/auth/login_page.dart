// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_button.dart';
import 'package:nonghai/components/custom_text_field.dart';
import 'package:nonghai/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  TextEditingController forgetEmailController = TextEditingController();

  void signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password.'),
        ),
      );
      return; // Return early if validation fails
    }

    final authService = AuthService();
    bool success = await authService.signInWithEmailAndPassword(email, password);

    if (success) {
      // Handle successful sign-in (e.g., navigate to the next screen)
    } else {
      // Show an error message in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect email or password. Please try again.'),
        ),
      );
    }
  }

  Future<void> _forgotPassword(BuildContext context) async {
    // Show a dialog to enter the email
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Reset Password',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: const Color(0xff333333)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email to receive a password reset link:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Theme.of(context).colorScheme.primary), // Border color when not focused
                  ),
                ),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 16),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () async {
                      String email = emailController.text.trim();
                      if (email.isNotEmpty) {
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Password reset email sent! Check your inbox.')),
                          );
                        } catch (e) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                        Navigator.of(context).pop(); // Close the dialog
                      } else {
                        // Show a message if the email is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your email.')),
                        );
                      }
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xffFFFFFF),
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Changed to start
                children: [
                  // Image
                  const SizedBox(height: 45),
                  Image.asset(
                    'assets/images/Logo.png',
                    width: 200,
                  ),
                  const Text('Welcome!', style: TextStyle(fontSize: 40)),
                  const Text('NongHai', style: TextStyle(fontSize: 24)),

                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Keeping your pets safe with our innovative NFC technology. Let's ensure every wagging tail finds its way home.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xff5C5C5C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Email
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CustomTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                      hintStyle: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),

                  // Password
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                      hintStyle: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),

                  // Sign In Button
                  const SizedBox(height: 5),
                  CustomButton1(
                    text: "Sign In",
                    onTap: signIn,
                  ),

                  // Forget Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _forgotPassword(context),
                        child: const Text(
                          "Forget your password?",
                          style: TextStyle(
                            color: Color(0xff333333),
                            fontFamily: "Fredoka",
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25), // Added spacing

                  // Go to Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                            color: Color(0xff333333),
                            fontFamily: 'Fredoka',
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      TextButton(
                        onPressed: widget.onTap,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Color(0xff57687C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
