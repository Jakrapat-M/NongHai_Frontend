import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/components/notification_tile.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/caller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final authService = AuthService();
  final currentUserId = AuthService().getCurrentUser()!.uid;
  List<dynamic>? notifications;

  getNotification() async {
    try {
      final resp = await Caller.dio.get(
        '/notification/getNotificationObject',
        data: {"user_id": currentUserId},
      );
      if (resp.statusCode == 200) {
        setState(() {
          notifications = resp.data['data'];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Notification', noBackButton: true),
      body: SafeArea(child: _buildNotificationList()),
    );
  }

  Widget _buildNotificationList() {
    if (notifications == null) {
      return Center(child: SpinKitFadingCube(color: Theme.of(context).colorScheme.primary));
    }

    if (notifications!.isEmpty) {
      return const Center(child: Text('No notifications available.'));
    }

    return ListView.builder(
      itemCount: notifications!.length,
      itemBuilder: (context, index) {
        final notification = notifications![index];
        return NotificationTile(
          userId: notification['user_id'],
          petId: notification['pet_id'],
          trackingId: notification['tracking_id'],
          isRead: notification['is_read'],
        );
      },
    );
  }
}
