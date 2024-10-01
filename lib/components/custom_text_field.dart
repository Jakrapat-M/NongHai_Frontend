import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextStyle? hintStyle;
  final bool obscureText;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.hintStyle,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    final curvedborder = BorderRadius.circular(90);
    return TextField(
      controller: controller,
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
