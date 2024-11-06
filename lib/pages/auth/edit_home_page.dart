// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, unnecessary_null_comparison, use_build_context_synchronously, non_constant_identifier_names, prefer_typing_uninitialized_variables

// import 'dart:io';
// import 'dart:typed_data'; //unnecessary

import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nonghai/services/auth/add_profile.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/services/location_service.dart';
import 'package:permission_handler/permission_handler.dart';

class EditHomePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditHomePage({super.key, required this.userData});

  @override
  State<EditHomePage> createState() => _EditHomePageState();
}

class _EditHomePageState extends State<EditHomePage> {
  bool isLoadingAddress = false;
  bool _isLoading = true;
  late String _uid;
  late String _username;
  late String _newAddress = '';
  String _address = '';
  late String _phone;
  late String _image = '';
  // var image;
  late String? imgUrl;
  late List<dynamic> _petDetails;
  int _petCount = 0;
  XFile? _newImage;
  final List<String> _deletedPetIds = [];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeUserData() {
    // Extract user data from the widget's userData map
    _uid = widget.userData['id'] ?? FirebaseAuth.instance.currentUser!.uid;
    _username = widget.userData['username'] ?? 'No Username';
    _address = widget.userData['address'] ?? '';
    _phone = widget.userData['phone'] ?? 'No Phone';
    _image = widget.userData['image'] ?? '';
    _petDetails = widget.userData['pets'] ?? '';
    _petCount = _petDetails.length;
    imgUrl = '';

    _usernameController.text = _username;
    _addressController.text = _address;
    _phoneController.text = _phone;

    setState(() {
      _isLoading = false;
    });
  }

  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Select Image Source',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: const Color(0xff333333))),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffC8A48A)),
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
                child: const Text(
                  'Camera',
                  style: TextStyle(
                      fontSize: 20,
                      color: Color(0xffFFFFFF),
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffC8A48A)),
                child: const Text(
                  'Gallery',
                  style: TextStyle(
                      fontSize: 20,
                      color: Color(0xffFFFFFF),
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w500),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final XFile? result =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (result != null) {
                    setState(() {
                      _newImage = result;
                    });
                  } else {
                    _showMessage('No file selected.');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> SaveProfile() async {
    print(_newImage);
    if (_newImage != null) {
      try {
        // Convert the image file to Uint8List for uploading
        Uint8List imageFile = await _newImage!.readAsBytes();

        // Define the path for the image upload
        String folderPath = 'profileImage/$_uid.jpg'; // Save as userId.jpg

        // Save the profile image and get the new image URL
        imgUrl = await StoreProfile().saveData(
          userId: _uid,
          file: imageFile,
          folderPath: folderPath,
        );
        // print(imgUrl);

        // Update the state with the new image URL
        // setState(() {
        //   _image = imgUrl!; // Update the local image URL with the new one
        // });
        print(_image);

        print('Uploaded image URL: $imgUrl');
      } catch (e) {
        _showError("Failed to update profile image: $e");
      }
    }
    // else {
    //   _showError("Can't update new profile");
    // }
  }

  // Function to show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, String petId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Pet',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: const Color(0xff333333)),
          ),
          content: Text(
            'Are you sure you want to delete this pet ?',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      _deletedPetIds.add(petId); // Add petId to deleted list
                      setState(() {
                        _petDetails.removeWhere((pet) => pet['id'] == petId);
                        _petCount = _petDetails.length;
                      });
                      Navigator.of(context)
                          .pop(); // Close the dialog after deletion
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xffFFFFFF),
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Change Password ?',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: const Color(0xff333333)),
          ),
          content: Text(
            'this process will reset your password, please check your registered email.',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _sendPasswordResetEmail(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xffFFFFFF),
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        // Store a reference to the scaffold messenger before the await.
        final messenger = ScaffoldMessenger.of(context);

        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);

