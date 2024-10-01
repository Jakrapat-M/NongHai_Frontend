import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth/auth_service.dart';
import '../../services/caller.dart';

class AddPetProfilePage extends StatefulWidget {
  // final void Function()? onTap;
  const AddPetProfilePage({super.key});

  @override
  State<AddPetProfilePage> createState() => _AddPetProfilePageState();
}

class _AddPetProfilePageState extends State<AddPetProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl; // URL of the selected image

  Map<String, dynamic>? userData; // Store user data

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the userData passed from the RegisterPage
    userData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.getImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageUrl = pickedFile.path; // Store the image path
  //     });
  //   }
  // }

  void signUp(BuildContext context) async {
    final authService = AuthService();
    try {
      // Sign up with Firebase
      UserCredential userCredential =
          await authService.signUpWithEmailandPassword(
              userData!['email'], userData!['password']);

      // Get the Firebase User's UID
      String uid = userCredential.user!.uid;

      // Call the createUser API
      final response = await Caller.dio.post(
        ("/user/createUser"), // Adjust to your API URL
        data: userData,
      );

      // Check if API call was successful
      if (response.statusCode == 201) {
        print('resp: ${response.data}');
        Navigator.pushNamed(context, '/home');
      } else {
        // Handle error from API
        if (mounted) {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('API Error'),
                    content: Text(response.data),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ));
        }
      }
    } catch (e) {
      // Handle Firebase sign-up error
      print('Error occurred: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
