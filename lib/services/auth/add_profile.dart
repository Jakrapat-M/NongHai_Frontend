import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreProfile {
  Future<String> uploadProfileToStorage(
      String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData(
      {required String userId,
      required Uint8List file,
      required String folderPath}) async {
    // Your existing logic for uploading the file
    // This could involve using Firebase Storage, for example:

    // Create a reference to the storage bucket
    final storageRef = FirebaseStorage.instance.ref();

    // Create a reference to the location where the image will be saved
    final imageRef = storageRef.child(folderPath);

    // Upload the file
    await imageRef.putData(file);

    // Get the download URL
    String downloadUrl = await imageRef.getDownloadURL();

    return downloadUrl; // Return the URL of the uploaded image
  }

  Future<String> updateProfileImage(String userId, Uint8List file) async {
    String resp = "Some error occurred";
    try {
      String imgUrl = await uploadProfileToStorage('profileImage', file);
      await _firestore
          .collection('userProfile')
          .doc(userId)
          .update({'image': imgUrl});
      resp = imgUrl;
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}
