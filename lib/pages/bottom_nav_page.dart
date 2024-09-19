import 'package:flutter/material.dart';
import 'package:nonghai/pages/chat/chat_home_page.dart';
import 'package:nonghai/pages/home_page.dart';

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
        Positioned(
          bottom: 8, // Adjust this value to control the pop-out effect
          left: MediaQuery.of(context).size.width / 2 -
              36, // Adjust the offset to center the button
          child: SizedBox(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              elevation: 1,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              shape: const CircleBorder(),
              onPressed: () {
                setState(() {
                  _selectedPageIndex = 1; // Set to the index of the Home page
                });
              },
              child: const Icon(
                Icons.home,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
