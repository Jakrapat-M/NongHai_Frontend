import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';

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

  void _createUser(BuildContext context) {
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
    } else {
      _showAlertDialog();
    }
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Input'),
          content: Text('The field cannot be empty.'),
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
                  color: Color(0xffffffff),
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
                      borderSide:
                          BorderSide(color: Colors.transparent), // No underline
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
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
