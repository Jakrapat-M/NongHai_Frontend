import 'package:flutter/material.dart';

class ChatRoomPage extends StatelessWidget {
  final String receiverEmail;
  const ChatRoomPage({super.key, required this.receiverEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverEmail),
      ),
      body: const Center(
        child: Text("Chat Room"),
      ),
    );
  }
}