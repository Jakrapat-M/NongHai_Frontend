import 'package:flutter/material.dart';

class CustomButton1 extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const CustomButton1({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: FilledButton(
          onPressed: onTap,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
            minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
          ),
          child: Text(text),
        ));
    // return GestureDetector(
    //   onTap: onTap,

    //   child: Container(
    //     width: double.infinity,
    //     padding: const EdgeInsets.all(10),
    //     decoration: BoxDecoration(
    //       color: Colors.deepPurple[300],
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //     child: Center(
    //       child: Text(
    //         text,
    //         style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 20),
    //       ),
    //     ),
    //   ),
    // );
  }
}
