import 'package:flutter/material.dart';
import 'package:nonghai/pages/chat_home_page.dart';
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

  static const List<Widget> _widgetOptions = <Widget>[
    ChatHomePage(),
    HomePage(),
    Placeholder(),
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
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Empty space for the middle item
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
            ],
            currentIndex: _selectedPageIndex,
            onTap: (index) {
              setState(() {
                _selectedPageIndex = index;
              });
            },
          ),
        ),
        Positioned(
          bottom: 50, // Adjust this value to control the pop-out effect
          left:
              MediaQuery.of(context).size.width / 2 - 30, // Adjust the offset to center the button
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: const CircleBorder(),
            onPressed: () {
              setState(() {
                _selectedPageIndex = 1; // Set to the index of the Home page
              });
            },
            child: const Icon(Icons.home),
          ),
        ),
      ],
    );
  }
}
