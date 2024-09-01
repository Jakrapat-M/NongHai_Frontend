import 'package:flutter/material.dart';
import 'package:nonghai/services/auth/auth_service.dart';
// import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //sign user out
  void signOut() {
    // get auth service
    final authService = AuthService();
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    const cards = 2;
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
              child: const Center(
                child: Icon(
                  Icons.edit,
                  size: 28,
                  color: Color(0xff333333),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 85, 0, 20),
            child: Column(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 47,
                      backgroundImage: AssetImage('assets/images/meme1.jpg'),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PUN ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "'s family",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(65, 0, 65, 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.home_outlined,
                          size: 25,
                          color: Color(0xff333333),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '154 KingMongkut street, Ladphoa, BangKok',
                          style: TextStyle(fontSize: 16),
                          overflow: TextOverflow.clip,
                        ),
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(65, 0, 65, 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.phone_in_talk_outlined,
                          size: 24,
                          color: Color(0xff333333),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '081-111-1111',
                          style: TextStyle(fontSize: 16),
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
                            itemCount: cards +
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
                              if (index >= cards) {
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
                                    highlightColor: Colors
                                        .transparent, // Remove highlight effect
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
                                );
                              } else {
                                // Regular cards for indices 0 to n-1
                                return Card(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                                          child: Image.asset(
                                            'assets/images/meme2.jpg',
                                            height: 40,
                                            width: 40,
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
                                                    'Card Label $index',
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
                                                    'Female - 1 Year',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium,
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
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceBright,
                                                        shape:
                                                            BoxShape.rectangle,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Text(
                                                      'Safe',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelSmall,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]),
                                      ),
                                    ],
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
    //   ),
    // );

    // appBar: AppBar(
    //   title: const Text("Home"),
    //   actions: [
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //       child: IconButton(
    //         // sign out button
    //         onPressed: signOut,
    //         icon: const Icon(Icons.logout),
    //       ),
    //     ),
    //   ],
    // ),
  }
}
