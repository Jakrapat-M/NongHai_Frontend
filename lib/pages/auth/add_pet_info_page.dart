// ignore_for_file: avoid_print, use_build_context_synchronously, unused_element, unused_import, unnecessary_null_comparison, non_constant_identifier_names, unnecessary_const

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nonghai/components/validate_text_field.dart';
import 'package:nonghai/pages/auth/additional_note_page.dart';
import 'package:nonghai/pages/nfc_page.dart';

import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../services/auth/add_profile.dart';
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
      (Route<dynamic> route) =>
          false, // This will remove all the previous routes
    );
  }

  Future<void> _createPet(BuildContext context) async {
    try {
      // Check for empty fields and show a dialog if any required fields are missing
      if (breedController.text.isEmpty) {
        _showAlertDialog();
        return;
      }
      if (nameController.text.isEmpty) {
        _showAlertDialog();
        return;
      }
      if (weightController.text.isEmpty) {
        _showAlertDialog();
        return;
      }
      if (hairColorController.text.isEmpty) {
        _showAlertDialog();
        return;
      }
      if (eyeColorController.text.isEmpty) {
        _showAlertDialog();
        return;
      }
      if (bloodController.text.isEmpty) {
        _showAlertDialog();
        return;
      }

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
        petId = response.data['data']
            .toString(); // Extract the petId from the response

        // Use the petId in SaveProfile function
        if (petData?['image'] != null && petData!['image'].isNotEmpty) {
          await SaveProfile();
        }

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NfcPage(petId: response.data['data'])));
      } else {
        _showAlertDialog();
      }
    } catch (e) {
      print('Error occurred: ${e.toString()}');
      _showAlertDialog();
    }
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('The fields cannot be empty.'),
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

// ต้อง create(no image) ให้ได้ไอดีมาแล้วค่อยเอาไอดีไปsave in fb-> update iamge
  Future<Map<String, dynamic>> SaveProfile() async {
    if (petData?['image'] != null) {
      String imagePath = petData!['image'];
      // String petId = petData!['id']; // Use the petId for the file name

      Uint8List imageFile = await File(imagePath).readAsBytes();
      String folderPath = 'petProfileImage/$petId.jpg'; // Save as petId.jpg

      String imgUrl = await StoreProfile()
          .saveData(userId: petId, file: imageFile, folderPath: folderPath);

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
      appBar: AppBar(
        title: Text("Your Pet info",
            style: Theme.of(context).bannerTheme.contentTextStyle),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                      hint: Text(
                        'Animal',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
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
                          borderSide:
                              const BorderSide(color: Colors.transparent),
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
                            vertical: 0,
                            horizontal:
                                20), // Adjust vertical padding to fit height
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
                      decoration: InputDecoration(
                        hintText: 'Date of birth',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 20),
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
                      hint: Text(
                        'Sex',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
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
                          borderSide:
                              const BorderSide(color: Colors.transparent),
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
                            vertical: 0, horizontal: 20),
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
                        keyboardType:
                            TextInputType.number, // Use the number keyboard
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'))
                        ],
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
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
                TextButton(
                  onPressed: () => _skip(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        175, 224, 223, 223), // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          50), // Optional: Adjust radius for rounded corners
                    ),
                  ),
                  child: const Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 113),
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
      ),
    );
  }
}
