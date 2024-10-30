import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:nonghai/pages/auth/edit_home_page.dart';
import 'package:nonghai/pages/auth/edit_pet_page.dart';
import 'package:nonghai/pages/nfc_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/auth/auth_service_inherited.dart';
import 'package:nonghai/pages/tracking_page.dart';
import 'package:nonghai/services/auth/login_or_registoer.dart';
import 'package:nonghai/firebase_options.dart';
import 'package:nonghai/pages/auth/home_page.dart';
import 'package:nonghai/services/auth/auth_gate.dart';
import 'package:nonghai/services/noti/noti_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nonghai/services/caller.dart';

import 'pages/auth/add_contact_page.dart';
import 'pages/auth/add_pet_info_page.dart';
import 'pages/auth/add_pet_profile_page.dart';
import 'pages/auth/add_profile_page.dart';
import 'pages/auth/additional_note_page.dart';
import 'pages/auth/pet_profile_page.dart';


final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  final notificationService = NotificationService(navigatorKey: navigatorKey);

  await notificationService.initialize();
  await notificationService.initPushNotification();

  FirebaseMessaging.onMessage
      .listen(notificationService.firebaseMessagingForegroundHandler);
  FirebaseMessaging.onBackgroundMessage(
      notificationService.firebaseMessagingBackgroundHandler);

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
  // final MyRouteObserver myRouteObserver = MyRouteObserver();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final AuthService authService = AuthService();

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

  Future<bool> createTracking(String petId) async {
    try {
      print("createTracking id: $petId");
      final currentUser = AuthService().getCurrentUser();
      if (currentUser == null) {
        print('No user is currently signed in.');
        return true; // Handle this case appropriately, maybe show an error message
      }
      final currentUserId = currentUser.uid;

      double lat = 0.0000000;
      double long = 0.0000000;

      print("currentUserId: $currentUserId");
      // // final position = await _getLocation();
      // if (position != null) {
      //   lat = position.latitude;
      //   long = position.longitude;
      // }

      final resp = await Caller.dio.post(
        '/tracking/createTracking',
        data: {
          'pet_id': petId,
          'finder_id': currentUserId,
          'lat': lat,
          'long': long
        },
      );
      if (resp.statusCode == 200) {
        print('Tracking created');
      } else {
        // Log the error response
        print('Failed to create tracking: ${resp.statusCode} - ${resp.data}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
    return true;
  }

  // Future<Position?> _getLocation() async {
  //   print("test getLocaion");
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   print('Checking location');
  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     print("Location services are disabled.");
  //     return null;
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       print("Location permissions are denied");
  //       return null;
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     print(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //     return null;
  //   }
  //   print("get location success");

  //   return await Geolocator.getCurrentPosition();
  // }

  void openAppLink(Uri uri) {
    final fragment = uri.fragment;

    // Show plain white loading dialog
    showDialog(
      context: widget.navigatorKey.currentState!.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: SizedBox(
              width: 50, // Small fixed size for the loading indicator
              height: 50,
              child: CircularProgressIndicator()),
        );
      },
    );

    // Execute createTracking and close the loading dialog when done
    createTracking(fragment).then((value) {
      Navigator.of(widget.navigatorKey.currentState!.context)
          .pop(); // Close loading dialog
      widget.navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) {
          return PetProfilePage(petID: fragment);
        },
      ));
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AuthServiceInherited(
      authService: authService,
      child: MaterialApp(
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
              surfaceBright:
                  const Color(0xff5DB671), // green container box(status)
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
            displayMedium: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xff5C5C5C)),
            displaySmall: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Color(0xffffffff)),
            displayLarge: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xff57687C)),
            headlineLarge: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: Color(0xff2C3F50),
                fontFamily: 'Fredoka'),
            headlineSmall: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xff333333),
                fontFamily: 'Fredoka'),
            titleSmall: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xff5C5C5C)),
            titleMedium: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff333333),
                fontFamily: 'Fredoka',
                overflow: TextOverflow.ellipsis),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xffbfbfbf),
              fontFamily: 'Fredoka',
            ),
          ),
          bannerTheme: const MaterialBannerThemeData(
            contentTextStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Color(0xff2C3F50),
                fontFamily: 'Fredoka'),
            backgroundColor: Color(0xfff2f2f2),
            elevation: 0,
            // iconTheme: IconThemeData(color: Color(0xff2C3F50), size: 25),
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
          '/editHome': (context) => const EditHomePage(
                userData: {},
              ),
          '/addProfileImage': (context) => const AddProfilePage(),
          '/addContact': (context) => const AddContactPage(),
          '/addPetProfileImage': (context) => const AddPetProfilePage(),
          '/addPetInfo': (context) => const AddPetInfoPage(),
          '/additionalNote': (context) => const AdditionalNotePage(
                note: '',
              ),
          '/petProfile': (context) {
            final dynamic petID = ModalRoute.of(context)?.settings.arguments;
            return PetProfilePage(petID: petID);
          },
          '/editPet': (context) => const EditPetPage(
                petData: {},
              ),
          '/nfc': (context) => const NfcPage(
                petId: '550e8400-e29b-41d4-a716-446655440000',
              ),
          '/tracking': (context) => const TrackingPage(
              petId: '550e8400-e29b-41d4-a716-446655440000',
              petName: 'Ella',
              petImage: 'assets/images/test.jpg'),
        },
      ),
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}
