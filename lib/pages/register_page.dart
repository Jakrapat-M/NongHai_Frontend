import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_button.dart';
import 'package:nonghai/components/custom_text_field.dart';
import 'package:nonghai/pages/home_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  // final void Function()? onTap;
  // const RegisterPage({super.key, required this.onTap});
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //TODO: Implement sign up logic
  void signUp() async {
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

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Incorrect Password!")));
      return;
    }

    //get auth service
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithEmailandPassword(
          emailController.text, passwordController.text);
      //navigate to homepage after sign up
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const HomePage()), // Ensure HomePage is imported
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
                      obscureText: false),
                ),

                // Password
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true),
                ),

                // Confirm Password
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: true),
                ),

                //register button
                const SizedBox(height: 50),
                CustomButton1(
                  text: "Register",
                  onTap: signUp,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    // GestureDetector(
                    //   onTap: widget.onTap,
                    //   child: const Text(
                    //     'Sign In',
                    //     style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 16,
                    //       color: Colors.deepPurple
                    //     ),
                    //   ),
                    // ),
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
