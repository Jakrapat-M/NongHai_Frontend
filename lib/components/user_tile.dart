import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/chat/chat_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserTile extends StatelessWidget {
  final String userLabel;
  final String receiverID;
  final void Function()? onTap;
  const UserTile(
      {super.key, required this.userLabel, required this.onTap, required this.receiverID});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final authService = AuthService();

    final senderID = authService.getCurrentUser()!.uid;
    final getLastMessage = chatService.getLastMessage(senderID, receiverID);

    return StreamBuilder(
        stream: getLastMessage,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return _buildUserTile(context, "", "", true);
          }

          DocumentSnapshot latestDocument = snapshot.data!.docs[0];
          Map<String, dynamic> data = latestDocument.data() as Map<String, dynamic>;

          DateTime dateTime = data["timestamp"].toDate();
          String timeSince = timeago.format(dateTime);

          return _buildUserTile(context, data["message"], timeSince, false);
        });
  }

  Widget _buildUserTile(BuildContext context, String lastMessage, time, isRead) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(90),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.fromLTRB(6, 6, 32, 6),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              radius: 30,
              backgroundImage: const AssetImage("assets/images/default_profile.png"),
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userLabel,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                ),
                const SizedBox(height: 4.0),
                Text(
                  lastMessage,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),

            const Spacer(),
            // add time and status
            Text(time,
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
            const SizedBox(width: 8.0),
            Icon(
              Icons.circle,
              color: isRead ? Colors.grey[200] : Colors.pink[200],
              size: 10,
            ),
          ],
        ),
      ),
    );
  }
}
