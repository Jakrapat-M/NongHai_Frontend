import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_button.dart';
import 'package:nonghai/components/custom_text_field.dart';
import 'package:nonghai/services/auth/auth_service.dart';
// import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() {
    // final email = emailController.text;
    // final password = passwordController.text;
    final authService = AuthService();
    try {
      authService.signInWithEmailandPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
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
                //image
                const SizedBox(height: 50),
                Image.asset(
                  'assets/images/Logo.png',
                  width: 200,
                ),
                const Text('Welcome!', style: TextStyle(fontSize: 40)),
                const Text('NonghHai', style: TextStyle(fontSize: 24)),

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
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                    controller: emailController,
                    hintText: "Email",
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

                //sign in button
                const SizedBox(height: 5),
                CustomButton1(
                  text: "Sign In",
                  onTap: signIn,
                ),

                //go to register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: widget.onTap,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepPurple),
                      ),
                    ),
                    // TextButton(
                    //   onPressed: onTap,
                    //   child: const Text("Sign Up",
                    //       style: TextStyle(
                    //           color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold)),
                    // ),
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
