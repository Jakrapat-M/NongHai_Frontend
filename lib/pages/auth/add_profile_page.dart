import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  XFile? _image;
  Map<String, dynamic>? userData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the userData passed from the RegisterPage
    userData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  Future<void> _pickImage() async {
    // Request storage permission
    var status = await Permission.storage.request();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? selectedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        setState(() {
          _image = selectedImage;
        });
      }
    } else {
      // Handle the case when permission is denied
      print('Storage permission denied');
    }
  }

  void _next() {
    // Update userData with the selected image if available
    if (_image != null) {
      userData!['image'] = _image!.path; // Update the image path in userData
      print(userData);
      // Navigate to the Add Contact page and pass the userData
      Navigator.pushNamed(context, '/addContact', arguments: userData);
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
    Navigator.pushNamed(context, '/addContact', arguments: userData);
  }

  @override
  Widget build(BuildContext context) {
    print(userData);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Profile",
            style: Theme.of(context).bannerTheme.contentTextStyle),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  _image != null ? FileImage(File(_image!.path)) : null,
              child: _image == null ? Icon(Icons.add_a_photo, size: 40) : null,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Text(
                _image == null ? 'Add profile' : 'Change profile',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _next,
              child: Text('Next'),
            ),
            ElevatedButton(
              onPressed: _skip,
              child: Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
