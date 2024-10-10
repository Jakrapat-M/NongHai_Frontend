import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nonghai/services/noti/token_service.dart';

class AuthService {
  // instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get user
  User? getCurrentUser() => _firebaseAuth.currentUser;

  //sign in user
  Future<UserCredential> signInWithEmailandPassword(String email, String password) async {
    try {
      //sign in
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      //add a new document for the user in users collection if it doens not already exist
      _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'uid': userCredential.user!.uid, 'email': email}, SetOptions(merge: true));

      //create a device token for the user
      TokenService().createUserToken();

      return userCredential;
    }
    // catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //create new user
  Future<UserCredential> signUpWithEmailandPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      //after creating the user, create a new document for the user in the users collection
      _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'uid': userCredential.user!.uid, 'email': email});

      TokenService().createUserToken();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign user out
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}
