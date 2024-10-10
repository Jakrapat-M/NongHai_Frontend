// ignore_for_file: avoid_print, unnecessary_null_comparison, use_build_context_synchronously, non_constant_identifier_names

import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nonghai/services/auth/add_profile.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../services/auth/auth_service.dart';
import '../../services/caller.dart';

class AddContactPage extends StatefulWidget {
  // final void Function()? onTap;
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  String? _phoneNumber;
  Map<String, dynamic>? userData;
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final addrController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the userData passed from the RegisterPage
    userData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  Future<void> _createUser(BuildContext context) async {
    if (_phoneNumber != null &&
        nameController.text.isNotEmpty &&
        surnameController.text.isNotEmpty &&
        addrController.text.isNotEmpty) {
      userData!['phone'] = _phoneNumber!.toString();
      userData!['name'] = nameController.text;
      userData!['surname'] = surnameController.text;
      userData!['address'] = addrController.text;

      print(userData);

      final authService = AuthService();
      try {
        // Sign up with Firebase
        UserCredential userCredential =
            await authService.signUpWithEmailandPassword(
                userData!['email'], userData!['password']);

        // Get the Firebase User's UID
        String uid = userCredential.user!.uid;

        // Update userData to include the UID and remove the password
        userData!['id'] = uid;
        userData!.remove('password');

        // Call SaveProfile and wait for the updated userData
        userData = await SaveProfile(); // Update userData with image URL

        // Call the createUser API with updated userData
        final response = await Caller.dio.post(
          "/user/createUser",
          data: userData,
        );

        // Check if API call was successful
        if (response.statusCode == 201) {
          print('resp: ${response.data}');
          Navigator.pushNamed(context, '/addPetProfileImage', arguments: uid);
        } else {
          // Handle error from API
          if (mounted) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('API Error'),
                      content: Text(response.data.toString()),
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
    } else {
      _showAlertDialog();
    }
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('The field cannot be empty.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> SaveProfile() async {
    if (userData?['image'] != null) {
      // Get the image file path
      String imagePath = userData!['image'];
      String userId = userData!['id'];

      // Convert the image file to Uint8List for uploading
      Uint8List imageFile = await File(imagePath).readAsBytes();

      // Define the path for the image upload
      String folderPath = 'profileImage/$userId.jpg'; // Save as userId.jpg

      // Save the profile image and pass the userId and folderPath
      String imgUrl = await StoreProfile()
          .saveData(userId: userId, file: imageFile, folderPath: folderPath);

      // Set userData['image'] with the URL
      userData!['image'] = imgUrl;

      // Handle the response as needed
      print('Uploaded image URL: $imgUrl');
      print(userData!['image']);
      return userData!; // Return the updated userData
    } else {
      _showAlertDialog(); // Handle case when no image is provided
      return {}; // Return empty map or handle it accordingly
    }
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomTextField(
                controller: nameController,
                hintText: "Name",
                obscureText: false,
                hintStyle: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomTextField(
                controller: surnameController,
                hintText: "Surname",
                obscureText: false,
                hintStyle: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomTextField(
                  controller: addrController,
                  hintText: "Address",
                  hintStyle: Theme.of(context).textTheme.displayLarge,
                  obscureText: false),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IntlPhoneField(
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    // labelText: 'Phone Number',
                    hintStyle: Theme.of(context).textTheme.displayLarge,
                    // labelStyle: Theme.of(context).textTheme.displayLarge,
                    // border: OutlineInputBorder(
                    //   borderSide: BorderSide(),
                    // ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Colors.transparent), // No underline
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color:
                              Colors.transparent), // No underline when focused
                    ),
                  ),
                  initialCountryCode: 'TH', // Set the initial country code
                  disableLengthCheck: true,
                  onChanged: (phone) {
                    setState(() {
                      _phoneNumber =
                          "${phone.countryCode}/${phone.number}"; // Store the full phone number with country code
                      print(_phoneNumber);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton1(
              text: "Register",
              onTap: () => _createUser(context),
            ),
          ],
        ),
      ),
    );
  }
}
