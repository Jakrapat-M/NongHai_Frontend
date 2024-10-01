import 'package:flutter/material.dart';
import 'package:nonghai/pages/chat/chat_home_page.dart';
<<<<<<< HEAD
import 'package:nonghai/pages/auth/home_page.dart';
=======
import 'package:nonghai/pages/home_page.dart';
>>>>>>> Dev

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key, required this.page});
  final int page;

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.page;
  }

  static final List<Widget> _widgetOptions = <Widget>[
    ChatHomePage(),
    const HomePage(),
    const Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Center(
            child: _widgetOptions.elementAt(_selectedPageIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Center(child: Icon(Icons.chat_outlined)),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Empty space for the middle item
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Center(child: Icon(Icons.notifications_none_rounded)),
                label: 'Notifications',
              ),
            ],
            currentIndex: _selectedPageIndex,
            onTap: (index) {
              setState(() {
                _selectedPageIndex = index;
              });
            },
            selectedIconTheme: Theme.of(context).appBarTheme.iconTheme,
            unselectedIconTheme: Theme.of(context).appBarTheme.iconTheme,
            showSelectedLabels: false, // Hide the label of the selected item
            showUnselectedLabels: false, // Hide the labels of unselected items
            elevation: 0,
          ),
        ),
        SafeArea(
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 10),
            child: Positioned(
              bottom: MediaQuery.of(context).size.height *
                  0.02, // Adjust this value to control the pop-out effect
              // left: MediaQuery.of(context).size.width / 2 - 35, // Center the button
              child: SizedBox(
                width: 70,
                height: 70,
                child: FloatingActionButton(
                  elevation: 1,
<<<<<<< HEAD
                  backgroundColor:
                      Theme.of(context).appBarTheme.backgroundColor,
                  shape: const CircleBorder(),
                  onPressed: () {
                    setState(() {
                      _selectedPageIndex =
                          1; // Set to the index of the Home page
=======
                  backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                  shape: const CircleBorder(),
                  onPressed: () {
                    setState(() {
                      _selectedPageIndex = 1; // Set to the index of the Home page
>>>>>>> Dev
                    });
                  },
                  child: const Icon(
                    Icons.home,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
