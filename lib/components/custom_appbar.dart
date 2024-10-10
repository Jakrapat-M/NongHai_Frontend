import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? noBackButton;

  const CustomAppBar({super.key, required this.title, this.noBackButton});

  @override
  Widget build(BuildContext context) {
    if (noBackButton == null || noBackButton == false) {
      return AppBar(
        title: Text(
          title,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: Theme.of(context).appBarTheme.centerTitle,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        leadingWidth: MediaQuery.of(context).size.width * 0.2,
        leading: GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamed(context, '/');
            }
          },
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20),
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
        ),
      );
    } else {
      return AppBar(
        title: Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
        centerTitle: Theme.of(context).appBarTheme.centerTitle,
        backgroundColor: Colors.transparent,
        elevation: Theme.of(context).appBarTheme.elevation,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
