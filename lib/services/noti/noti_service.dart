import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/pages/chat/chat_room_page.dart';
import 'package:nonghai/pages/tracking_page.dart';
import 'package:nonghai/services/chat/chat_service.dart';
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
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  final chatService = ChatService();
  // handle message
  void handleMessage(RemoteMessage? message) {
    debugPrint('noti data: ${message?.data}');

    if (message == null) return;

    switch (message.data['navigate_to']) {
      case 'tracking':
        _navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) {
            return TrackingPage(
              petId: message.data['identifer'],
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
        _navigatorKey.currentState?.push(materialPageRoute).then((value) {
          ShowOrHideNoti().resetChatting();
          // mark chat as read where navigate back from chat room
          chatService.setRead(
            message.data['identifer'],
          );
        });
        break;
      default:
        break;
    }
  }

  // Background message handler
  Future initPushNotification() async {
    // handle notification when app is terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   await Firebase.initializeApp();
  //   print('Handling a background message ${message.messageId}');
  // }

  void firebaseMessagingForegroundHandler(RemoteMessage message) {
    var hideNoti = false;
    if (message.data['navigate_to'] == 'chat') {
      hideNoti = ShowOrHideNoti().showOrHideNoti(message.data['identifer']);
    }

    if (message.notification != null && !hideNoti) {
      final snackbar = SnackBar(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(90),
        ),
        content: TextButton(
          onPressed: () {
            handleMessage(message);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center all content horizontally
            children: [
              Image.asset(
                'assets/images/Logo.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(width: 8), // Space between image and text
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft, // Center text content within Expanded
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Center text in Column
                    mainAxisSize: MainAxisSize.min, // Prevent Column from taking full height
                    children: [
                      Text(
                        message.notification!.title!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffC8A48A),
                        ),
                      ),
                      Text(
                        message.notification!.body!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 0,
        ),
        margin: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(_navigatorKey.currentContext!).size.height -
              (MediaQuery.of(_navigatorKey.currentContext!).size.height * 0.12),
        ),
        duration: const Duration(seconds: 10),
      );

      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(snackbar);
    }
  }
}
