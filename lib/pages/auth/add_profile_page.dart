// ignore_for_file: avoid_print, library_prefixes, use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
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
    userData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  Future<void> _pickImage() async {
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
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      child: const Text('Gallery'),
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // Check and request storage/gallery permission
                        var galleryStatus = await Permission.storage.status;
                        if (!galleryStatus.isGranted) {
                          galleryStatus = await Permission.storage.request();
                        }

                        if (galleryStatus.isGranted) {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                          );

                          if (result != null && result.files.isNotEmpty) {
                            String path = result.files.single.path!;
                            setState(() {
                              _image = XFile(path);
                            });
                          } else {
                            _showMessage('No file selected.');
                          }
                        } else {
                          _showMessage(
                            'Storage permission denied. Please allow permission in settings.',
                          );
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
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('No Image Selected'),
            content:
                const Text('Please select a profile image before proceeding.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(dialogContext).pop(),
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
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f2),
        title: const Text('Your Profile'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
