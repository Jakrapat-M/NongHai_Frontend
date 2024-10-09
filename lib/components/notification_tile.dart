import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final String userId;
  final String petId;
  final String trackingId;
  final bool isRead;

  const NotificationTile({
    super.key,
    required this.userId,
    required this.petId,
    required this.trackingId,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    // return ListTile(
    //   leading: Icon(
    //     isRead ? Icons.notifications : Icons.notifications_active,
    //     color: isRead ? Colors.grey : Colors.blue,
    //   ),
    //   title: Text('Pet ID: $petId'),
    //   subtitle: Text('Tracking ID: $trackingId'),
    //   trailing: isRead
    //       ? const Icon(Icons.check_circle, color: Colors.green)
    //       : const Icon(Icons.circle, color: Colors.red),
    // );
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => TrackingPage(
        //       petId: petId,
        //       petName: 'Pet Name',
        //       petImage: 'Pet Image',
        //     ),
        //   ),
        // );
      },
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pet ID: $petId",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "Tracking ID: $trackingId",
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              "time ago", // from timestamp in tracking info
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
            ),
            const SizedBox(width: 8.0),
            Icon(
              Icons.circle,
              color: isRead ? Colors.grey[200] : Colors.pink[200],
              size: 10,
            ),
          ],
        ),
      ),
    );
  }
}
