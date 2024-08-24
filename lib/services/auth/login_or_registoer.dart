import 'package:flutter/material.dart';
import 'package:nonghai/pages/login_page.dart';
import 'package:nonghai/pages/register_page.dart';

class LoginOrRegistoer extends StatefulWidget {
  const LoginOrRegistoer({super.key});

  @override
  State<LoginOrRegistoer> createState() => _LoginOrRegistoerState();
}

class _LoginOrRegistoerState extends State<LoginOrRegistoer> {
  bool showLoginPage = true;

  // toggler
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}
