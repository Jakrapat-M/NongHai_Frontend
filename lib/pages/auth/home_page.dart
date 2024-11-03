// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_typing_uninitialized_variables, unnecessary_null_comparison, curly_braces_in_flow_control_structures

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:nonghai/pages/auth/login_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/auth/auth_service_inherited.dart';
// import 'package:nonghai/services/auth/login_or_registoer.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/pages/bottom_nav_page.dart';
// import 'package:nonghai/services/navigatorObserver.dart';
import 'edit_home_page.dart';
// import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AuthService authService = AuthService();
  var _username, _address, _phone, _image;
  int _petCount = 0;
  List<dynamic> _pets = [], _petDetails = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String uid = "";
  bool _hasError = false;
  // var profileImageUrl;
  bool _showOptions = false;
  //  bool _isEditing = false;
  final MyRouteObserver myRouteObserver = MyRouteObserver();

  // Function to handle user account deletion
  void _deleteUser(BuildContext context) async {
    final authService = AuthServiceInherited.of(context)?.authService;

    if (authService != null) {
      try {
        await authService.signInWithCustomToken(context);
        await authService.deleteUser(context);
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) =>
        //           const LoginOrRegistoer()), // replace with the actual route for your register page
        //   (Route<dynamic> route) => false, // Remove all previous routes
        // );
      } catch (e) {
        _showMessage(e.toString());
      }
    } else {
      _showMessage('AuthService not available.');
    }
  }

  Future<void> fetchUserData(BuildContext context) async {
    uid = FirebaseAuth.instance.currentUser!.uid;
    print(uid);

    try {
      final response = await Caller.dio.get("/user/$uid");

      // Log the entire API response for debugging
      print('API response data: ${response.data}');

      if (response.statusCode == 200 && mounted) {
        final userData = response.data;

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
          String fetchedPhone = userData['data']['phone'];
          _phone = fetchedPhone.contains('/')
              ? fetchedPhone.split('/').last
              : fetchedPhone;
          _pets = userData['data']['pets'] ?? [];
          _petCount = _pets.length;
          _petDetails = _pets.map((pet) {
            return {
              'id': pet['id'],
              'name': pet['name'] ?? 'No name',
              'sex': pet['sex'] ?? 'Unknown',
              'age': pet['age'] != null ? pet['age'].toString() : 'Unknown age',
              'img': pet['image'] ?? '',
              'status': pet['status'] != null ? pet['status'].toString() : ''
            };
          }).toList();
          _image = userData['data']['image'] ?? '';
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to fetch user data: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("error: $e");
      if (uid == null) {
        if (mounted) {
          _errorMessage =
              'Error occurred while logging in, Please try again later.';
          // Use the context passed to this method for the dialog
          _showErrorDialog(context, _errorMessage);
          setState(() {
            _isLoading = false;
          });
        }
      } else if (uid != null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Error occurred while registering, Please register again.';
            _hasError = true; // Set error state to true
          });

          // Print the error message
          print(_errorMessage);
        }
      }
    }
  }

