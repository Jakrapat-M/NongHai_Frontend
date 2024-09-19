import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotiService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();

    if (kDebugMode) {
      print('FCM Token: $fCMToken');
    }

    // handle message
    void handleMessage(RemoteMessage? message) {
      if (message != null) return;

      // navigate to page
    }
  }
}
