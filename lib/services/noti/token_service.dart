import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/caller.dart';

class TokenService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> createUserToken(String? uid) async {
    debugPrint('Creating token for user: $uid');

    if (uid == null) {
      final authService = AuthService();
      uid = authService.getCurrentUser()!.uid;
    }

    final token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('Device Token: $token');
    }
    try {
      // Create a user token in the backend
      final resp =
          await Caller.dio.post('/token/createUserToken', data: {"user_id": uid, "token": token});
      if (resp.statusCode == 200 && resp.data['data'] == "Token already exist") {
        debugPrint('Token already exist');
      } else if (resp.statusCode == 200) {
        debugPrint('Token created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
  }

  Future<void> removeUserToken(String? uid) async {
    if (uid == null) {
      final authService = AuthService();
      uid = authService.getCurrentUser()!.uid;
    }

    final token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('Deleting token for user: $uid Token: $token');
    }
    try {
      // Delete a user token in the backend
      final resp =
          await Caller.dio.delete('/token/removeUserToken', data: {"user_id": uid, "token": token});
      if (resp.statusCode == 200) {
        debugPrint('Token deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
  }
}
