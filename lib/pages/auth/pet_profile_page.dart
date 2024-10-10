// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, prefer_const_constructors, duplicate_ignore

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nonghai/pages/tracking_page.dart';
import 'dart:convert';

import '../../services/caller.dart';

class PetProfilePage extends StatefulWidget {
  final String petID;

  const PetProfilePage({super.key, required this.petID});

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  Map<String, dynamic> petDetails = {};
  Map<String, dynamic> ownerData = {};
  bool _isLoading = true;
  String _errorMessage = '';
  bool isSafe = true;
  bool isOwner = false;
  String? phone;

  @override
  void initState() {
    super.initState();
    fetchPetDetails();
    // fetchOwnerData(petDetails['user_id']);
  }

  String formatDateOfBirth(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('d MMMM yyyy').format(date);
  }

  Future<void> fetchPetDetails() async {
    try {
      final response = await Caller.dio.get("/pet/${widget.petID}");

      if (response.statusCode == 200) {
        setState(() {
          petDetails = response.data['data'];
          _isLoading = false;

          // Check if the current logged-in user is the owner
          final currentUserId = FirebaseAuth.instance.currentUser!.uid;
          isOwner = currentUserId == petDetails['user_id'];

          // If the current user is not the owner, fetch the owner's data
          if (!isOwner) {
            fetchOwnerData(petDetails['user_id']);
          }
          //อย่าลืมลบออก
          fetchOwnerData(petDetails['user_id']);
          print(ownerData['phone']);

          // print(isOwner);
          // print(isSafe);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch pet details: ${response.statusCode}';
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

  Future<void> fetchOwnerData(String ownerId) async {
    try {
      final response = await Caller.dio.get("/user/$ownerId");

      if (response.statusCode == 200) {
        setState(() {});
        print(ownerData);
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch owner details: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error occurred while fetching owner details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var image = petDetails['image'];
    print(petDetails);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("tttt"),
    //   ),
    // );
    String? fetchedPhone = ownerData['phone'];

    if (fetchedPhone != null && fetchedPhone.isNotEmpty) {
      if (fetchedPhone.contains('/')) {
        phone = fetchedPhone.split('/').last; // Get the part after '/'
      } else {
        phone = fetchedPhone; // No '/' present, use the full phone number
      }
    } else {
      phone = 'No phone available'; // Provide a default or fallback value
    }
    print(phone);

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
              isOwner == true
                  // ? ElevatedButton(onPressed: () {}, child: Text('track'))
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackingPage(
                              petId: widget.petID,
                              petName: petDetails['name'],
                              petImage: petDetails['image'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xffE8E8E8)),
                        padding: const EdgeInsets.all(7),
                        child: Image.asset(
                          'assets/images/location_track.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                    )
                  : const SizedBox
                      .shrink(), // This will show nothing if isOwner is false
            ],
          ),
        ),
        backgroundColor: const Color(0xfff2f2f2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                  child: CircleAvatar(
                    radius: 125,
                    backgroundImage: (image != null && image != '')
                        ? NetworkImage(image) // Load image from URL
                        : const AssetImage('assets/images/meme1.jpg')
                            as ImageProvider, // Fallback to a placeholder if _image is empty
                    // backgroundImage: AssetImage('assets/images/meme1.jpg'),
                  ),
                ),
              ),
              Text(
                petDetails['name'],
                style: Theme.of(context).textTheme.headlineLarge,
                overflow: TextOverflow.clip,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  petDetails['animal_type'] + " | " + petDetails['breed'],
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: isSafe ? Colors.green : Colors.red),
                // decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(50),
                //     color: Colors.red),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                child: Text(
                  petDetails['sex'],
                  style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'age',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    petDetails['age'],
                                    style: const TextStyle(
                                        color: Color(0xff333333),
                                        fontSize: 20,
                                        fontFamily: 'Fredoka',
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'weight',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${petDetails['weight']} kg',
                                    style: const TextStyle(
                                        color: Color(0xff333333),
                                        fontSize: 20,
                                        fontFamily: 'Fredoka',
                                        fontWeight: FontWeight.w600),
                                  )
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
                          padding: const EdgeInsets.fromLTRB(22, 5, 0, 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Date of birth',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    formatDateOfBirth(
                                        petDetails['date_of_birth'] ?? ''),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 5, 0, 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Hair Color',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                petDetails['hair_color'],
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign
                                    .center, // Center the text in the second part
                              ),
                            ),
                          ],
                        ),
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
                                padding:
                                    const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                child: Row(
                                  children: [
                                    Text(
                                      'Eyes',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const Spacer(),
                                    Text(petDetails['eyes'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        overflow: TextOverflow.ellipsis)
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
                                padding:
                                    const EdgeInsets.fromLTRB(11, 5, 11, 5),
                                child: Row(
                                  children: [
                                    Text(
                                      'Blood Type',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const Spacer(),
                                    Text(
                                      petDetails['blood_type'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Switch(
                                      value: isSafe,
                                      onChanged: (value) {
                                        setState(() {
                                          isSafe = value;
                                        });
                                        // You might want to send this updated status to your backend here.
                                      },
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.red,
                                    ),
                                    const Padding(padding: EdgeInsets.all(5)),
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
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Additional note",
                              style: Theme.of(context).textTheme.headlineSmall),
                          const Padding(padding: EdgeInsets.all(3)),
                          Container(
                            padding: const EdgeInsets.all(20),
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white),
                            child: SingleChildScrollView(
                              child: Text(
                                petDetails['note'],
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              if (!isOwner)
                Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                    child: Column(children: [
                      Row(
                        children: [
                          const Text(
                            "OWNER : ",
                            style: TextStyle(
                                color: Color(0xff5C5C5C),
                                fontFamily: 'Fredoka',
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            ownerData['username'] ?? 'Unknown',
                            style: const TextStyle(
                                color: Color(0xff2C3F50),
                                fontFamily: 'Fredoka',
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: (ownerData['image'] != null &&
                                      ownerData['image'] != '')
                                  ? NetworkImage(
                                      ownerData['image']) // Load image from URL
                                  : const AssetImage('assets/images/meme1.jpg')
                                      as ImageProvider, // Fallback to a placeholder if _image is empty
                              // backgroundImage: AssetImage('assets/images/meme1.jpg'),
                            ),
                            const Padding(padding: EdgeInsets.all(15)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Address",
                                  style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff5C5C5C)),
                                ),
                                Text(
                                  ownerData['address'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff000000),
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                                const Padding(padding: EdgeInsets.all(4)),
                                const Text(
                                  "Phone",
                                  style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff5C5C5C)),
                                ),
                                Text(
                                  phone!,
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff000000),
                                  ),
                                  overflow: TextOverflow.clip,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // First icon button
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white, // Background color
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.message_outlined,
                                color: isSafe
                                    ? const Color(0xff5DB671)
                                    : const Color(0xffDF2D2D),
                                size: 20,
                              ),
                              onPressed: () {
                                // Action for the first icon button
                              },
                            ),
                          ),
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white, // Background color
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.phone_in_talk_outlined,
                                color: isSafe
                                    ? const Color(0xff5DB671)
                                    : const Color(0xffDF2D2D),
                                size: 20,
                              ),
                              onPressed: () {
                                // Action for the second icon button
                              },
                            ),
                          ),
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white, // Background color
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.location_on_outlined,
                                color: isSafe
                                    ? const Color(0xff5DB671)
                                    : const Color(0xffDF2D2D),
                                size: 20,
                              ),
                              onPressed: () {
                                // Action for the third icon button
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Action for the text button
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.green,
                                backgroundColor: Colors.white, // Text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20), // Rounded edges
                                ),
                                minimumSize: Size(170, 35)),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone_in_talk_outlined,
                                  color: isSafe
                                      ? const Color(0xff5DB671)
                                      : const Color(0xffDF2D2D),
                                  size: 20,
                                ),
                                const Padding(padding: EdgeInsets.all(3)),
                                Text(
                                  "RESCUER",
                                  style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSafe
                                          ? const Color(0xff5DB671)
                                          : const Color(0xffDF2D2D)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "*in case you cannot contact pet-owner, please contact rescuer",
                            style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff5C5C5C)),
                          )
                        ],
                      )
                    ]))
            ],
          ),
        ),
      ),
    );
  }
}
