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
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            itemCount:
                                6, // Total number of items (n regular cards + 1 button card)
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 cards per row
                              mainAxisSpacing: 15.0, // Spacing between rows
                              crossAxisSpacing: 12.0, // Spacing between columns
                              childAspectRatio:
                                  2 / 2.5, // Aspect ratio of the cards
                            ),
                            itemBuilder: (context, index) {
                              // Check if it's the last index (index n) to place the button card
                              if (index >= 5) {
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
                                    child: Center(
                                      child: Container(
                                        width: 55,
                                        height: 55,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
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
                                // Regular cards for indices 0 to n
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
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Card Label $index', // Replace with your label text
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
