import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
import 'package:nonghai/pages/nfc_page.dart';
import 'package:nonghai/pages/tracking_page.dart';
import 'package:nonghai/services/auth/login_or_registoer.dart';
import 'package:nonghai/firebase_options.dart';
import 'package:nonghai/pages/home_page.dart';
import 'package:nonghai/services/auth/auth_gate.dart';
// import 'package:nonghai/services/auth/auth_service.dart';
// import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
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
              secondaryContainer: const Color(0xffE8E8E8), //container
              secondaryFixed: const Color(0xff2C3F50), //container
            ),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xff2C3F50),
              fontFamily: 'Fredoka'),
          bodyLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xff2C3F50),
              fontFamily: 'Fredoka'),
          bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff2C3F50),
              fontFamily: 'Fredoka'),
          bodySmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff8C8C8C),
              fontFamily: 'Fredoka'),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w500,
              color: Color(0xff2C3F50),
              fontFamily: 'Fredoka'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xff2C3F50), size: 36),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/loginOrRegister': (context) => const LoginOrRegistoer(),
        '/home': (context) => const HomePage(),
        '/nfc': (context) => const NfcPage(),
        '/tracking': (context) => const TrackingPage(
            petId: '318f9090-1613-4016-8d16-0f2de8223564',
            petName: 'Ella',
            petImage: 'assets/images/test.jpg'),
      },
    );
  }
}
