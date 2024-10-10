import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/chat_bubble.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/services/chat/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nonghai/services/noti/show_or_hide_noti.dart';
import 'package:nonghai/types/user_data.dart';

class ChatRoomPage extends StatefulWidget {
  final String receiverID;
  final String? receiverName;
  final bool? isNew;

  const ChatRoomPage({
    super.key,
    required this.receiverID,
    this.receiverName,
    bool? isNew,
  }) : isNew = isNew ?? false;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  UserData? userData;
  // controller
  final _messageController = TextEditingController();

  // chat & auth services
  final _chatService = ChatService();
  final _authService = AuthService();

  final _focusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();

  checkChatRoom() {
    // Check if the chat room exists
    ShowOrHideNoti().setChatingWith(widget.receiverID);
  }

  getuserData() async {
    print('Fetching Name');
    try {
      final response = await Caller.dio.get(
        "/user/${widget.receiverID}",
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = UserData.fromJson(response.data['data']);
        });
        return UserData.fromJson(response.data['data']);
      }
      return 'Error Fetching Name';
    } catch (e) {
      return 'Error Fetching Name';
    }
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
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();
      scrollDown();
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        // Upload image to Firebase Storage and send message
        await _chatService.sendImageMessage(widget.receiverID, imageFile);
        scrollDown();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _captureAndSendImage() async {
    final XFile? capturedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (capturedFile != null) {
      File imageFile = File(capturedFile.path);
      // Upload image to Firebase Storage and send message
      await _chatService.sendImageMessage(widget.receiverID, imageFile);
      scrollDown();
    }
  }

  @override
  void initState() {
    super.initState();
    checkChatRoom();
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

    // Fetch and set the username
    if (widget.receiverName == null) {
      getuserData();
    }

    if (widget.isNew!) {
      _chatService.createChatRoom(widget.receiverID);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.getCurrentUser()!.uid;
    if (widget.receiverName == currentUserId) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'THIS IS YOU'),
        body: Center(
          child: Text('You cannot chat with yourself'),
        ),
      );
    }

    String receiverName = userData?.name ?? '';
    return Scaffold(
      appBar: CustomAppBar(title: receiverName),
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
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc))
              .toList()
              .reversed
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Check if the message belongs to the current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    // Align message to the right if it's from the current user
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: data["imageUrl"] != null
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  data["imageUrl"],
                  height: MediaQuery.of(context).size.width * 0.50,
                  fit: BoxFit.fitHeight,
                ),
              ),
            )
          : ChatBubble(
              message: data["message"],
              isSender: isCurrentUser,
              timestamp: data["timestamp"],
            ),
    );
  }

  // build message input
  Widget _buildMessageInput(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.width * 0.30,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        color: Theme.of(context).colorScheme.tertiary,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.camera_alt,
                color: Theme.of(context).colorScheme.primary),
            onPressed:
                _captureAndSendImage, // Call the method to capture an image using the camera
          ),
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
            icon:
                Icon(Icons.image, color: Theme.of(context).colorScheme.primary),
            onPressed:
                _pickAndSendImage, // Call the method to pick an image from the gallery
          ),
          IconButton(
            icon:
                Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}
