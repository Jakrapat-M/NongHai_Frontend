import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:nonghai/pages/chat/chat_room_page.dart';
import 'package:nonghai/pages/tracking_page.dart';
import 'package:nonghai/services/noti/show_or_hide_noti.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  late GlobalKey<NavigatorState> _navigatorKey;

  NotificationService({required GlobalKey<NavigatorState> navigatorKey}) {
    _navigatorKey = navigatorKey;
  }

  Future<void> initialize() async {
    final settings = await _firebaseMessaging.requestPermission(
      provisional: true,
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
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
            receiverID: message.data['identifer'],
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
    // print(object)
    final hideNoti = ShowOrHideNoti().showOrHideNoti(message.data['identifer']);
    if (message.notification != null && !hideNoti) {
      final snackbar = SnackBar(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: TextButton(
          onPressed: () {
            handleMessage(message);
          },
          child: Row(
            children: [
              Text(
                '${message.notification!.title!}: ',
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black), // Optional: Change text color for better visibility
              ),
              const SizedBox(width: 8),
              Text(
                overflow: TextOverflow.clip,
                maxLines: 1,
                message.notification!.body!,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black), // Optional: Change text color for better visibility
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(_navigatorKey.currentContext!).size.height - 100,
        ),
        duration: const Duration(seconds: 3),
      );

      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(snackbar);
    }
  }
}
