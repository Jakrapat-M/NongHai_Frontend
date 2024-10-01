import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

// class NotiService {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> init() async {
//     final notificationSetion = await _firebaseMessaging.requestPermission(provisional: true);

//     final apnsToken = await _firebaseMessaging.getAPNSToken();
//     if (apnsToken != null) {
//       print('APNS Token: $apnsToken');
//       // make FCM plugin API request
//     }

//     final fCMToken = await _firebaseMessaging.getToken();

//     if (kDebugMode) {
//       print('FCM Token: $fCMToken');
//     }
//   }

//   // handle message
//   void handleMessage(RemoteMessage? message) {
//     if (message == null) return;
// // navigate to page
//     navigatorKey.currentState?.pushNamed('/notification', arguments: message);
//   }

//   Future initPushNotification() async {
//     // handle notification when app is terminated and now opened
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//   }
// }

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permissions for iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get the device token
    String? token = await _messaging.getToken();
    print("Device Token: $token");

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground: ${message.notification?.title}');
      _showNotification(message);
    });
  }

  // Show a notification
  void _showNotification(RemoteMessage message) {
    // Use a package like flutter_local_notifications to show a notification
  }
}
