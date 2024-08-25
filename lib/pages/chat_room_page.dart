import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_text_field.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/chat/chat_service.dart';

class ChatRoomPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;

  ChatRoomPage({super.key, required this.receiverEmail, required this.receiverID});

  // controller
  final _messageController = TextEditingController();

  // chat & auth services
  final _chatService = ChatService();
  final _authService = AuthService();

  // send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(receiverID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverEmail),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: _buildMessageList(),
              ),
              _buildMessageInput(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(senderID, receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Text(data["message"]);
  }

  // build message input
  Widget _buildMessageInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(300),
        color: Theme.of(context).colorScheme.tertiary,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(300),
                  borderSide: BorderSide.none,
                ),
                fillColor: Theme.of(context).colorScheme.tertiary,
                filled: true,
                hintText: "Message...",
              ),
              obscureText: false,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}
