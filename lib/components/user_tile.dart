import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const UserTile({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(90),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.fromLTRB(6, 6, 32, 6),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              radius: 30,
              backgroundImage: const AssetImage("assets/images/default_profile.png"),
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                ),
                const SizedBox(height: 4.0),
                const Text(
                  "Hello",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),

            const Spacer(),
            // add time and status
            Text("1 hr ago", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(width: 8.0),
            Icon(
              Icons.circle,
              color: Colors.pink[200],
              size: 10,
            ),
          ],
        ),
      ),
    );
  }
}
