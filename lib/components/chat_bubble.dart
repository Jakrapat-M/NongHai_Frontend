import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final Timestamp timestamp;
  final bool isSender;

  const ChatBubble(
      {super.key, required this.message, required this.isSender, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65, // Set max width to 75% of screen width
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSender
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isSender ? const Radius.circular(20) : const Radius.circular(20),
          bottomRight: isSender ? const Radius.circular(20) : const Radius.circular(20),
        ),
      ),
      child: Text(message,
          style: TextStyle(
            color: isSender ? Theme.of(context).colorScheme.tertiary : Colors.black,
          )),
    );
  }
}
