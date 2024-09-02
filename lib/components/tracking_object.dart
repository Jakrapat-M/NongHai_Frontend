import 'package:flutter/material.dart';

class TrackingObject extends StatelessWidget {
  final String dateTime;
  final String username;
  final String phone;
  final String chat;
  final String address;

  const TrackingObject(
      {super.key,
      required this.dateTime,
      required this.username,
      required this.phone,
      required this.chat,
      required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // date Time
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 3, right: 20),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle),
            ),
            Text(dateTime, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),

        // user info
        IntrinsicHeight(
          child: Row(
            children: [
              VerticalDivider(
                color: Theme.of(context).colorScheme.primary,
                thickness: 2,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12.5,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                foregroundImage:
                                    const AssetImage('assets/images/test.jpg'),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Text(username,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon:
                                  const Icon(Icons.chat_bubble_outline_rounded),
                              onPressed: () {},
                              color:
                                  Theme.of(context).colorScheme.secondaryFixed,
                              iconSize: 18,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.phone_rounded),
                              onPressed: () {},
                              color:
                                  Theme.of(context).colorScheme.secondaryFixed,
                              iconSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8, left: 8, right: 16, bottom: 8),
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.location_pin),
                            onPressed: () {},
                            color: Theme.of(context).colorScheme.secondaryFixed,
                            iconSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: Text(
                          address,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
