import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
      centerTitle: Theme.of(context).appBarTheme.centerTitle,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: Theme.of(context).appBarTheme.elevation,
      iconTheme: Theme.of(context).appBarTheme.iconTheme,
      leading: Row(
        children: [
          const SizedBox(width: 30),
          SizedBox(
            width: 51,
            height: 51,
            child: Container(
              decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: const Icon(Icons.arrow_back_rounded,size: 36),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
