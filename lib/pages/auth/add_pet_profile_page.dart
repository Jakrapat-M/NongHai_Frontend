// ignore_for_file: avoid_print, unnecessary_null_comparison, prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nonghai/components/custom_button.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AddPetProfilePage extends StatefulWidget {
  const AddPetProfilePage({super.key});

  @override
  State<AddPetProfilePage> createState() => _AddPetProfilePageState();
}

class _AddPetProfilePageState extends State<AddPetProfilePage> {
  XFile? _image;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? petData = {
    "user_id": "",
    "name": "N/A",
    "animal_type": "",
    "breed": "N/A",
    "date_of_birth": "",
    "sex": "",
    "weight": 0,
    "hair_color": "N/A",
    "blood_type": "N/A",
    "eyes": "",
    "status": "Safe", // default
    "note": "",
    "image": ""
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if arguments are available
    // final args = ModalRoute.of(context)?.settings.arguments;

    // if (args is String) {
    //   // Assign userId from arguments if it's a non-null String
    //   petData!['user_id'] = args;
    // } else {
    //   // If arguments are null, get the uid from Firebase

    if (uid != null) {
      petData!['user_id'] = uid; // Assign Firebase UID if it's not null
    } else {
      print('Error: No user ID available from arguments or Firebase.');
    }
    // }
  }

  Future<void> _pickImage() async {
    // Check storage permission status first
    var status = await Permission.storage.status;
    var cameraStatus = await Permission.camera.request();
    if (status.isDenied) {
      // If the permission is denied, request permission
      status = await Permission.storage.request();
    } else if (cameraStatus.isDenied) {
      cameraStatus = await Permission.camera.request();
    }

    if (status.isGranted && cameraStatus.isGranted) {
      // Show dialog to choose image source
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Select Image Source',
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        child: const Text('Camera'),
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close the dialog
                          final ImagePicker picker = ImagePicker();
                          final XFile? selectedImage = await picker.pickImage(
                              source: ImageSource.camera);
                          if (selectedImage != null) {
                            setState(() {
                              _image = selectedImage;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        child: const Text('Gallery'),
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close the dialog
                          final ImagePicker picker = ImagePicker();
                          final XFile? selectedImage = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (selectedImage != null) {
                            setState(() {
                              _image = selectedImage;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (status.isPermanentlyDenied) {
      // If permission is permanently denied, you can prompt the user to go to settings
      _showMessage(
          'Storage permission is permanently denied. Please enable it in app settings.');
    } else {
      _showMessage('Storage permission denied');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      // No casting needed
      SnackBar(content: Text(message)),
    );
  }

  void _next() {
    // Update userData with the selected image if available
    if (_image != null) {
      petData!['image'] = _image!.path; // Update the image path in userData
      print(petData);
      // Navigate to the Add Contact page and pass the userData
      Navigator.pushNamed(context, '/addPetInfo', arguments: petData);
    } else {
      // Show an AlertDialog when no image is selected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Image Selected'),
            content: Text('Please select a profile image before proceeding.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _skip() {
    // Navigate to the Add Contact page and pass the userData
    Navigator.pushNamed(context, '/addPetInfo', arguments: petData);
  }

  @override
  Widget build(BuildContext context) {
    print(petData);
    return Scaffold(
      appBar: AppBar(
        title: Text("Pet Profile",
            style: Theme.of(context).bannerTheme.contentTextStyle),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 150,
                backgroundColor: const Color(0xffd9d9d9),
                backgroundImage:
                    _image != null ? FileImage(File(_image!.path)) : null,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Text(
                  _image == null ? 'Add profile' : 'Change profile',
                  style: const TextStyle(
                      color: Color(0xff57677C),
                      fontSize: 16,
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.w400),
                ),
              ),
              // SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.fromLTRB(80, 20, 80, 5),
                child: CustomButton1(
                  text: "Next",
                  onTap: () => _next(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(80, 0, 80, 8),
                child: TextButton(
                  onPressed: () => _skip(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        175, 224, 223, 223), // Background color
                    padding:
                        const EdgeInsets.symmetric(horizontal: 100), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          50), // Optional: Adjust radius for rounded corners
                    ),
                  ),
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Color(0xffC8A48A),
                      fontFamily: "Fredoka",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
