import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/pages/nfc_page.dart';
import 'package:nonghai/services/auth/login_or_registoer.dart';
import 'package:nonghai/firebase_options.dart';
import 'package:nonghai/pages/home_page.dart';
import 'package:nonghai/services/auth/auth_gate.dart';
// import 'package:nonghai/services/auth/auth_service.dart';
// import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      initialRoute: '/nfc',
      routes: {
        '/': (context) => const AuthGate(),
        '/loginOrRegister': (context) => const LoginOrRegistoer(),
        '/home': (context) => const HomePage(),
        '/nfc': (context) => const NfcPage(),
      },
    );
  }
}
