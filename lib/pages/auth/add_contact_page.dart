// ignore_for_file: avoid_print, unnecessary_null_comparison, use_build_context_synchronously, non_constant_identifier_names

import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nonghai/components/custom_appbar.dart';
// import 'package:nonghai/pages/auth/add_pet_info_page.dart';
import 'package:nonghai/pages/auth/add_pet_profile_page.dart';
import 'package:nonghai/services/auth/add_profile.dart';
import 'package:nonghai/services/location_service.dart';
import 'package:nonghai/services/noti/token_service.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
// import '../../services/auth/auth_service.dart';
import '../../services/caller.dart';

class AddContactPage extends StatefulWidget {
  // final void Function()? onTap;
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  String? _phoneNumber;
  // String? _addr;
  Map<String, dynamic>? userData;
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final addrController = TextEditingController();
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the userData passed from the RegisterPage
    userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      // No casting needed
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _createUser(BuildContext context) async {
    LatLong? latLong;
    if (_phoneNumber == null || _phoneNumber!.length < 13) {
      // 13 = 9+4(+66/)
      // Show a message if the phone number has fewer than 9 digits
      _showMessage("Phone number must be 9 or 10 digits.");
      return;
      // } else if (_addr == null || _addr == "") {
      //   _showMessage("Please get your current location.");
      //   return;
    }

    if (nameController.text.isNotEmpty &&
        surnameController.text.isNotEmpty &&
        addrController.text.isNotEmpty) {
      userData!['phone'] = _phoneNumber!;
      userData!['name'] = nameController.text;
      userData!['surname'] = surnameController.text;
      userData!['address'] = addrController.text;
      // userData!['address'] = _addr!;

      // final authService = AuthService();
      try {
        //get latlong from addr
        latLong = await LocationService().getLatLong(userData!['address']);
        if (latLong != null) {
          userData!['latitude'] = latLong.lat;
          userData!['longitude'] = latLong.lng;
          print('lat: ${userData!['latitude']}, long: ${userData!['longitude']}');
        }

        // Call SaveProfile to upload the profile image and get the updated user data
        if (userData?['image'] != null && userData!['image'].isNotEmpty) {
          userData = await SaveProfile();
        }
        print(userData);

        // Call the createUser API with updated userData
        final response = await Caller.dio.post(
          "/user/createUser",
          data: userData,
        );

        TokenService().createUserToken(userData!['id']);
        // Handle the API response
        if (response.statusCode == 201) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              // ignore: prefer_const_constructors
              builder: (context) => AddPetProfilePage(
                  // userId: userData!['id'], // Pass your userData if needed
                  ),
            ),
            (Route<dynamic> route) => false, // This ensures no previous routes remain
          );
        } else {
          // Handle error from API
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text('API Error',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: const Color(0xff333333))),
              content: Text(
                response.data.toString(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary),
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
            ),
          );
        }
      } catch (e) {
        // Handle errors during the API call or image upload
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('Error',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: const Color(0xff333333))),
            content: Text(
              'Error occurred: ${e.toString()}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
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
          ),
        );
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
      String imgUrl =
          await StoreProfile().saveData(userId: userId, file: imageFile, folderPath: folderPath);

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
    // Future<void> getLocation() async {
    //   setState(() {
    //     isLoading = true;
    //   });
    //   Future<Position?> location = LocationService().getLocation();
    //   location.then((value) async {
    //     if (value != null) {
    //       print('Location: ${value.latitude}, ${value.longitude}');
    //       try {
    //         final resp =
    //             await Caller.dio.post('/tracking/getAddressByLatLng', data: {
    //           'lat': value.latitude,
    //           'lng': value.longitude,
    //         });
    //         if (resp.statusCode == 200) {
    //           setState(() {
    //             _addr = resp.data['data'];
    //             userData!['latitude'] = value.latitude;
    //             userData!['longitude'] = value.longitude;
    //             isLoading = false;
    //           });
    //         }
    //       } catch (e) {
    //         setState(() {
    //           isLoading = false;
    //         });
    //         if (kDebugMode) {
    //           print('Network error occurred: $e');
    //         }
    //       }
    //     }
    //   });
    // }

    print(userData);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(title: "Your Contact"),
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
                obscureText: false,
                hintStyle: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            // get latlong button version
            // TextButton(
            //   style: TextButton.styleFrom(
            //     backgroundColor: Colors.white,
            //     padding:
            //         const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            //   ),
            //   onPressed: getLocation,
            //   child: isLoading
            //       ? Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             CircularProgressIndicator(
            //               color: Theme.of(context).colorScheme.primary,
            //             ),
            //           ],
            //         )
            //       : Row(
            //           children: [
            //             Icon(
            //               Icons.location_on,
            //               color: Theme.of(context).colorScheme.primary,
            //             ),
            //             const SizedBox(width: 8),
            //             Expanded(
            //               child: Padding(
            //                 padding: const EdgeInsets.only(right: 25),
            //                 child: Text(
            //                   _addr ??
            //                       "Get current location", // Display address or default text
            //                   style: const TextStyle(
            //                       color: Color(0xffC8A48A),
            //                       fontFamily: "Fredoka",
            //                       fontSize: 16,
            //                       fontWeight: FontWeight.w500),
            //                   textAlign: TextAlign.center,
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 12),
            //   child: Row(
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 10),
            //         child: SizedBox(
            //           width: MediaQuery.of(context).size.width * 0.80,
            //           child: const Text(
            //             "*if current location is not your home please edit later at the homepage",
            //             style: TextStyle(
            //                 fontFamily: 'Fredoka',
            //                 fontSize: 10,
            //                 fontWeight: FontWeight.w400,
            //                 color: Color(0xffC8A48A)),
            //             overflow: TextOverflow.clip,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
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
                        borderSide: const BorderSide(color: Colors.transparent), // No underline
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.transparent), // No underline when focused
                      ),
                    ),
                    initialCountryCode: 'TH', // Set the initial country code
                    disableLengthCheck: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Allow digits only

                      LengthLimitingTextInputFormatter(10), // Limit input to 10 characters
                    ],

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
