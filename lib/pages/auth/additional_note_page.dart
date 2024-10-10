import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../services/auth/auth_service.dart';
import '../../services/caller.dart';

class AdditionalNotePage extends StatefulWidget {
  // final void Function()? onTap;
  final Map<String, dynamic>? petData;
  const AdditionalNotePage({super.key, required this.petData});

  @override
  State<AdditionalNotePage> createState() => _AdditionalNotePageState();
}

class _AdditionalNotePageState extends State<AdditionalNotePage> {
  String? _phoneNumber;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the existing note if any
    noteController = TextEditingController(text: widget.petData!['note']);
  }

  @override
  void dispose() {
    noteController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _updateNote() {
    // Update the petData with the new note
    widget.petData!['note'] = noteController.text;

    // Navigate back to the previous page with updated petData
    Navigator.pop(context, widget.petData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Additional Note"),
        titleTextStyle: Theme.of(context).bannerTheme.contentTextStyle,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'Note',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5, // Allow for multiple lines
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateNote, // Update note on button press
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
