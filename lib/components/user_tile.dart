import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/pages/chat/chat_room_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/services/chat/chat_service.dart';
import 'package:nonghai/types/chat_room_data.dart';
import 'package:nonghai/types/user_data.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'dart:ui'; // Import this for using BackdropFilter

class UserTile extends StatefulWidget {
  final String receiverID;

  const UserTile({
    super.key,
    required this.receiverID,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  UserData? userData;
  String? chatRoomID;
  String? currentUserId;
  final chatService = ChatService();
  final authService = AuthService();

  Future<ChatRoomData?> getChatRoomDataWithDelay(String chatID) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Adjust this delay if necessary
    return getChatRoomData(chatID);
  }

  Future<ChatRoomData?> getChatRoomData(String chatID) async {
    try {
      final resp = await Caller.dio.get('/chat/getCurrentUserChatRoom', data: {"chat_id": chatID});
      if (resp.statusCode == 200) {
        return ChatRoomData.fromJson(resp.data['data']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
    return null;
  }

  void getuserData() async {
    try {
      final response = await Caller.dio.get(
        "/user/${widget.receiverID}",
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = UserData.fromJson(response.data['data']);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    currentUserId = authService.getCurrentUser()!.uid;

    List<String> ids = [currentUserId!, widget.receiverID];
    ids.sort();
    chatRoomID = ids.join('_');

    getuserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final getLastMessage = chatService.getLastMessage(chatRoomID!);

    return StreamBuilder(
      stream: getLastMessage,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a blurred version of the tile during loading
          return _buildBlurredUserTile(context, "", "", true);
        }

        if (snapshot.data!.docs.isEmpty) {
          return _buildUserTile(
            context,
            "",
            "",
            true,
          );
        }

        DocumentSnapshot latestDocument = snapshot.data!.docs[0];
        Map<String, dynamic> data = latestDocument.data() as Map<String, dynamic>;
        DateTime dateTime = data["timestamp"].toDate();
        String timeSince = timeago.format(dateTime);

        return FutureBuilder<ChatRoomData?>(
          future: getChatRoomDataWithDelay(chatRoomID!), // Use delayed fetching
          builder: (context, chatRoomSnapshot) {
            if (chatRoomSnapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (chatRoomSnapshot.connectionState == ConnectionState.waiting) {
              // Show a blurred version of the tile during loading
              return _buildBlurredUserTile(context, data["message"], timeSince, true);
            }

            // Determine `isRead` status from the fetched chat room data
            bool isRead = true; // Default to true
            if (chatRoomSnapshot.hasData) {
              ChatRoomData? chatRoomData = chatRoomSnapshot.data;
              if (chatRoomData != null) {
                if (chatRoomData.userID1 == currentUserId) {
                  isRead = chatRoomData.isUser1Read;
                } else {
                  isRead = chatRoomData.isUser2Read;
                }
              }
            }

            return _buildUserTile(context, data["message"], timeSince, isRead);
          },
        );
      },
    );
  }

  Widget _buildUserTile(
    BuildContext context,
    String lastMessage,
    String time,
    bool isRead,
  ) {
    final userLabel = userData?.name ?? "Unknown User";
    return GestureDetector(
      onTap: () {
        MaterialPageRoute materialPageRoute = MaterialPageRoute(
          builder: (context) => ChatRoomPage(
            receiverID: widget.receiverID,
          ),
        );
        // navigate to chat room
        Navigator.of(context)
            .push(
          materialPageRoute,
        )
            .then((value) {
          // Refresh the chat room list
          setState(() {
            // mark chat as read where navigate back from chat room
            Caller.dio.post(
              '/chat/setRead',
              data: {
                'chat_id': chatRoomID,
                'sender_id': currentUserId,
              },
            );
            //refresh chat room list
          });
        });
      },
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
            Expanded(
              child: Column(
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              time,
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
            ),
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

  // Create a blurred version of the user tile
  Widget _buildBlurredUserTile(
    BuildContext context,
    String lastMessage,
    String time,
    bool isRead,
  ) {
    return Stack(
      children: [
        // The original user tile widget
        _buildUserTile(context, lastMessage, time, isRead),
        // Positioned to overlay the original tile with a blur effect
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(90), // Apply the border radius to the blur effect
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0), // Apply blur effect
              child: Container(
                color: Colors.transparent, // Slightly darken the blur overlay
              ),
            ),
          ),
        ),
      ],
    );
  }
}
