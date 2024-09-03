import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/components/user_tile.dart';
import 'package:nonghai/pages/chat_room_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/services/chat/chat_service.dart';

class ChatHomePage extends StatelessWidget {
  ChatHomePage({super.key});

  // chat & auth services
  final chatService = ChatService();
  final authService = AuthService();

  getChatRoom() async {
    try {
      final resp = await Caller.dio
          .get('/chat/getChatRoom', data: {"user_id": authService.getCurrentUser()!.uid});
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
      print("current user: ${authService.getCurrentUser()!.email}");
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

        final chatRoomData = chatRoomSnapshot.data as List<dynamic>;

        // Combine both user_id_1 and user_id_2 into one set
        final chatRoomUserIds =
            chatRoomData.expand((room) => [room['user_id_1'], room['user_id_2']]).toSet();

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

            return ListView(
              children: filteredUsersList
                  .map<Widget>((userData) => _buildUserListItem(userData, context))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != authService.getCurrentUser()!.email) {
      return UserTile(
          userLabel: userData["email"],
          receiverID: userData["uid"],
          onTap: () {
            // navigate to chat room
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatRoomPage(
                        receiverEmail: userData["email"], receiverID: userData["uid"])));
          });
    } else {
      return const SizedBox();
    }
  }
}
