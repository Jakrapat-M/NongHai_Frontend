import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nonghai/models/message.dart';
import 'package:nonghai/services/caller.dart';

class ChatService {
// get instance of firestore

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

// get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // get chat room stream
  Stream<List<Map<String, dynamic>>> getChatRoomStream() {
    return _firestore
        .collection('chat_rooms')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

// send message
  Future<void> sendMessage(String receiverID, message) async {
    // get current user
    final currentUserID = _auth.currentUser!.uid;
    final timestamp = Timestamp.now();

    // create new message
    Message newMessage = Message(
      senderID: currentUserID,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // Construct chat room id
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // add message to firestore
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

// get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // Construct chat room id
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // get last message
  Stream<QuerySnapshot> getLastMessage(String userID, otherUserID) {
    // Construct chat room id
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  // create chat room in database
  Future<void> createChatRoom(String receiverID) async {
    // get current user
    final currentUserID = _auth.currentUser!.uid;

    // Construct chat room id
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // create chat room
    try {
      final resp = await Caller.dio.post(
        '/chat/createChatRoom',
        data: {
          'chat_id': chatRoomID,
          'user_id_1': currentUserID,
          'user_id_2': receiverID,
        },
      );
    } catch (e) {
      print('Error creating chat room: $e');
    }
  }
}
