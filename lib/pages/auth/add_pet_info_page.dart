// ignore_for_file: avoid_print, use_build_context_synchronously, unused_element, unused_import, unnecessary_null_comparison, non_constant_identifier_names, unnecessary_const

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/components/custom_button.dart';
import 'package:nonghai/components/custom_text_field.dart';
import 'package:nonghai/components/validate_text_field.dart';
import 'package:nonghai/pages/auth/additional_note_page.dart';
import 'package:nonghai/pages/bottom_nav_page.dart';
import 'package:nonghai/pages/nfc_page.dart';
import 'package:nonghai/services/auth/add_profile.dart';
import 'package:nonghai/services/caller.dart';

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
  final eyeColorController = TextEditingController();
  final bloodController = TextEditingController();
  final dobController = TextEditingController();
  String petId = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null) {
      petData = arguments as Map<String, dynamic>?;
      print(petData);
    } else {
      // Handle the case when arguments are null or of a different type
      // You might want to initialize petData to a default value or show an error message.
      // petData =
      //     {}; // Initialize with an empty map or a default value if necessary.
    }
  }

  void navigateToAdditionalNotePage() async {
    final updatedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdditionalNotePage(note: petData?['note']),
      ),
    );

    // If a note is returned, update the state
    if (updatedNote != null) {
      setState(() {
        petData!['note'] = updatedNote;
      });
      print("Received Updated Note: ${petData!['note']}");
      print("Received Updated Note: $updatedNote");
    }
  }

  void _skip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavPage(page: 1)),
      (Route<dynamic> route) => false, // This will remove all the previous routes
    );
  }

  Future<void> _createPet(BuildContext context) async {
    // Validate required fields before proceeding
    if (!_validateFields()) {
      _showAlertDialog();
      return;
    }

    try {
      // Populate petData with the values from the controllers
      petData!['breed'] = breedController.text;
      petData!['name'] = nameController.text;
      petData!['weight'] = int.tryParse(weightController.text);
      petData!['hair_color'] = hairColorController.text;
      petData!['eyes'] = eyeColorController.text;
      petData!['blood_type'] = bloodController.text;

      print(petData);

      // Proceed with the API call
      final response = await Caller.dio.post(
        "/pet/createPet",
        data: petData,
      );

      if (response.statusCode == 201) {
        petId = response.data['data'].toString(); // Extract the petId from the response

        // Use the petId in SaveProfile function
        if (petData?['image'] != null && petData!['image'].isNotEmpty) {
          await SaveProfile();
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NfcPage(petId: petId)),
        );
      } else {
        _showFailureDialog();
      }
    } catch (e) {
      print('Error occurred: ${e.toString()}');
      // _showFailureDialog();
    }
  }

