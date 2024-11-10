// ignore_for_file: unused_field, unused_import, prefer_const_constructors, avoid_print, must_be_immutable, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

import '../../components/custom_button.dart';

class AdditionalNotePage extends StatefulWidget {
  final note;

  const AdditionalNotePage({super.key, required this.note});

  @override
  State<AdditionalNotePage> createState() => _AdditionalNotePageState();
}

class _AdditionalNotePageState extends State<AdditionalNotePage> {
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();

    // Initialize the controller with the existing note if any, or an empty string
    noteController = TextEditingController(text: widget.note);
  }

  @override
  void dispose() {
    noteController.dispose(); // Dispose the controller when no longer needed
    super.dispose();
  }

  void _updateNote() {
    // Retrieve the updated note text
    String newNote = noteController.text;

    // Print for debugging purposes
    print("Updated Note: $newNote");

    // Navigate back to the previous page with the updated note
    Navigator.pop(context, newNote);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Additional Note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: noteController,
                minLines: 6,
                maxLines: null, // Allow unlimited lines
                decoration: InputDecoration(
                  hintText: 'Note',
                  fillColor: const Color(0xffffffff), // White fill color
                  filled: true, // Apply the fill color
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: Colors.transparent, // Transparent border when not focused
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: Colors.transparent, // Transparent border when focused
                    ),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 20),
              CustomButton1(
                text: "Next",
                onTap: _updateNote,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
