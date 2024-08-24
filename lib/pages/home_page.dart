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
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              // sign out button
              onPressed: signOut,
              icon: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
    );
  }
}
