import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  const ChatRoomPage({
    super.key,
    required this.roomId,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room${widget.roomId}'),
      ),
    );
  }
}
