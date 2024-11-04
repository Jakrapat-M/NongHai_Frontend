import 'package:flutter/material.dart';
import 'package:nonghai/pages/chat/chat_room_page.dart';
import 'package:nonghai/services/auth/auth_service.dart';
import 'package:nonghai/services/chat/chat_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class TrackingObject extends StatelessWidget {
  final DateTime dateTime;
  final String username;
  final String phone;
  final String chat;
  final String? address;
  final String? image;
  final double? lat;
  final double? long;

  const TrackingObject(
      {super.key,
      required this.dateTime,
      required this.username,
      required this.phone,
      required this.chat,
      this.address,
      this.lat,
      this.long,
      this.image});

  Future<void> _launchMap() async {
    if (lat != null && long != null) {
      Uri url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$long');
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    await launchUrl(launchUri);
  }

  ImageProvider getImage() {
    if (image == null || image!.isEmpty) {
      return const AssetImage("assets/images/Logo.png");
    } else {
      return NetworkImage(image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateTime =
        DateFormat('hh:mm:ss a, dd MMMM yyyy').format(this.dateTime);
    final currentUserId = AuthService().getCurrentUser()!.uid;
    bool isCurrentUser = currentUserId == chat;
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
                          width: 200,
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
                                foregroundImage: getImage(),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Text(
                                  username,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.white,
                            child: isCurrentUser
                                ? IconButton(
                                    icon: const Icon(
                                        Icons.chat_bubble_outline_rounded),
                                    onPressed: () {},
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    iconSize: 18,
                                  )
                                : IconButton(
                                    icon: const Icon(
                                        Icons.chat_bubble_outline_rounded),
                                    onPressed: () {
                                      print('Chatwith $chat');
                                      ChatService().createChatRoom(chat);
                                      MaterialPageRoute materialPageRoute =
                                          MaterialPageRoute(
                                        builder: (context) => ChatRoomPage(
                                          receiverID: chat,
                                        ),
                                      );
                                      // navigate to chat room
                                      Navigator.of(context)
                                          .push(
                                        materialPageRoute,
                                      )
                                          .then((e) {
                                        ChatService().setRead(chat);
                                      });
                                    },
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryFixed,
                                    iconSize: 18,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.white,
                            child: isCurrentUser
                                ? IconButton(
                                    icon: const Icon(Icons.phone_rounded),
                                    onPressed: () {},
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    iconSize: 18,
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.phone_rounded),
                                    onPressed: _makePhoneCall,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryFixed,
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
                            icon: const Icon(
                              Icons.location_on_outlined,
                            ),
                            onPressed: _launchMap,
                            color: Theme.of(context).colorScheme.secondaryFixed,
                            iconSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: Text(
                          address ?? 'No address provided',
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
