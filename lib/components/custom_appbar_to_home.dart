import 'package:flutter/material.dart';
import 'package:nonghai/pages/auth/home_page.dart';

class CustomAppBarToHome extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool? noBackButton;

  const CustomAppBarToHome({super.key, required this.title, this.noBackButton});

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
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const HomePage();
            }));
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}