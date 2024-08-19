import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_button.dart';
import 'package:nonghai/components/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //TODO: Implement sign up logic
  void signUp() {
    // final email = emailController.text;
    // final password = passwordController.text;
    // final confirmPassword = confirmPasswordController.text;

    // if (password != confirmPassword) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //     content: Text("Passwords do not match"),
    //   ));
    //   return;
    // }

    // // Sign up logic
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

                const Text('Regiester', style: TextStyle(fontSize: 30)),
                // Email
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                      controller: emailController, hintText: "Email", obscureText: false),
                ),

                // Password
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                      controller: passwordController, hintText: "Password", obscureText: true),
                ),

                // Confirm Password
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: true),
                ),

                //button
                const SizedBox(height: 50),
                CustomButton1(
                  text: "Register",
                  onTap: signUp,
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
                              color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold)),
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
