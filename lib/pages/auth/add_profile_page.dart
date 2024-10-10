// ignore_for_file: avoid_print, library_prefixes, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as Path; // For getting the filename
import 'package:permission_handler/permission_handler.dart';

class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  XFile? _image;
  Map<String, dynamic>? userData;
  // final bool _isUploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the userData passed from the RegisterPage
    userData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  Future<void> _pickImage() async {
    // Request storage permission
    var status = await Permission.storage.request();

    if (status.isGranted) {
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
              // Set a fixed height if needed
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the buttons horizontally
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
                      const SizedBox(width: 20), // Add space between buttons
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
    } else {
      _showMessage('Storage permission denied');
    }
  }

  // Future<void> _uploadImage(File imageFile) async {
  //   setState(() {
  //     _isUploading = true;
  //   });
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse(
  //           'https://your-server-url.com/upload'), // Replace with your server URL
  //     );

  //     request.files.add(await http.MultipartFile.fromPath(
  //       'image',
  //       imageFile.path,
  //       filename: Path.basename(imageFile.path),
  //     ));

  //     var response = await request.send();

  //     if (response.statusCode == 200) {
  //       _showMessage('Image uploaded successfully');
  //     } else {
  //       _showMessage('Failed to upload image. Please try again.');
  //     }
  //   } catch (e) {
  //     _showMessage('Error uploading image: $e');
  //   } finally {
  //     setState(() {
  //       _isUploading = false;
  //     });
  //   }
  // }

  void _next() {
    if (_image != null) {
      userData?['image'] = _image!.path; // Update the image path in userData
      Navigator.pushNamed(context, '/addContact',
          arguments: userData); // No casting needed
    } else {
      _showImageRequiredDialog();
    }
  }

  void _skip() {
    Navigator.pushNamed(context, '/addContact',
        arguments: userData); // No casting needed
  }

  void _showImageRequiredDialog() {
    showDialog(
      context: context, // No casting needed
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      // No casting needed
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProfileImage(),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Text(
                _image == null ? 'Add profile' : 'Change profile',
                style: const TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            // _isUploading
            //     ? const CircularProgressIndicator()
            //     : ElevatedButton(
            ElevatedButton(
              onPressed: _next,
              child: const Text('Next'),
            ),
            ElevatedButton(
              onPressed: _skip,
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 60,
      backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
      child: _image == null
          ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
          : null,
    );
  }
}