        // Ensure the widget is still mounted before showing the snackbar.
        if (context.mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Password reset email sent!')),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email found for the current user.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

// // Function to delete pet by ID (implement your API call here)
//   Future<void> _deletePetById(String petId) async {
//     // Add your API call logic here to delete the pet by ID
//     print('Deleting pet with ID: $petId');
//     // Example: await apiService.deletePet(petId);
//     try {
//       final response = await Caller.dio.delete("/pet/$petId");

//       if (response.statusCode == 200) {
//         setState(() {
//           _petDetails.removeWhere((pet) => pet['id'] == petId);
//           _petCount = _petDetails.length; // Update the pet count.
//         });
//         print('Pet with ID: $petId deleted successfully');
//       }
//     } catch (e) {
//       print('Error occurred while delete pet: $e');
//       _showError("An error occurred. Please try again later.");
//     }
//   }

  @override
  Widget build(BuildContext context) {
    Future<void> getLocation() async {
      setState(() {
        isLoadingAddress = true;
      });
      Future<Position?> location = LocationService().getLocation();
      location.then((value) async {
        if (value != null) {
          print('Location: ${value.latitude}, ${value.longitude}');
          try {
            final resp =
                await Caller.dio.post('/tracking/getAddressByLatLng', data: {
              'lat': value.latitude,
              'lng': value.longitude,
            });
            if (resp.statusCode == 200) {
              setState(() {
                _newAddress = resp.data['data'];
                print(_newAddress);
                isLoadingAddress = false;
              });
            }
          } catch (e) {
            setState(() {
              isLoadingAddress = false;
            });
            if (kDebugMode) {
              print('Network error occurred: $e');
            }
          }
        }
      });
    }

    if (_isLoading) {
      // Show a loading spinner while fetching data
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(35, 85, 35, 10),
          child: Column(
            children: [
              // Profile Image with Icon Overlay
              Stack(
                alignment: Alignment.center,
                children: [
                  // CircleAvatar with opacity
                  Opacity(
                    opacity: 0.55, // Set opacity to 55%
                    child: CircleAvatar(
                      radius: 47,
                      backgroundImage: (_newImage !=
                              null) // Check if a new image is selected
                          ? FileImage(File(_newImage!
                              .path)) // Load image from the newly selected XFile
                          : (_image != null && _image.isNotEmpty)
                              ? NetworkImage(
                                  _image) // Load image from URL if no new image is selected
                              : const AssetImage(
                                      'assets/images/default_profile.png') // Fallback to a placeholder if no image exists
                                  as ImageProvider,
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
              const SizedBox(height: 16),
              // Editable TextFields for User Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32.0),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.withOpacity(0.2),
                    //     spreadRadius: 1,
                    //     blurRadius: 5,
                    //     offset: const Offset(0, 3),
                    //   ),
                    // ],
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Name',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff1E1E1E),
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w400),
                      ),
                      const Spacer(),
                      Expanded(
                        child: TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xff2C3F50),
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            // hintText: 'Enter username',
                          ),
                          keyboardType: TextInputType.name,
                          onChanged: (value) {
                            setState(() {
                              _username = value;
                            });
                          },
                        ),
                      ),
                      // const Spacer()
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Address field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.withOpacity(0.2),
                  //     spreadRadius: 1,
                  //     blurRadius: 5,
                  //     offset: const Offset(0, 3),
                  //   ),
                  // ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: getLocation,
                        child: isLoadingAddress
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xffC8A48A),
                                  ),
                                  const SizedBox(width: 25),
                                  Expanded(
                                    child: Text(
                                      _newAddress == ''
                                          ? "Update location"
                                          : _newAddress,
                                      // Display address or default text
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xffC8A48A),
                                        fontFamily: 'Fredoka',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Phone field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.withOpacity(0.2),
                  //     spreadRadius: 1,
                  //     blurRadius: 5,
                  //     offset: const Offset(0, 3),
                  //   ),
                  // ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_in_talk_outlined,
                      color: Color(0xff2C3F50),
                      size: 24,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        initialValue: _phone,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xff1E1E1E),
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Phone no. has to be 9 or 10 digits',
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Allow digits only

                          LengthLimitingTextInputFormatter(
                              10), // Limit input to 10 characters
                          // TextInputFormatter.withFunction((oldValue, newValue) {
                          //   // Ensure length is between 9 and 10 characters
                          //   if (newValue.text.length < 9) {
                          //     return oldValue; // Prevent changes if length is less than 9
                          //   }
                          //   return newValue;
                          // }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _phone = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        _showConfirmationDialog(context);
                      },
                      child: const Text(
                        "Change password",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff333333),
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Pet section
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                        child: Row(
                          children: [
                            Text('Your Family', style: TextStyle(fontSize: 16))
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height * 0.41,
                        child: _petCount == 0
                            ? const Center(
                                child: Text(
                                  'No pet in family right now',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: _petCount,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 15.0,
                                  crossAxisSpacing: 12.0,
                                  childAspectRatio: 2.05 / 2.6,
                                ),
                                itemBuilder: (context, index) {
                                  final pet = _petDetails[index];
                                  return Card(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        Opacity(
                                          opacity:
                                              0.55, // Adjust the opacity level as needed.
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.18,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                    top: Radius.circular(8),
                                                  ),
                                                  child: Container(
                                                    color: const Color.fromARGB(
                                                        255, 227, 225, 225),
                                                    child: pet['img'] != '' &&
                                                            pet['img'] != null
                                                        ? Image.network(
                                                            pet['img'],
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return const Center(
                                                                child: Text(
                                                                  'No preview image',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .grey, // Customize text color if needed
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )
                                                        : const Center(
                                                            child: Text(
                                                              'No preview image',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey, // Customize text color if needed
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 5, 8, 5),
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            constraints: BoxConstraints(
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.35),
                                                            child: Text(
                                                              pet['name'],
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .labelLarge,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      // ค่อยมาเปลี่ยนเป็น data1-data2 (sex-year)
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            pet['sex'] +
                                                                ' - ' +
                                                                pet['age'],
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayMedium,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const Spacer(),
                                                          //add logic if status=safe then green
                                                          if (pet['status'] !=
                                                                  null &&
                                                              pet['status'] !=
                                                                  "")
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          11,
                                                                      vertical:
                                                                          1.5),
                                                              decoration: BoxDecoration(
                                                                  color: pet['status'] ==
                                                                          'Lost'
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .green,
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                              child: Text(
                                                                pet['status'],
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .displaySmall,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 60,
                                          right: 60,
                                          child: GestureDetector(
                                            onTap: () {
                                              _showDeleteConfirmationDialog(
                                                  context, pet['id']);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              child: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 27,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      )
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const BottomNavPage(
                        //       page: 1,
                        //     ),
                        //   ),
                        // );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w500),
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
                        // SaveProfile();
                        _saveChanges();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffC8A48A)),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xffFFFFFF),
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      // No casting needed
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveChanges() async {
    bool isValid = true;
    String updateAddr, updateImg;
    await SaveProfile();

    if (_username == '' || _username.isEmpty) {
      _showDialog("Username");
      isValid = false;
      // } else if (_address == '' || _address.isEmpty) {
      //   _showDialog("Address");
      //   isValid = false;
    } else if (_phone == '' || _phone.isEmpty) {
      _showDialog("Phone number");
      isValid = false;
    } else if (_phone.length < 9) {
      // Check if phone has fewer than 9 digits
      _showError("Phone number must be 9 or 10 digits");
      isValid = false;
    }

    // If any of the fields are invalid, return early to avoid updating with empty values.
    if (!isValid) return;

    if (_newAddress == '') {
      updateAddr = _address;
    } else {
      print('newAddress updated');
      updateAddr = _newAddress;
    }

    if (imgUrl == '' || imgUrl == null) {
      updateImg = _image;
    } else {
      updateImg = imgUrl!;
    }

    print('Updated username: $_username');
    print('Updated address: $updateAddr');
    print('Updated phone: $_phone');
    print('Updated img: $updateImg');

    // Delete all pets in the deleted list
    for (String petId in _deletedPetIds) {
      try {
        final response = await Caller.dio.delete("/pet/$petId");
        if (response.statusCode == 200) {
          print('Pet with ID: $petId deleted successfully from API');
        } else {
          print('Failed to delete pet with ID: $petId');
        }
      } catch (e) {
        print('Error occurred while deleting pet with ID: $petId: $e');
      }
    }

    // Reset the deleted pet IDs list
    _deletedPetIds.clear();

    // Proceed with the API call to update user data
    // print(_image);
    // print(imgUrl);
    try {
      final response = await Caller.dio.put(
        "/user/$_uid",
        data: {
          "username": _username,
          "address": updateAddr,
          "phone": _phone,
          "image": updateImg,
        },
      );

      if (response.statusCode == 200) {
        print('User data updated successfully');
        // Optionally, show a success message or navigate back
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const BottomNavPage(
        //       page: 1,
        //     ),
        //   ),
        // );
        Navigator.pop(context);
      } else {
        print('Failed to update user data: ${response.statusCode}');
        _showError("Failed to update user data. Please try again.");
      }
    } catch (e) {
      print('Error occurred while updating user data: $e');
      _showError("An error occurred. Please try again later.");
    }
  }

  Future _showDialog(String show) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Invalid ' + show,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: const Color(0xff333333)),
          ),
          content: Text(
            show + ' should not be empty.',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffC8A48A)),
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

  Future<void> _showError(String show) async {
    if (mounted) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Error',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: const Color(0xff333333)),
            ),
            content: Text(
              show,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffC8A48A)),
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
    } else {
      // Handle the case where the widget is not mounted, if necessary.
      print("Widget is not mounted, cannot show dialog.");
      return Future.value();
    }
  }
}
