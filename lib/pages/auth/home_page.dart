// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_typing_uninitialized_variables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nonghai/services/caller.dart';
// import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _username, _address, _phone, _image;
  int _petCount = 0;
  List<dynamic> _pets = [], _petDetails = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String uid = "";

  Future<void> fetchUserData() async {
    uid = FirebaseAuth.instance.currentUser!.uid;

    if (uid == null) {
      setState(() {
        _errorMessage = 'No user is currently signed in.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await Caller.dio.get(
        "/user/$uid",
      );

      // Log the entire API response for debugging
      print('API response data: ${response.data}');

      if (response.statusCode == 200) {
        final userData = response.data;

        // Check if username, phone, and address are null or missing
        if (userData['data'] == null ||
            userData['data']['username'] == null ||
            userData['data']['phone'] == null ||
            userData['data']['address'] == null) {
          throw Exception(
              "Required user data (username, phone, or address) is missing.");
        }

        setState(() {
          _username = userData['data']['username'];
          _address = userData['data']['address'];
          // _phone = userData['data']['phone'];

          // Check if phone contains '/' and extract the number after it
          String fetchedPhone = userData['data']['phone'];
          if (fetchedPhone.contains('/')) {
            _phone = fetchedPhone.split('/').last; // Get the part after '/'
          } else {
            _phone = fetchedPhone; // No '/' present, use the full phone number
          }

          // Log the user data to check what was retrieved
          print('Username: $_username, Address: $_address, Phone: $_phone');

          // Pets data can be null, provide fallback
          _pets = userData['data']['pets'] ?? [];
          _petCount = _pets.length;

          // Map pet details
          _petDetails = _pets.map((pet) {
            return {
              'id': pet['id'],
              'name': pet['name'] ?? 'No name',
              'sex': pet['sex'] ?? 'Unknown',
              'age': pet['age'] != null ? pet['age'].toString() : 'Unknown age',
              'img': pet['image'] ?? '',
            };
          }).toList();

          // Log the pet details to see if they're correctly parsed
          print('Pet details: $_petDetails');

          // Set image, fallback to empty string if null
          _image = userData['data']['image'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch user data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    print(uid);
    // const cards = 2;
    if (_isLoading) {
      // Show a loading spinner while fetching data
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: 58,
            right: 28,
            child: Container(
              width: 45, // Adjust the size as needed
              height: 45, // Adjust the size as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .secondary, // Background color of the circle
              ),
              child: GestureDetector(
                onTap: () async {
                  final authService = AuthService();
                  await authService.signOut();
                  // Navigate to login or handle post-signout logic
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                child: const Center(
                  child: Icon(
                    Icons.edit,
                    size: 28,
                    color: Color(0xff333333),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 85, 0, 20),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 47,
                      backgroundImage: (_image != null && _image != '')
                          ? NetworkImage(_image) // Load image from URL
                          : const AssetImage('assets/images/meme1.jpg')
                              as ImageProvider, // Fallback to a placeholder if _image is empty
                      // backgroundImage: AssetImage('assets/images/meme1.jpg'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_username ',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Fredoka'),
                          ),
                          const Text(
                            "'s family",
                            style:
                                TextStyle(fontSize: 20, fontFamily: 'Fredoka'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(65, 0, 65, 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.home_outlined,
                          size: 25,
                          color: Color(0xff333333),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '$_address',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.clip,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(65, 0, 65, 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.phone_in_talk_outlined,
                          size: 24,
                          color: Color(0xff333333),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '$_phone',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.clip,
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(
                  color: Color.fromARGB(255, 199, 198, 198),
                  thickness: 1.3,
                  indent: 35,
                  endIndent: 35,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(35, 0, 35, 12),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 12),
                          child: Row(
                            children: [
                              Text('Your Family',
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          height: MediaQuery.of(context).size.height * 0.41,
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _petCount +
                                1, // Total number of items (n regular cards + 1 button card)
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 cards per row
                              mainAxisSpacing: 15.0, // Spacing between rows
                              crossAxisSpacing: 12.0, // Spacing between columns
                              childAspectRatio:
                                  2.05 / 2.6, // Aspect ratio of the cards
                            ),
                            itemBuilder: (context, index) {
                              // Check if it's the last index (index n) to place the button card
                              if (index >= _petCount) {
                                return Card(
                                    color: Colors.transparent,
                                    margin: const EdgeInsets.all(8.0),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        // Define your add button action here
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      splashColor: Colors
                                          .transparent, // Remove ripple effect
                                      highlightColor: const Color.fromRGBO(0, 0,
                                          0, 0), // Remove highlight effect
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/addPetProfileImage');
                                        },
                                        child: Center(
                                          child: Container(
                                            width: 55,
                                            height: 55,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                                              //     spreadRadius: 2, // How much the shadow spreads
                                              //     blurRadius: 5, // How soft the shadow is
                                              //     offset: Offset(0, 3), // The position of the shadow (x, y)
                                              //   ),
                                              // ],
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 23,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // ),
                                    ));
                              } else {
                                final pet = _petDetails[index];
                                // Regular cards for indices 0 to n-1
                                return Card(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigate to pet detail page with the pet ID
                                      String petId = pet['id'];
                                      Navigator.pushNamed(
                                          context, '/petProfile',
                                          arguments: petId);
                                    },
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: 155,
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(8),
                                            ),
                                            child: pet['img'] != '' &&
                                                    pet['img'] != null
                                                ? Image.network(
                                                    pet['img'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.asset(
                                                        'assets/images/meme2.jpg', // Default image
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                : Image.asset(
                                                    'assets/images/meme2.jpg', // Default image
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 5, 8, 5),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      pet['name'],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                // ค่อยมาเปลี่ยนเป็น data1-data2 (sex-year)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      pet['sex'] +
                                                          ' - ' +
                                                          pet['age'],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const Spacer(),
                                                    //add logic if status=safe then green
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 11,
                                                          vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .surfaceBright,
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8)),
                                                      child: Text(
                                                        'Safe',
                                                        style: Theme.of(context)
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
                                );
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                )
                // Add other Row widgets here as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
