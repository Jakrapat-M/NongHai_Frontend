// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print, use_build_context_synchronously, non_constant_identifier_names

// import 'dart:typed_data';

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// import 'package:nonghai/pages/auth/pet_profile_page.dart';
import 'package:nonghai/services/auth/add_profile.dart';
import 'package:nonghai/services/caller.dart';
import 'package:permission_handler/permission_handler.dart';

class EditPetPage extends StatefulWidget {
  final Map<String, dynamic> petData;
  const EditPetPage({super.key, required this.petData});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  late bool isSafe = true;
  var containerColor;
  late DateTime _dob;
  late String _name,
      _breed,
      _eye,
      _blood,
      _note,
      _hair,
      _animalType,
      image,
      _weight,
      _age,
      _selectedGender = '';
  // late int _weight;
  // late dynamic image;
  XFile? _newImage;
  late Map<String, dynamic> petDetails;
  bool _isLoading = true;
  final String _errorMessage = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController hairController = TextEditingController();
  final TextEditingController eyeController = TextEditingController();
  final TextEditingController bloodController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    isSafe = widget.petData['status'] == 'Safe';
    image = widget.petData['image'];
  }

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    hairController.dispose();
    weightController.dispose();
    bloodController.dispose();
    eyeController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _initializeUserData() {
    setState(() {
      _isLoading = true; // Start loading
    });

    petDetails = widget.petData;
    _name = petDetails['name'] ?? '';
    _hair = petDetails['hair_color'] ?? '';
    _eye = petDetails['eyes'] ?? '';
    _weight = petDetails['weight'].toString();
    _animalType = petDetails['animal_type'];
    _note = petDetails['note'] ?? '';
    _blood = petDetails['blood_type'] ?? '';
    _breed = petDetails['breed'] ?? '';
    _selectedGender = petDetails['sex'] ?? '';
    _age = petDetails['age'] ?? '';
    _dob = DateTime.parse(petDetails['date_of_birth'].toString());

    // Update text controllers with initial data
    nameController.text = _name;
    breedController.text = _breed;
    weightController.text = _weight;
    hairController.text = _hair;
    eyeController.text = _eye;
    bloodController.text = _blood;
    noteController.text = _note;

    // Set loading to false after data initialization
    setState(() {
      _isLoading = false;
    });
  }

  // Function to calculate age based on the selected date of birth
  String calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;

    // Adjust the age if the birthday hasn't occurred yet this year
    if (months < 0 || (months == 0 && today.day < birthDate.day)) {
      years--;
      months += 12; // Add 12 to months to account for a full year
    }

    // Calculate the number of months if years is less than 1
    if (years == 0) {
      if (months == 1 || months == 0) {
        return '$months month'; // Singular form for 1 month
      } else {
        return '$months months';
      }
    } else {
      if (years == 1) {
        return '$years year';
      } else {
        return '$years years';
      }
    }
  }

  String formatDateOfBirth(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMMM yyyy').format(date);
  }

  Future<void> _saveChanges() async {
    // Show loading state while saving changes
    setState(() {
      _isLoading = true; // Optionally, show a loading indicator
    });
    await SaveProfile();
    String name = nameController.text.isEmpty ? '-' : nameController.text;
    String breed =
        breedController.text.isEmpty ? 'Unknown' : breedController.text;

    // Prepare the data for the API call
    final petData = {
      "name": name,
      "animal_type": _animalType,
      "breed": breed,
      "date_of_birth": _dob
          .toLocal()
          .toIso8601String()
          .split('T')
          .first, // Correct date format
      "sex": _selectedGender,
      "weight": double.tryParse(weightController.text) ??
          0.0, // Ensure to send as double
      "hair_color": hairController.text,
      "blood_type": bloodController.text,
      "eyes": eyeController.text,
      "status": isSafe ? "Safe" : "Lost",
      "note": noteController.text,
      "image": image, // Include the current image or new image if updated
    };

    try {
      final response = await Caller.dio.put(
        "/pet/${widget.petData['id']}", // Adjust the URL based on your API structure
        data: petData,
      );

      if (response.statusCode == 200) {
        print('Pet data updated successfully');
        // Optionally, show a success message or navigate back
        Navigator.pop(context, true);
      } else {
        print('Failed to update pet data: ${response.statusCode}');
        _showError("Failed to update pet data. Please try again.");
      }
    } catch (e) {
      print('Error occurred while updating pet data: $e');
      _showError("An error occurred. Please try again later.");
    } finally {
      // Hide loading state after operation is complete
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePetStatus(bool isSafe) async {
    setState(() {
      _isLoading = true; // Start loading
      this.isSafe = isSafe; // Update the isSafe variable
      containerColor = isSafe
          ? Theme.of(context).colorScheme.surfaceBright
          : Theme.of(context).colorScheme.onErrorContainer;
      _isLoading = false;
    });

    //   setState(() {
    //     containerColor = isSafe
    //         ? Theme.of(context).colorScheme.surfaceBright
    //         : Theme.of(context).colorScheme.onErrorContainer;
    //   });
    // setState(() {
    //   _isLoading = false; // Set loading to false after the update is complete
    // });
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select Image Source',
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      child: const Text('Camera'),
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // Check and request camera permission
                        var cameraStatus = await Permission.camera.status;
                        if (!cameraStatus.isGranted) {
                          cameraStatus = await Permission.camera.request();
                        }

                        if (cameraStatus.isGranted) {
                          final ImagePicker picker = ImagePicker();
                          final XFile? selectedImage = await picker.pickImage(
                            source: ImageSource.camera,
                          );
                          if (selectedImage != null) {
                            setState(() {
                              _newImage = selectedImage;
                            });
                          }
                        } else {
                          _showMessage(
                            'Camera permission denied. Please allow permission in settings.',
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      child: const Text('Gallery'),
                      onPressed: () async {
                        Navigator.of(context).pop();

                        // Check and request storage/gallery permission
                        var galleryStatus = await Permission.storage.status;
                        if (!galleryStatus.isGranted) {
                          galleryStatus = await Permission.storage.request();
                        }

                        if (galleryStatus.isGranted) {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                          );

                          if (result != null && result.files.isNotEmpty) {
                            String path = result.files.single.path!;
                            setState(() {
                              _newImage = XFile(path);
                            });
                          } else {
                            _showMessage('No file selected.');
                          }
                        } else {
                          _showMessage(
                            'Storage permission denied. Please allow permission in settings.',
                          );
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
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      // No casting needed
      SnackBar(content: Text(message)),
    );
  }

  Future<void> SaveProfile() async {
    String id = petDetails['id'];
    if (_newImage != null) {
      try {
        // Convert the image file to Uint8List for uploading
        Uint8List imageFile = await _newImage!.readAsBytes();

        // Define the path for the image upload
        String folderPath = 'petProfileImage/$id.jpg'; // Save as userId.jpg

        // Save the profile image and get the new image URL
        String imgUrl = await StoreProfile().saveData(
          userId: id,
          file: imageFile,
          folderPath: folderPath,
        );

        // Update the state with the new image URL
        setState(() {
          image = imgUrl; // Update the local image URL with the new one
        });

        print('Uploaded image URL: $imgUrl');
      } catch (e) {
        _showError("Failed to update profile image: $e");
      }
    }
    // else {
    //   _showError("Can't update new profile");
    // }
  }

  Future<void> _showError(String show) async {
    if (mounted) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(show),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle the case where the widget is not mounted, if necessary.
      print("Widget is not mounted, cannot show dialog.");
      return Future.value();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    containerColor = isSafe
        ? Theme.of(context).colorScheme.surfaceBright
        : Theme.of(context).colorScheme.onErrorContainer;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
            child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).colorScheme.surface,
        )),
      );
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }
    return Scaffold(
        appBar: AppBar(
          // title: Text(petDetails['name'] ?? 'Pet Details'),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 20, 0),
            child: Row(
              children: [
                Icon(
                  isSafe
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  color: isSafe ? Colors.green : Colors.red,
                  size: 30,
                ),
                const Padding(padding: EdgeInsets.all(8)),
                Text(
                  isSafe ? 'SAFE' : 'LOST',
                  style: TextStyle(
                      color: isSafe ? Colors.green : Colors.red, fontSize: 30),
                ),
                const Spacer(),
              ],
            ),
          ),
          backgroundColor: const Color(0xfff2f2f2),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: 0.55,
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey.shade300,
                                  radius: 125,
                                  backgroundImage: (_newImage !=
                                          null) // Check if a new image is selected
                                      ? FileImage(File(_newImage!
                                          .path)) // Load image from the newly selected XFile
                                      : (image != '' && image.isNotEmpty)
                                          ? NetworkImage(
                                              image) // Load image from URL if no new image is selected
                                          : null,
                                ),
                              ),
                              // Icon on top of the CircleAvatar
                              GestureDetector(
                                onTap: () {
                                  // Handle image selection here (e.g., open image picker)
                                  _pickImage();
                                },
                                child: const Icon(
                                  Icons.photo_library_outlined,
                                  size: 28,
                                  color: Colors.black87, // Icon color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 18, 0, 5),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 60),
                                child: Text(
                                  'Name',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xff5c5c5c),
                                      fontFamily: 'Frodoka',
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              // const Spacer(),
                              Expanded(
                                child: TextFormField(
                                  textAlignVertical: TextAlignVertical.center,
                                  maxLines:
                                      1, // Keeps it as a single line field
                                  minLines: 1,
                                  controller: nameController,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 0,
                                      ),
                                      isCollapsed: true
                                      // hintText: 'Enter username',
                                      ),
                                  keyboardType: TextInputType.name,
                                  onChanged: (value) {
                                    setState(() {
                                      _name = value;
                                    });
                                  },
                                ),
                              ),
                              // const Spacer()
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 25),
                                child: Text(
                                  'Animals',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff5c5c5c),
                                    fontFamily: 'Frodoka',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: petDetails[
                                      'animal_type'], // Initialize with petDetails['animal_type']
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Cat',
                                      child: Text('Cat'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Dog',
                                      child: Text('Dog'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _animalType = value!;
                                    });
                                  },
                                  style: Theme.of(context).textTheme.titleLarge,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32.0),
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32.0),
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32.0),
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  dropdownColor: Colors
                                      .white, // Dropdown list background color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 62),
                                child: Text(
                                  'Breed',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xff5c5c5c),
                                      fontFamily: 'Frodoka',
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              // const Spacer(),
                              Expanded(
                                child: TextFormField(
                                  controller: breedController,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 0,
                                      ), // Adjust vertical padding
                                      isCollapsed: true,
                                      hintText:
                                          'Enter breed', // Optional: Add hint text
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  keyboardType: TextInputType.name,
                                  onChanged: (value) {
                                    setState(() {
                                      _breed = value;
                                    });
                                  },
                                ),
                              ),

                              // const Spacer()
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(70, 5, 70, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _selectedGender == 'Female'
                                      ? containerColor
                                      : Theme.of(context).colorScheme.tertiary,
                                  border: Border.all(color: Colors.transparent),
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(25)),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedGender = 'Female';
                                    });
                                    print('Female selected');
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets
                                        .zero, // Remove default padding
                                    alignment:
                                        Alignment.center, // Center the content
                                  ),
                                  child: Text(
                                    'Female',
                                    style: TextStyle(
                                        color: _selectedGender == 'Female'
                                            ? Theme.of(context)
                                                .colorScheme
                                                .tertiary
                                            : Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.color,
                                        fontFamily: "Fredoka",
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.w500), // Text color
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _selectedGender == 'Male'
                                      ? containerColor
                                      : Theme.of(context).colorScheme.tertiary,
                                  border: Border.all(color: Colors.transparent),
                                  borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(25)),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedGender = 'Male';
                                    });
                                    print('Male selected');
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets
                                        .zero, // Remove default padding
                                    alignment:
                                        Alignment.center, // Center the content
                                  ),
                                  child: Text(
                                    'Male',
                                    style: TextStyle(
                                        color: _selectedGender == 'Male'
                                            ? Theme.of(context)
                                                .colorScheme
                                                .tertiary
                                            : Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.color,
                                        fontFamily: "Fredoka",
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Age calculated from birthdate, can't be modified*",
                            style: TextStyle(
                                color: Color(0xff5c5c5c),
                                fontSize: 11,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 3, 0, 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'age',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          Text(
                                            _age,
                                            style: const TextStyle(
                                              color: Color(0xff333333),
                                              fontSize: 20,
                                              fontFamily: 'Fredoka',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.all(5)),
                                Expanded(
                                  child: Container(
                                    // height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize
                                            .min, // Ensures the column doesn't expand infinitely
                                        children: [
                                          Text(
                                            'weight (kg)', // Fixed capitalization for consistency
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          // const SizedBox(
                                          //     height:
                                          //         8), // Add some spacing between the label and the field
                                          SizedBox(
                                            height: 35,
                                            child: TextFormField(
                                              controller: weightController,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  // contentPadding: EdgeInsets.symmetric(
                                                  //     vertical:
                                                  //         10), // Adjust vertical padding
                                                  hintText:
                                                      'Enter weight', // Adjusted placeholder text
                                                  hintStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge),
                                              keyboardType: TextInputType
                                                  .number, // Number input for weight
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(
                                                        RegExp(r'^\d*\.?\d*'))
                                              ],
                                              textAlign: TextAlign.center,
                                              onChanged: (value) {
                                                setState(() {
                                                  _weight = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(22, 5, 0, 5),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Date of birth',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () async {
                                              DateTime? selectedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime.now(),
                                              );

                                              if (selectedDate != null) {
                                                setState(() {
                                                  // Update date of birth in petDetails
                                                  _dob = selectedDate;

                                                  // Calculate and update age in petDetails
                                                  _age =
                                                      calculateAge(selectedDate)
                                                          .toString();
                                                });
                                              }
                                            },
                                            child: Text(
                                              formatDateOfBirth(
                                                  _dob.toString()),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xffbfbfbf),
                                                fontFamily: 'Fredoka',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 32,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 23.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 62),
                                    child: Text(
                                      'Hair Color',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                  ),
                                  // const Spacer(),
                                  Expanded(
                                    child: TextFormField(
                                      textAlign: TextAlign.end,
                                      controller: hairController,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xffbfbfbf),
                                        fontFamily: 'Fredoka',
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isCollapsed: true,
                                        // contentPadding: EdgeInsets.symmetric(
                                        //   vertical: 11,
                                        // ), // Adjust vertical padding
                                        hintText:
                                            'Enter hair color', // Optional: Add hint text
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xffbfbfbf),
                                          fontFamily: 'Fredoka',
                                        ),
                                      ),
                                      keyboardType: TextInputType.text,
                                      onChanged: (value) {
                                        setState(() {
                                          _hair = value;
                                        });
                                      },
                                    ),
                                  ),

                                  // const Spacer()
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 5, 20, 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween, // Aligns the text and TextFormField
                                          children: [
                                            Text(
                                              'Eyes',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                            SizedBox(
                                              height: 24,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2, // Optional: Limit the width of the TextFormField
                                              child: TextFormField(
                                                textAlign: TextAlign
                                                    .end, // Align text inside the TextFormField to the right
                                                controller: eyeController,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xffbfbfbf),
                                                  fontFamily: 'Fredoka',
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText:
                                                      'Eyes color', // Optional: Add hint text
                                                  hintStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xffbfbfbf),
                                                    fontFamily: 'Fredoka',
                                                  ),
                                                  isDense:
                                                      true, // Reduces the height of the TextFormField
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical:
                                                              0), // Adjust vertical padding
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _eye = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.all(3)),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 8, 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween, // Aligns the text and TextFormField
                                          children: [
                                            Text(
                                              'Blood Type',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                            SizedBox(
                                              height: 24,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.15, // Optional: Limit the width of the TextFormField
                                              child: TextFormField(
                                                textAlign: TextAlign
                                                    .end, // Align text inside the TextFormField to the right
                                                controller: bloodController,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xffbfbfbf),
                                                  fontFamily: 'Fredoka',
                                                ),
                                                decoration:
                                                    const InputDecoration(
                                                  border: InputBorder.none,
                                                  // hintText:
                                                  //     'Eyes color', // Optional: Add hint text
                                                  isDense:
                                                      true, // Reduces the height of the TextFormField
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical:
                                                              0), // Adjust vertical padding
                                                ),
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      6), // Limit to 6 characters
                                                ],
                                                keyboardType:
                                                    TextInputType.text,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _blood = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IntrinsicWidth(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.white),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 22, vertical: 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Switch(
                                            value: isSafe,
                                            onChanged: (value) {
                                              setState(() {
                                                isSafe = value;
                                              });
                                              _updatePetStatus(isSafe);
                                              // You might want to send this updated status to your backend here.
                                            },
                                            activeColor: Colors.green,
                                            inactiveThumbColor: Colors.red,
                                          ),
                                          const Padding(
                                              padding: EdgeInsets.all(5)),
                                          Text(
                                            isSafe ? 'SAFE' : 'LOST',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff333333),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Report pet lost status*",
                                      style: TextStyle(
                                          color: Color(0xff5C5C5C),
                                          fontFamily: 'Fredoka',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Additional note",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                  const Padding(padding: EdgeInsets.all(3)),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white),
                                    child: SingleChildScrollView(
                                      child: TextFormField(
                                        controller: noteController,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xffbfbfbf),
                                          fontFamily: 'Fredoka',
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          // hintText:
                                          //     'Eyes color', // Optional: Add hint text
                                          isDense:
                                              true, // Reduces the height of the TextFormField
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical:
                                                  0), // Adjust vertical padding
                                        ),
                                        maxLines: 10,
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          setState(() {
                                            _note = value;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white),
                                    child: Text(
                                      'Cancel',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Handle save logic, such as updating the user data in the backend
                                      _saveChanges();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xffC8A48A)),
                                    child: const Text(
                                      'Confirm',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xffFFFFFF),
                                          fontFamily: 'Frodoka',
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]))));
  }
}
