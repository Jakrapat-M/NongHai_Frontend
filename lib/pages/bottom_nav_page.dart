import 'dart:async'; // Import Timer class
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/main.dart';
import 'package:nonghai/pages/chat/chat_home_page.dart';
import 'package:nonghai/pages/auth/home_page.dart';
import 'package:nonghai/pages/notification_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/services/noti/noti_service.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key, required this.page});
  final int page;

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  final uid = AuthService().getCurrentUser()!.uid;
  bool hasUnreadMessages = false;
  bool hasUnreadNotifications = false;
  int _selectedPageIndex = 0;
  Timer? _refreshTimer;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.page;

    // Initialize notification service and setup listeners
    NotificationService(navigatorKey: navigatorKey).initialize();
    _setupFirebaseListeners();

    // Initial data fetch
    checkAllReadChat();
    checkAllReadNotification();

    // Start periodic refresh every X seconds
    _startAutoRefresh(const Duration(seconds: 10)); // Adjust the duration as needed
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancel the timer to prevent memory leaks
    _onMessageSubscription?.cancel(); // Cancel the Firebase onMessage listener
    _onMessageOpenedAppSubscription?.cancel(); // Cancel the Firebase onMessageOpenedApp listener
    super.dispose();
  }

  void _startAutoRefresh(Duration interval) {
    _refreshTimer = Timer.periodic(interval, (timer) {
      checkAllReadChat();
      checkAllReadNotification();
    });
  }

  Future<void> checkAllReadChat() async {
    try {
      final resp = await Caller.dio.get('/chat/hasUnreadMessage?userId=$uid');
      setState(() {
        hasUnreadMessages = resp.data['data'];
      });
    } on Exception catch (e) {
      debugPrint('Error checking unread messages: $e');
    }
  }

  Future<void> checkAllReadNotification() async {
    try {
      final resp = await Caller.dio.get('/notification/hasUnreadNotification?userID=$uid');
      setState(() {
        hasUnreadNotifications = resp.data['data'];
      });
    } on Exception catch (e) {
      debugPrint('Error checking unread notifications: $e');
    }
  }

  void _setupFirebaseListeners() {
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await checkAllReadChat();
      await checkAllReadNotification();
    });

    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      NotificationService(navigatorKey: navigatorKey).handleMessage(message);
    });
  }

  void _showCenteredSnackbar(String message) {
    final snackBar = SnackBar(
      content: Center(child: Text(message)),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildIconWithBadge(IconData icon, bool showBadge) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 28),
        if (showBadge)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const ChatHomePage(),
    const HomePage(),
    const NotificationPage(),
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
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildIconWithBadge(Icons.chat_outlined, hasUnreadMessages),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: SizedBox.shrink(), // Empty space for the middle item
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildIconWithBadge(Icons.notifications_none_rounded, hasUnreadNotifications),
                label: 'Notifications',
              ),
            ],
            currentIndex: _selectedPageIndex,
            onTap: (index) {
              setState(() {
                _selectedPageIndex = index;
                if (index == 0) hasUnreadMessages = false;
                if (index == 2) hasUnreadNotifications = false;
              });
            },
            selectedIconTheme: Theme.of(context).appBarTheme.iconTheme,
            unselectedIconTheme: Theme.of(context).appBarTheme.iconTheme,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
          ),
        ),
        SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.02,
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: FloatingActionButton(
                    elevation: 1,
                    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                    shape: const CircleBorder(),
                    onPressed: () {
                      setState(() {
                        _selectedPageIndex = 1; // Navigate to Home page
                      });
                    },
                    child: const Image(
                      image: AssetImage('assets/images/Logo.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
