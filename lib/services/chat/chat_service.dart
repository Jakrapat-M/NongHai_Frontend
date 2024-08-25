import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nonghai/models/message.dart';

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

// send message
  Future<void> sendMessage(String receiverID, message) async {
    // get current user
    final currentUserID = _auth.currentUser!.uid;
    final currentUserEmail = _auth.currentUser!.email!;
    final timestamp = Timestamp.now();

    // create new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // Construct chat room id
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');
    // add message to database
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
}
