import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nonghai/pages/auth/additional_note_page.dart';

import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../services/auth/auth_service.dart';
import '../../services/caller.dart';
import '../bottom_nav_page.dart';
import 'home_page.dart';

class AddPetInfoPage extends StatefulWidget {
  // final void Function()? onTap;
  const AddPetInfoPage({super.key});

  @override
  State<AddPetInfoPage> createState() => _AddPetInfoPageState();
}

class _AddPetInfoPageState extends State<AddPetInfoPage> {
  String? _selectedAnimalType, _selectedSex;
  Map<String, dynamic>? petData;
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final weightController = TextEditingController();
  final hairColorController = TextEditingController();
  final bloodController = TextEditingController();
  final dobController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    petData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  void _skip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavPage(page: 1)),
      (Route<dynamic> route) =>
          false, // This will remove all the previous routes
    );
  }

  Future<void> _createPet(BuildContext context) async {
    // if (_phoneNumber != null &&
    //     nameController.text != null &&
    //     surnameController.text != null &&
    //     addrController.text != null) {
    if (breedController.text != null) {
      petData!['breed'] = breedController.text;
    }
    if (nameController.text != null) {
      petData!['name'] = nameController.text;
    }
    if (weightController.text != null) {
      petData!['weight'] = int.tryParse(weightController.text);
    }
    if (hairColorController.text != null) {
      petData!['hair_color'] = hairColorController.text;
    }
    if (bloodController.text != null) {
      petData!['blood_type'] = bloodController.text;
    }
    print(petData);
    //call api here to create user then go to next page

    final response = await Caller.dio.post(
      "/pet/createPet",
      data: petData,
    );

    // Check if API call was successful
    if (response.statusCode == 201) {
      print('resp: ${response.data}');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavPage(page: 1)),
        (Route<dynamic> route) =>
            false, // This will remove all the previous routes
      );
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
    // } else {
    //   _showAlertDialog();
    // }
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
    print(petData);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Pet info",
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
            // Dropdown for Animal Type
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: _selectedAnimalType,
                hint: Text(
                  'Animal',
                  style: Theme.of(context).textTheme.displayLarge,
                ), // Use hint here
                items: const [
                  DropdownMenuItem(
                    value: 'Dog',
                    child: Text('Dog'),
                  ),
                  DropdownMenuItem(
                    value: 'Cat',
                    child: Text('Cat'),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAnimalType = newValue;
                    petData!['animal_type'] = newValue;
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20), // Match the TextField padding
                  hintStyle: Theme.of(context)
                      .textTheme
                      .displayLarge, // Match the hint style
                ),
                style: Theme.of(context)
                    .textTheme
                    .displayLarge, // Style for dropdown text
                dropdownColor: Colors.white, // Background color of the dropdown
                borderRadius: BorderRadius.circular(
                    12), // Match the rounded corner for dropdown menu
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomTextField(
                controller: breedController,
                hintText: "Breed",
                obscureText: false,
                hintStyle: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            // Date of Birth Field with YYYY-MM-DD format
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: dobController, // Your controller for date of birth
                decoration: InputDecoration(
                  hintText: 'Date of birth',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  hintStyle: Theme.of(context).textTheme.displayLarge,
                ),
                // style: Theme.of(context).textTheme.displayLarge,
                keyboardType:
                    TextInputType.datetime, // Opens number and symbols keyboard
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'\d|-')), // Only allows digits and dash
                  LengthLimitingTextInputFormatter(
                      10), // Limits input to 10 characters (YYYY-MM-DD)
                ],
                onTap: () async {
                  // Show DatePicker to help the user select the date
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900), // Set minimum year
                    lastDate: DateTime.now(), // Set maximum to today
                  );
                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    dobController.text =
                        formattedDate; // Set the formatted date to the text field
                    petData!['date_of_birth'] = formattedDate;
                  }
                },
              ),
            ),
            // Dropdown for Sex
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: _selectedSex,
                hint: Text(
                  'Sex',
                  style: Theme.of(context).textTheme.displayLarge,
                ), // Use hint here
                items: const [
                  DropdownMenuItem(
                    value: 'Male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child: Text('Female'),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSex = newValue;
                    petData!['sex'] = newValue;
                  });
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20), // Match the TextField padding
                  hintStyle: Theme.of(context)
                      .textTheme
                      .displayLarge, // Match the hint style
                ),
                style: Theme.of(context)
                    .textTheme
                    .displayLarge, // Style for dropdown text
                dropdownColor: Colors.white, // Background color of the dropdown
                borderRadius: BorderRadius.circular(
                    12), // Match the rounded corner for dropdown menu
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomTextField(
                  controller: weightController,
                  hintText: "Weight",
                  hintStyle: Theme.of(context).textTheme.displayLarge,
                  obscureText: false),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomTextField(
                  controller: hairColorController,
                  hintText: "Hair color",
                  hintStyle: Theme.of(context).textTheme.displayLarge,
                  obscureText: false),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomTextField(
                  controller: bloodController,
                  hintText: "Blood type",
                  hintStyle: Theme.of(context).textTheme.displayLarge,
                  obscureText: false),
            ),
            //additional note
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AdditionalNotePage(petData: petData)),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Text('Add additional note',
                      style: Theme.of(context).textTheme.displayLarge),
                ),
              ),
            ),

            // const SizedBox(height: 16),
            CustomButton1(
              text: "Next",
              onTap: () => _createPet(context),
            ),
            // const SizedBox(height: 5),
            CustomButton1(
              text: "Skip",
              onTap: () => _skip(),
            ),
          ],
        ),
      ),
    );
  }
}
