import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/components/user_tile.dart';
import 'package:nonghai/pages/chat_room_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/chat/chat_service.dart';

class ChatHomePage extends StatelessWidget {
  ChatHomePage({super.key});

  // chat & auth services
  final chatService = ChatService();
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Chat',
        noBackButton: true,
      ),
      body: SafeArea(child: _buildChatRoomList()),
    );
  }

  Widget _buildChatRoomList() {
    return StreamBuilder(
      stream: chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
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
