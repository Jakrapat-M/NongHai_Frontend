import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nonghai/pages/nfc_page.dart';
// import 'package:flutter/painting.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
import 'package:nonghai/pages/test_nfc_page.dart';
import 'package:nonghai/pages/tracking_page.dart';
import 'package:nonghai/services/auth/login_or_registoer.dart';
import 'package:nonghai/firebase_options.dart';
import 'package:nonghai/pages/home_page.dart';
import 'package:nonghai/services/auth/auth_gate.dart';
import 'package:nonghai/services/noti/noti_service.dart';
// import 'package:nonghai/services/auth/auth_service.dart';
// import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final navigatorKey = GlobalKey<NavigatorState>();
  final notificationService = NotificationService(navigatorKey: navigatorKey);

  await notificationService.initialize();
  await notificationService.initPushNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initializeDateFormatting('th_TH', null);
  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    final fragment = uri.fragment;

    // Print the full URI for debugging purposes
    debugPrint('Navigating to: $fragment');

    // Navigate to TrackingPage
    widget.navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) {
        return TrackingPage(
          petId: fragment,
          petName: 'Ella',
          petImage: 'petImage',
        );
      },
    ));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      title: 'Nonghai',
      theme: ThemeData(
        colorScheme: ThemeData().colorScheme.copyWith(
            primary: const Color(0xffC8A48A),
            secondary: const Color(0xffE8E8E8),
            surface: const Color(0xffF2F2F2), // page background
            tertiary: const Color(0xffFfffff), //textfield
            onSurface: const Color(0xff2C3F50), //blue surface(box/button)
            secondaryContainer: const Color(0xffE8E8E8), //container
            secondaryFixed: const Color(0xff2C3F50), //container
            surfaceBright: const Color(0xff5DB671), // green container box(status)
            onErrorContainer: Colors.red // red container box(status)
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
          labelMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xffC8A48A),
              fontFamily: 'Fredoka'),
          labelSmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xffFfffff),
              fontFamily: 'Fredoka'),
          bodySmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff8C8C8C),
              fontFamily: 'Fredoka'),
          labelLarge: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xff1E1E1E)),
          // labelMedium: TextStyle(
          //     fontFamily: 'Fredoka',
          //     fontSize: 9,
          //     fontWeight: FontWeight.w500,
          //     color: Color(0xff5C5C5C)),
          // labelSmall: TextStyle(
          //     fontFamily: 'Fredoka',
          //     fontSize: 8,
          //     fontWeight: FontWeight.w600,
          //     color: Color(0xffffffff)),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w500,
              color: Color(0xff2C3F50),
              fontFamily: 'Fredoka'),
          backgroundColor: Color(0xffffffff),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xff2C3F50), size: 25),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/loginOrRegister': (context) => const LoginOrRegistoer(),
        '/home': (context) => const HomePage(),
        '/testnfc': (context) => const TestNfcPage(),
        '/nfc': (context) => const NfcPage(
              petId: '550e8400-e29b-41d4-a716-446655440000',
            ),
        '/tracking': (context) => const TrackingPage(
            petId: '550e8400-e29b-41d4-a716-446655440000',
            petName: 'Ella',
            petImage: 'assets/images/test.jpg'),
      },
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}
