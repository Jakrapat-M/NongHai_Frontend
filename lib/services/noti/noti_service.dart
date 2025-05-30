import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nonghai/main.dart';
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

      showCustomNotification(
        message.data['navigate_to'],
        message.notification!.title!,
        message.notification!.body!,
        payload: message.data['identifer'],
      );
    }
  }

  Future<void> showCustomNotification(String navTo, String title, String body,
      {required String payload}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'custom_channel_id',
      'Custom Notifications',
      channelDescription: 'Channel for custom-styled notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
      ),
      color: const Color(0xffC8A48A),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    switch (navTo) {
      case 'tracking':
        await flutterLocalNotificationsPlugin.show(
          1, // Notification ID
          title,
          body,
          platformChannelSpecifics,
          payload: payload, // Include the payload to trigger navigation
        );
        break;
      case 'chat':
        await flutterLocalNotificationsPlugin.show(
          2, // Notification ID
          title,
          body,
          platformChannelSpecifics,
          payload: payload, // Include the payload to trigger navigation
        );
        break;
      default:
        await flutterLocalNotificationsPlugin.show(
          0, // Notification ID
          title,
          body,
          platformChannelSpecifics,
          payload: payload, // Include the payload to trigger navigation
        );
        break;
    }
  }
}
