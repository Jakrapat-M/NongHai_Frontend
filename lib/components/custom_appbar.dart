import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
      centerTitle: Theme.of(context).appBarTheme.centerTitle,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: Theme.of(context).appBarTheme.elevation,
      iconTheme: Theme.of(context).appBarTheme.iconTheme,
      leadingWidth: 100,
      leading: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 30),
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 36),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}