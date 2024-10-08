import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/caller.dart';

class TokenService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> createUserToken() async {
    final authService = AuthService();
    final currentUserID = authService.getCurrentUser()!.uid;

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
  
}