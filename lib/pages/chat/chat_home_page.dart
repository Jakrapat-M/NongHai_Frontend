import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/components/user_tile.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/services/chat/chat_service.dart';
import 'package:nonghai/types/chat_room_data.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  // chat & auth services
  final chatService = ChatService();

  final authService = AuthService();

  final currentUserId = AuthService().getCurrentUser()!.uid;
  final currentEmail = AuthService().getCurrentUser()!.email;

  getChatRoom() async {
    try {
      final resp =
          await Caller.dio.get('/chat/getChatRoom?userId=${authService.getCurrentUser()!.uid}');
      if (resp.statusCode == 200) {
        return resp.data['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("current user: $currentEmail");
      print("current user id: $currentUserId");
    }
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Chat',
        noBackButton: true,
      ),
      body: SafeArea(child: _buildChatRoomList()),
    );
  }

  Widget _buildChatRoomList() {
    return FutureBuilder(
      future: getChatRoom(),
      builder: (context, chatRoomSnapshot) {
        if (chatRoomSnapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (chatRoomSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatRoomSnapshot.data == null) {
          return const Center(child: Text('No chat room found'));
        }

        final chatRoomData = chatRoomSnapshot.data as List<dynamic>;

        // Create a map of user_id to updated_at for sorting
        final Map<String, DateTime> chatRoomUserUpdatedAtMap = {};
        for (var room in chatRoomData) {
          // convert it to DateTime
          DateTime updatedAt = DateTime.parse(room['updated_at']);
          chatRoomUserUpdatedAtMap[room['user_id_1']] = updatedAt;
          chatRoomUserUpdatedAtMap[room['user_id_2']] = updatedAt;
        }

        // Combine both user_id_1 and user_id_2 into one set
        final chatRoomUserIds = chatRoomUserUpdatedAtMap.keys.toSet();
        return StreamBuilder(
          stream: chatService.getUsersStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter the list of users
            List<Map<String, dynamic>> usersList = snapshot.data!;

            // Filter users based on chat room data
            List<Map<String, dynamic>> filteredUsersList = usersList.where((user) {
              return chatRoomUserIds.contains(user["uid"]);
            }).toList();

            // Sort filteredUsersList based on the 'updated_at' field
            filteredUsersList.sort((a, b) {
              DateTime aUpdatedAt = chatRoomUserUpdatedAtMap[a["uid"]]!;
              DateTime bUpdatedAt = chatRoomUserUpdatedAtMap[b["uid"]]!;
              return bUpdatedAt.compareTo(aUpdatedAt); // Sort in descending order
            });

            final chatData =
                chatRoomData.map<ChatRoomData>((e) => ChatRoomData.fromJson(e)).toList();

            return ListView(
              children: filteredUsersList
                  .map<Widget>((userData) => _buildUserListItem(userData, chatData, context))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, List<ChatRoomData> chatData, BuildContext context) {
    // Find the relevant chat room for this user

    if (userData["email"] != authService.getCurrentUser()!.email) {
      return UserTile(
        receiverID: userData["uid"],
      );
    } else {
      return const SizedBox();
    }
  }
}
