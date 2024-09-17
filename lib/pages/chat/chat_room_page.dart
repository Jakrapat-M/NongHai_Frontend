import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/chat_bubble.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/chat/chat_service.dart';

class ChatRoomPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  ChatRoomPage({super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  // controller
  final _messageController = TextEditingController();

  // chat & auth services
  final _chatService = ChatService();
  final _authService = AuthService();

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 1000),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 100),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // scroll comtroller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverID, _messageController.text);
      _messageController.clear();
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.receiverEmail),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMessageList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildMessageInput(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(senderID, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          reverse: true,
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList().reversed.toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    // align message to right
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
        alignment: alignment,
        child: ChatBubble(
          message: data["message"],
          isSender: isCurrentUser,
          timestamp: data["timestamp"],
        ));
  }

  // build message input
  Widget _buildMessageInput(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.width * 0.30, // Set max width to 75% of screen width
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        color: Theme.of(context).colorScheme.tertiary,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              autofocus: false,
              focusNode: _focusNode,
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