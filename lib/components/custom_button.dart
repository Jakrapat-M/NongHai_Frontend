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
            backgroundColor:
                WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
            minimumSize:
                WidgetStateProperty.all(const Size(double.infinity, 40)),
          ),
          child: Text(text, style: Theme.of(context).textTheme.labelSmall),
        ));
  }
}
