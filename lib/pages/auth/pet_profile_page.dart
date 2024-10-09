import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  bool _isLoading = true;
  String _errorMessage = '';
  bool isSafe = true;
  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    fetchPetDetails();
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
          print(isOwner);
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

    return Scaffold(
      appBar: AppBar(
        // title: Text(petDetails['name'] ?? 'Pet Details'),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(50, 0, 20, 0),
          child: Row(
            children: [
              Icon(
                petDetails['status'] == 'Safe'
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color:
                    petDetails['status'] == 'Safe' ? Colors.green : Colors.red,
                size: 30,
              ),
              const Padding(padding: EdgeInsets.all(8)),
              Text(
                petDetails['status'] == 'Safe' ? 'SAFE' : 'LOST',
                style: TextStyle(
                    color: petDetails['status'] == 'Safe'
                        ? Colors.green
                        : Colors.red,
                    fontSize: 30),
              ),
              // Icon(
              //   isOwner
              //       ? Icons.map
              //       : Icons.error_outline_rounded,
              //   color:
              //       petDetails['status'] == 'Safe' ? Colors.green : Colors.red,
              //   size: 30,
              // ),
              const Spacer(),
              isOwner == true
                  ? ElevatedButton(
                      onPressed: () {
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
                      child: const Text('track'))
                  // ? AssetImage(
                  //     'assets/images/location_track.png',
                  //     width: 10, // Adjust width as needed
                  //     height: 10, // Adjust height as needed
                  //     color: petDetails['status'] == 'Safe'
                  //         ? Colors.green
                  //         : Colors.red,
                  //   )
                  : const SizedBox
                      .shrink(), // This will show nothing if isOwner is false
            ],
          ),
        ),
        backgroundColor: const Color(0xfff2f2f2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 15),
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
                    color: petDetails['status'] == 'Safe'
                        ? Colors.green
                        : Colors.red),
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

                    // Row(
                    //   children: [
                    //     Container(
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(50),
                    //           color: Colors.white),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         children: [
                    //           Text(
                    //             'Eyes',
                    //             style: Theme.of(context).textTheme.titleSmall,
                    //           ),
                    //           const Spacer(),
                    //           Text(
                    //             petDetails['eyes'],
                    //             // "Yellow",
                    //             style: Theme.of(context).textTheme.titleMedium,
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //     Container(
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(50),
                    //           color: Colors.white),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         children: [
                    //           Text(
                    //             'Blood Type',
                    //             style: Theme.of(context).textTheme.titleSmall,
                    //           ),
                    //           const Spacer(),
                    //           Text(
                    //             petDetails['blood_type'],
                    //             style: Theme.of(context).textTheme.titleMedium,
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    //                   if (isOwner)
                    //                     Column(
                    //                       children: [
                    //                         Row(
                    //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                           children: [
                    //                             Text(
                    //                               'SAFE',
                    //                               style: TextStyle(
                    //                                 fontSize: 18,
                    //                                 fontWeight: FontWeight.bold,
                    //                                 color: isSafe ? Colors.green : Colors.red,
                    //                               ),
                    //                             ),
                    //                             Switch(
                    //                               value: isSafe,
                    //                               onChanged: (value) {
                    //                                 setState(() {
                    //                                   isSafe = value;
                    //                                 });
                    //                                 // You might want to send this updated status to your backend here.
                    //                               },
                    //                               activeColor: Colors.green,
                    //                               inactiveThumbColor: Colors.red,
                    //                             ),
                    //                           ],
                    //                         ),
                    //                         const Row(
                    //                           mainAxisAlignment: MainAxisAlignment.center,
                    //                           children: [
                    //                             Text(
                    //                               "Report pet lost status*",
                    //                               style: TextStyle(
                    //                                   color: Color(0xff5C5C5C),
                    //                                   fontFamily: 'Fredoka',
                    //                                   fontSize: 11,
                    //                                   fontWeight: FontWeight.w400),
                    //                             )
                    //                           ],
                    //                         )
                    //                       ],
                    //                     ),
                    //                   Padding(
                    //                     padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                    //                     child: Column(
                    //                       crossAxisAlignment: CrossAxisAlignment.center,
                    //                       children: [
                    //                         Text("Additional note",
                    //                             style:
                    //                                 Theme.of(context).textTheme.headlineSmall),
                    //                         Container(
                    //                           padding: EdgeInsets.all(8),
                    //                           height: 200,
                    //                           width: double.infinity,
                    //                           decoration: BoxDecoration(
                    //                               borderRadius: BorderRadius.circular(50),
                    //                               color: Colors.white),
                    //                           child: Text(
                    //                             petDetails['note'],
                    //                             style: Theme.of(context).textTheme.titleMedium,
                    //                           ),
                    //                         )
                    //                       ],
                    //                     ),
                    //                   )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
