// ignore_for_file: avoid_print, library_prefixes, use_build_context_synchronously
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nonghai/components/custom_button.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  XFile? _image;
  Map<String, dynamic>? userData;
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  @override
  void initState() {
    super.initState();

    // Close any open dialogs automatically when AddProfilePage is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the userData passed from the RegisterPage
    userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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

  void _next() {
    if (_image != null) {
      userData?['image'] = _image!.path;
      if (mounted) {
        Navigator.pushNamed(context, '/addContact', arguments: userData);
      }
    } else {
      _showImageRequiredDialog();
    }
  }

  void _skip() {
    if (mounted) {
      Navigator.pushNamed(context, '/addContact', arguments: userData);
    }
  }

  void _showImageRequiredDialog() {
    if (mounted) {
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f2),
        title: const Text('Your Profile'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileImage(),
              const SizedBox(height: 16),
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
              // const SizedBox(height: 30),
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
                  child: const Row(
                    children: [
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

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 150,
      backgroundColor: const Color(0xffd9d9d9),
      backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
      // child: _image == null
      //     ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
      //     : null,
    );
  }
}
