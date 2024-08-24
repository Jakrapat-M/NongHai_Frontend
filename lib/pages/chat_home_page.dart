import 'package:flutter/material.dart';
import 'package:nonghai/components/user_tile.dart';
import 'package:nonghai/pages/chat_room_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/chat/chat_service.dart';

class ChatHomePage extends StatelessWidget {
  ChatHomePage({super.key});

  // chat & auth services
  final _chatService = ChatService();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: const Text("Chat"),
        ),
      ),
      body: SafeArea(child: _buildChatRoomList()),
    );
  }

  Widget _buildChatRoomList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
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
    return UserTile(
        text: userData["email"],
        onTap: () {
          // navigate to chat room
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatRoomPage(receiverEmail: userData["email"])));
        });
  }
}
