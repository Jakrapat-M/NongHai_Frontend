import 'package:flutter/material.dart';
import 'package:nonghai/pages/login_page.dart';
import 'package:nonghai/pages/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nonghai',
      theme: ThemeData(
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: const Color(0xffC8A48A),
              secondary: const Color(0xffE8E8E8),
              surface: const Color(0xffF2F2F2), // background
              tertiary: const Color(0xffFfffff), //textfield
            ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