// Validation function to check if required fields are not empty
  bool _validateFields() {
    if (breedController.text.isEmpty) {
      print('invalid breed');
      return false;
    }
    if (nameController.text.isEmpty) {
      print('invalid name');
      return false;
    }
    if (weightController.text.isEmpty) {
      print('invalid weight');
      return false;
    }
    if (hairColorController.text.isEmpty) {
      print('invalid hair');
      return false;
    }
    if (eyeColorController.text.isEmpty) {
      print('invalid eye');
      return false;
    }
    if (bloodController.text.isEmpty) {
      print('invalid blood');
      return false;
    }
    return true;
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Creation Failed',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: const Color(0xff333333)),
          ),
          content: Text(
            'Failed to create the pet profile. Please try again later.',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffC8A48A)),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Invalid Input',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: const Color(0xff333333))),
          content: Text(
            'The field cannot be empty.',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: [
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
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
                  Spacer(),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// ต้อง create(no image) ให้ได้ไอดีมาแล้วค่อยเอาไอดีไปsave in fb-> update iamge
  Future<Map<String, dynamic>> SaveProfile() async {
    if (petData?['image'] != null) {
      String imagePath = petData!['image'];
      // String petId = petData!['id']; // Use the petId for the file name

      Uint8List imageFile = await File(imagePath).readAsBytes();
      String folderPath = 'petProfileImage/$petId.jpg'; // Save as petId.jpg

      String imgUrl =
          await StoreProfile().saveData(userId: petId, file: imageFile, folderPath: folderPath);

      petData!['image'] = imgUrl;
      await _updatePetWithImage(petId, imgUrl);

      print('Uploaded image URL: $imgUrl');
      return petData!;
    } else {
      _showAlertDialog();
      return {};
    }
  }

  Future<void> _updatePetWithImage(String petId, String imageUrl) async {
    final response = await Caller.dio.put(
      "/pet/$petId",
      data: {
        'image': imageUrl,
      },
    );

    if (response.statusCode == 200) {
      print('Pet updated with image URL successfully.');
    } else {
      print('Failed to update pet image URL: ${response.data}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(petData);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(title: "Your Pet info"),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(55, 0, 55, 8),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 40, // Set the desired height for each field
                    child: CustomTextField(
                      controller: nameController,
                      hintText: "Name",
                      obscureText: false,
                      hintStyle: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
                // Dropdown for Animal Type
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 40, // Set the desired height for each field
                    child: DropdownButtonFormField<String>(
                      value: _selectedAnimalType,
                      isExpanded: true,
                      hint: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Animal',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Dog',
                          child: Align(alignment: Alignment.center, child: Text('Dog')),
                        ),
                        DropdownMenuItem(
                          value: 'Cat',
                          child: Align(alignment: Alignment.center, child: Text('Cat')),
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
                            vertical: 0, horizontal: 20), // Adjust vertical padding to fit height
                        hintStyle: Theme.of(context).textTheme.displayLarge,
                      ),
                      style: Theme.of(context).textTheme.displayLarge,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 40, // Set the desired height for each field
                    child: CustomTextField(
                      controller: breedController,
                      hintText: "Breed",
                      obscureText: false,
                      hintStyle: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
                // Date of Birth Field with YYYY-MM-DD format
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 40, // Set the desired height for each field
                    child: TextFormField(
                      controller: dobController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Date of birth',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        hintStyle: Theme.of(context).textTheme.displayLarge,
                      ),
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'\d|-')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          dobController.text = formattedDate;
                          petData!['date_of_birth'] = formattedDate;
                        }
                      },
                    ),
                  ),
                ),
                // Dropdown for Sex
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 40, // Set the desired height for each field
                    child: DropdownButtonFormField<String>(
                      value: _selectedSex,
                      isExpanded: true,
                      hint: Align(
                        alignment: Alignment.center,
                        child: Text('Sex',
                            style: Theme.of(context).textTheme.displayLarge,
                            textAlign: TextAlign.center),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Male',
                          child: Align(alignment: Alignment.center, child: Text('Male')),
                        ),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Align(alignment: Alignment.center, child: Text('Female')),
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        hintStyle: Theme.of(context).textTheme.displayLarge,
                      ),
                      style: Theme.of(context).textTheme.displayLarge,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Other fields (e.g., weight, hair color, blood type)...
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                      height: 40, // Set the desired height for each field
                      child: TextField(
                        controller: weightController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(90),
                            borderSide: BorderSide.none,
                          ),

                          // enabledBorder: OutlineInputBorder(
                          //   borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                          // ),
                          fillColor: Theme.of(context).colorScheme.tertiary,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(90),
                            borderSide: BorderSide(
                              width: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          hintText: "Weight",
                          hintStyle: Theme.of(context).textTheme.displayLarge,
                        ),
                        obscureText: false,
                        keyboardType: TextInputType.number, // Use the number keyboard
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      )),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 40, // Set the desired height for each field
                    child: CustomTextField(
                      controller: hairColorController,
                      hintText: "Hair color",
                      hintStyle: Theme.of(context).textTheme.displayLarge,
                      obscureText: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 40, // Set the desired height for each field
                    child: CustomTextField(
                      controller: eyeColorController,
                      hintText: "Eye color",
                      hintStyle: Theme.of(context).textTheme.displayLarge,
                      obscureText: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                      height: 40, // Set the desired height for each field
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: bloodController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(90),
                            borderSide: BorderSide.none,
                          ),

                          // enabledBorder: OutlineInputBorder(
                          //   borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                          // ),
                          fillColor: Theme.of(context).colorScheme.tertiary,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(90),
                            borderSide: BorderSide(
                              width: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          hintText: "Blood type",
                          hintStyle: Theme.of(context).textTheme.displayLarge,
                        ),
                        obscureText: false,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                        ],
                      )),
                ),
                // Additional note and buttons...
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      navigateToAdditionalNotePage();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 40, // Set the desired height for the note button
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: const Center(
                        child: Text(
                          'Add additional note',
                          style: TextStyle(
                              color: Color(0xffC8A48A),
                              fontFamily: "Fredoka",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),
                CustomButton1(
                  text: "Next",
                  onTap: () => _createPet(context),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: TextButton(
                    onPressed: () => _skip(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(175, 224, 223, 223), // Background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            50), // Optional: Adjust radius for rounded corners
                      ),
                    ),
                    child: const Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        children: [
                          const Spacer(),
                          const Text(
                            "Skip",
                            style: TextStyle(
                              color: Color(0xffC8A48A),
                              fontFamily: "Fredoka",
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
