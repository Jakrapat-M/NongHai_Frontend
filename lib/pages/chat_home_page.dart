import 'package:flutter/material.dart';
import 'package:nonghai/pages/chat_room_page.dart';

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: const Text("Chat"),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Center(
                child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Chat Room 1'),
                  subtitle: const Text('Chat Room 1 description'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const ChatRoomPage(roomId: '1')));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Chat Room 2'),
                  subtitle: const Text('Chat Room 2 description'),
                  onTap: () {
                    Navigator.pushNamed(context, '/chat-room');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Chat Room 3'),
                  subtitle: const Text('Chat Room 3 description'),
                  onTap: () {
                    Navigator.pushNamed(context, '/chat-room');
                  },
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
