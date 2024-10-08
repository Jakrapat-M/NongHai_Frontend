import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:nonghai/models/notification.dart';
import 'package:nonghai/pages/chat/chat_room_page.dart';
import 'package:nonghai/pages/tracking_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/caller.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  late GlobalKey<NavigatorState> _navigatorKey;

  NotificationService({required GlobalKey<NavigatorState> navigatorKey}) {
    _navigatorKey = navigatorKey;
  }

  Future<void> initialize() async {
    final authService = AuthService();
    final currentUserID = authService.getCurrentUser()!.uid;

    final settings = await _firebaseMessaging.requestPermission(provisional: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    final token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('Device Token: $token');
    }
    try {
      // Create a user token in the backend
      final resp = await Caller.dio
          .post('/token/createUserToken', data: {"user_id": currentUserID, "token": token});
      if (resp.statusCode == 200 && resp.data['data'] == "Token already exist") {
        print('Token already exist');
      } else if (resp.statusCode == 200) {
        print('Token created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
  }

  // handle message
  void handleMessage(RemoteMessage? message) {
    print('noti data: ${message?.data}');

    if (message == null) return;

    switch (message.data['navigate_to']) {
      case 'tracking':
        _navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) {
            return const TrackingPage(
              petId: "111",
              petName: 'Ella',
              petImage: 'petImage',
            );
          },
        ));
        break;
      case 'chat':
        // Navigate to Chat Page
        MaterialPageRoute materialPageRoute = MaterialPageRoute(
          builder: (context) => ChatRoomPage(
            receiverID: message.data['chat_with'],
          ),
        );

// Use the global navigator key to push the route

        _navigatorKey.currentState?.push(materialPageRoute);
        break;
      default:
        break;
    }

    // navigate to page

    // navigatorKey.currentState?.pushNamed('/notification', arguments: message);
  }

  // Background message handler
  Future initPushNotification() async {
    // handle notification when app is terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
  }

  void firebaseMessagingForegroundHandler(RemoteMessage message) {
    if (message.notification != null) {

      final snackbar = SnackBar(
        content: Text("test"),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        duration: const Duration(seconds: 5),
      );

      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(snackbar);
    }
  }
}
