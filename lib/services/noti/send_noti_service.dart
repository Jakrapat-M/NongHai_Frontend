import 'package:flutter/foundation.dart';
import 'package:nonghai/models/notification.dart';
import 'package:nonghai/services/caller.dart';

class SendNotiService {
  Future<void> sendNotification(NotificationEntity notiEntity) async {
    try {
      final resp =
          await Caller.dio.post('/notification/sendNotification', data: notiEntity.toJson());
      if (resp.statusCode == 200) {
        print('Notification sent successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
  }

  Future<void> readNotification(String notiId) async {
    try {
      print('setNotificationRead for notiId: $notiId');
      await Caller.dio.post(
        '/notification/setNotificationRead',
        data: {"noti_id": notiId},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
  }
}
