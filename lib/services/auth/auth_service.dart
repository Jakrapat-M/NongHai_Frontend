// ignore_for_file: use_build_context_synchronously, avoid_print

// import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nonghai/services/noti/token_service.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/services/auth/login_or_registoer.dart';
import 'package:nonghai/services/caller.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() => _firebaseAuth.currentUser;

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Sign in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //add a new document for the user in users collection if it doens not already exist
      _firestore.collection('users').doc(userCredential.user!.uid).set(
          {'uid': userCredential.user!.uid, 'email': email},
          SetOptions(merge: true));

      //create a device token for the user
      TokenService().createUserToken(userCredential.user!.uid);

      return true; // Return true on success
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthException cases
      if (e.code == 'user-not-found') {
        return false; // No user found
      } else if (e.code == 'wrong-password') {
        return false; // Incorrect password
      } else {
        return false; // Other errors
      }
    } catch (e) {
      // Handle other errors
      return false; // General failure
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'uid': userCredential.user!.uid, 'email': email});

      TokenService().createUserToken(userCredential.user!.uid);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    //delete the device token for the user
    TokenService().removeUserToken(_firebaseAuth.currentUser!.uid);
    return await _firebaseAuth.signOut();
  }

  // Change to public method
  Future<void> signInWithCustomToken(BuildContext context) async {
    String? uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      _showMessage('No user is currently signed in.');
      return;
    }

    try {
      String customToken = await fetchCustomToken(uid);
      await _firebaseAuth.signInWithCustomToken(customToken);
      print("re-signin success");
      // Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print("error: $e");
      _showMessage('Sign-in failed: ${e.toString()}');
    }
  }

  Future<String> fetchCustomToken(String uid) async {
    try {
      final response = await Caller.dio
          .post("/user/$uid/token"); // Adjust the request type if necessary

      // Print the response data for debugging
      print('Response data: ${response.data}');
      print(response.statusCode);

      // Check if the response is successful
      if (response.statusCode == 200) {
        // If response.data is a Map, directly access the customToken
        if (response.data is Map<String, dynamic>) {
          final customToken =
              response.data['customToken']; // Access the customToken

          if (customToken is String) {
            print(customToken);
            return customToken; // Return the customToken as a String
          } else {
            throw Exception('Custom token is not a String.');
          }
        } else {
          throw Exception('Unexpected response format. Expected a Map.');
        }
      } else {
        throw Exception(
            'Failed to load custom token, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching custom token: ${e.toString()}');
    }
  }

  void _showMessage(String message) {
    print(
        message); // Example, consider using SnackBar or AlertDialog for better UX
  }

  Future<void> deleteUser(BuildContext context) async {
    User? user = _firebaseAuth.currentUser;

    if (user == null) {
      _showErrorDialog(context, 'No user is currently signed in.');
      return;
    }

    // Prompt the user for their password
    // print("ppp");
    String password = await _promptForPassword(context);
    // print("ooo");
    if (password.isEmpty) {
      _showErrorDialog(context, 'Password cannot be empty.');
      return;
    }
    // print('iii');

    try {
      // Re-authenticate with the provided password
      final credential =
          EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);

      // Delete the user from FirebaseAuth and Firestore
      await user.delete();
      await _firestore.collection('users').doc(user.uid).delete();

      // After deletion, navigate to the register page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const LoginOrRegistoer()), // Replace with your RegisterPage
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // Show a specific error based on FirebaseAuthException codes
      switch (e.code) {
        case 'requires-recent-login':
          _showErrorDialog(
              context, 'Please sign in again to delete your account.');
          break;
        case 'user-not-found':
          _showErrorDialog(context, 'User not found. Please sign in again.');
          break;
        default:
          _showErrorDialog(context,
              'An error occurred: Please check if your password is correct.');
          break;
      }
    } catch (e) {
      // General error handling
      _showErrorDialog(context, 'An unexpected error occurred: $e');
    }
  }

// Mockup of a function to prompt for a password
  Future<String> _promptForPassword(BuildContext context) async {
    return await showDialog<String>(
          context: context,
          builder: (context) {
            TextEditingController passwordController = TextEditingController();
            return AlertDialog(
              title: Text(
                'Register failed',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: const Color(0xff333333)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please enter password and register again.',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary), // Border color when not focused
                      ),
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffC8A48A)),
                  onPressed: () {
                    Navigator.of(context).pop(passwordController.text);
                  },
                  child: const Row(
                    children: [
                      Spacer(),
                      Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xffFFFFFF),
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w500),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ],
            );
          },
        ) ??
        '';
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: const Color(0xff333333)),
          ),
          content: Text(
            message,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary),
              child: const Row(
                children: [
                  Spacer(),
                  Text(
                    'OK',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xffFFFFFF),
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
