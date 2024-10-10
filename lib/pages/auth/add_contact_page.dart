// ignore_for_file: avoid_print, unnecessary_null_comparison, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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
        nameController.text != null &&
        surnameController.text != null &&
        addrController.text != null) {
      if (_phoneNumber != null) {
        userData!['phone'] = _phoneNumber!.toString();
      }
      if (nameController.text != null) {
        userData!['name'] = nameController.text;
      }
      if (surnameController.text != null) {
        userData!['surname'] = surnameController.text;
      }
      if (addrController.text != null) {
        userData!['address'] = addrController.text;
      }
      print(userData);
      //call api here to create user then go to next page
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

        // Call the createUser API
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
