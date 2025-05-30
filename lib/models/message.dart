import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String? imageUrl;

  Message({
    required this.senderID,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.imageUrl,
  });

  // convert to map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
    };
  }
}
