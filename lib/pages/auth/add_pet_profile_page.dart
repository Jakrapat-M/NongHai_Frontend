// ignore_for_file: avoid_print, unnecessary_null_comparison, prefer_const_constructors, use_build_context_synchronously

// import 'package:file_picker/file_picker.dart';
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

  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Select Image Source',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: const Color(0xff333333))),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffC8A48A)),
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Check and request camera permission
                  var cameraStatus = await Permission.camera.status;
                  if (!cameraStatus.isGranted) {
                    cameraStatus = await Permission.camera.request();
                  }

                  if (cameraStatus.isGranted) {
                    final ImagePicker picker = ImagePicker();
                    final XFile? selectedImage = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (selectedImage != null) {
                      setState(() {
                        _image = selectedImage;
                      });
                    }
                  } else {
                    _showMessage(
                      'Camera permission denied. Please allow permission in settings.',
                    );
                  }
                },
                child: const Text(
                  'Camera',
                  style: TextStyle(
                      fontSize: 20,
                      color: Color(0xffFFFFFF),
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffC8A48A)),
                child: const Text(
                  'Gallery',
                  style: TextStyle(
                      fontSize: 20,
                      color: Color(0xffFFFFFF),
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w500),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final XFile? result = await _picker.pickImage(source: ImageSource.gallery);
                  if (result != null) {
                    setState(() {
                      _image = result;
                    });
                  } else {
                    _showMessage('No file selected.');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'No Image Selected',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: const Color(0xff333333)),
            ),
            content: Text(
              'Please select a profile image before proceeding.',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                child: Row(
                  children: const [
                    Spacer(),
                    Text(
                      'OK',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xffFFFFFF),
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w500),
                    ),
                    Spacer()
                  ],
                ),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Pet Profile", style: Theme.of(context).bannerTheme.contentTextStyle),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 150,
                backgroundColor: const Color(0xffd9d9d9),
                backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
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
                    backgroundColor: const Color.fromARGB(175, 224, 223, 223), // Background color
                    // padding:
                    //     const EdgeInsets.symmetric(horizontal: 100), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(50), // Optional: Adjust radius for rounded corners
                    ),
                  ),
                  child: Row(
                    children: const [
                      Spacer(),
                      Text(
                        "Skip",
                        style: TextStyle(
                          color: Color(0xffC8A48A),
                          fontFamily: "Fredoka",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Spacer(),
                    ],
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
