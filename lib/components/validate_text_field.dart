import 'package:flutter/material.dart';

class ValidateTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextStyle? hintStyle;
  final bool obscureText;
  const ValidateTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.hintStyle,
    required this.obscureText,
    required String? Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    final curvedborder = BorderRadius.circular(90);
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: curvedborder,
          borderSide: BorderSide.none,
        ),

        // enabledBorder: OutlineInputBorder(
        //   borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        // ),
        fillColor: Theme.of(context).colorScheme.tertiary,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: curvedborder,
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        hintText: hintText,
        hintStyle: hintStyle,
      ),
      obscureText: obscureText,
    );
  }
}