// Function to show error dialog
  void _showErrorDialog(BuildContext dialogContext, String message) {
    showDialog(
      context: dialogContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('An Error Occurred'),
          content: Text(message),
          actions: [
            if (uid == null)
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushReplacementNamed(dialogContext, '/');
                  }
                },
                child: const Text('Go back to login'),
              ),
            if (uid != null)
              TextButton(
                onPressed: () async {
                  // Close the dialog
                  Navigator.of(dialogContext).pop();

                  // Ensure _deleteUser is called only if still mounted
                  if (mounted) {
                    _deleteUser(context);
                  }
                },
                child: const Text('Go to register'),
              ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    print(uid);
    // const cards = 2;
    if (_isLoading) {
      // Show a loading spinner while fetching data
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage), // Display error message
              TextButton(
                onPressed: () async {
                  // Close the dialog
                  // Navigator.of(context).pop();

                  // Ensure _deleteUser is called only if still mounted
                  if (mounted) {
                    _deleteUser(context);
                  }
                },
                child: const Text('Go to register'),
              ),
            ],
          ),
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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 58,
              right: 28,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showOptions = !_showOptions;
                  });
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 28,
                      color: Color(0xff333333),
                    ),
                  ),
                ),
              ),
            ),
            if (_showOptions)
              Positioned(
                top:
                    110, // Adjust this to position the icons below the first button
                right: 28,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate to edit page or perform edit action
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => EditHomePage(
                              userData: {
                                'id': uid,
                                'username': _username,
                                'address': _address,
                                'phone': _phone,
                                'image': _image,
                                'pets': _petDetails,
                                // 'profileImageUrl': profileImageUrl,
                              },
                            ),
                          ),
                        )
                            .then((value) {
                          // Refresh the page after editing
                          setState(() {
                            _isLoading = true;
                            fetchUserData(context);
                          });
                        });
                        setState(() {
                          _showOptions = false;
                        });
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.edit,
                            size: 28,
                            color: Color(0xff333333),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // Spacing between the buttons
                    GestureDetector(
                      onTap: () async {
                        final authService = AuthService();
                        await authService.signOut();
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                        setState(() {
                          _showOptions = false;
                        });
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.logout,
                            size: 28,
                            color: Color(0xff333333),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 85, 0, 0),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 47,
                        backgroundImage: (_image != null && _image != '')
                            ? NetworkImage(_image) // Load image from URL
                            : const AssetImage(
                                    'assets/images/default_profile.png')
                                as ImageProvider, // Fallback to a placeholder if _image is empty
                        // backgroundImage: AssetImage('assets/images/meme1.jpg'),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(35, 10, 35, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.58),
                              child: Text(
                                '$_username ',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Fredoka'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text(
                              "'s family",
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'Fredoka'),
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
                            height: MediaQuery.of(context).size.height * 0.46,
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _petCount +
                                  1, // Total number of items (n regular cards + 1 button card)
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 cards per row
                                mainAxisSpacing: 15.0, // Spacing between rows
                                crossAxisSpacing:
                                    12.0, // Spacing between columns
                                childAspectRatio:
                                    2.05 / 2.6, // Aspect ratio of the cards
                              ),
                              itemBuilder: (context, index) {
                                // Check if it's the last index (index n) to place the button card
                                if (index >= _petCount || _petCount == 0) {
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
                                        highlightColor: const Color.fromRGBO(0,
                                            0, 0, 0), // Remove highlight effect
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
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: GestureDetector(
                                      onTap: () async {
                                        // Navigate to pet detail page with the pet ID
                                        String petId = pet['id'];

                                        // Check if the widget is still mounted before navigation
                                        if (mounted) {
                                          await Navigator.pushNamed(
                                              context, '/petProfile',
                                              arguments: petId);

                                          // Check if the widget is still mounted before navigating again
                                          if (mounted) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const BottomNavPage(
                                                  page: 1,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
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
                                                  const BorderRadius.vertical(
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
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return const Center(
                                                            child: Text(
                                                              'No preview image',
                                                              style: TextStyle(
                                                                fontSize: 16,
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
                                                      Container(
                                                        constraints: BoxConstraints(
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.35),
                                                        child: Text(
                                                          pet['name'],
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .labelLarge,
                                                          overflow: TextOverflow
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
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        pet['sex'] +
                                                            ' - ' +
                                                            pet['age'],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const Spacer(),
                                                      //add logic if status=safe then green
                                                      if (pet['status'] !=
                                                              null &&
                                                          pet['status'] != "")
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      11,
                                                                  vertical:
                                                                      1.5),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  pet['status'] ==
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
      ),
    );
  }
}

class MyRouteObserver extends NavigatorObserver {
  String currentRoute = '';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    currentRoute = route.settings.name ?? '';
    print('Current route: $currentRoute');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    currentRoute = previousRoute?.settings.name ?? '';
    print('Current route after pop: $currentRoute');
  }
}
