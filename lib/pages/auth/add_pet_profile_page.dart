import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    "note": "",
    "image": ""
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if arguments are available
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String) {
      // Assign userId from arguments if it's a non-null String
      petData!['user_id'] = args;
    } else {
      // If arguments are null, get the uid from Firebase

      if (uid != null) {
        petData!['user_id'] = uid; // Assign Firebase UID if it's not null
      } else {
        print('Error: No user ID available from arguments or Firebase.');
      }
    }
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
