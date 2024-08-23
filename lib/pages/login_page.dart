import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_button.dart';
import 'package:nonghai/components/custom_text_field.dart';
import 'package:nonghai/pages/home_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  // final void Function()? onTap;
  // const LoginPage({super.key, required this.onTap});
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //TODO: Implement sign in logic
  void signIn() async {
    // final email = emailController.text;
    // final password = passwordController.text;
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signInWithEmailandPassword(
          emailController.text, passwordController.text);

      //go to homepage after login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const HomePage()), // Ensure HomePage is imported
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }

    // Sign in logic
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
                const Text('NongHai', style: TextStyle(fontSize: 30)),

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

                //sign in button
                const SizedBox(height: 50),
                CustomButton1(
                  text: "Sign In",
                  onTap: signIn,
                ),

                //go to register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
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
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text("Sign Up",
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
