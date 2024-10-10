import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/types/noti_info.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationTile extends StatefulWidget {
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
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  TrackingNotiInfo? trackerNotiInfo;
  bool isLoading = true;

  getTrackingData() async {
    try {
      final resp = await Caller.dio.get(
        '/tracking/getTrackingById',
        data: {"tracking_id": widget.trackingId},
      );

      if (resp.statusCode == 200) {
        setState(() {
          trackerNotiInfo = TrackingNotiInfo.fromJson(resp.data['data']);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTrackingData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
          width: 50,
          child: SpinKitPulse(
            color: Theme.of(context).colorScheme.primary,
            size: 50.0,
          ),
        ),
      );
    }

    final address = trackerNotiInfo?.address ?? 'Unknown';
    String timeAgo = timeago.format(trackerNotiInfo!.createdAt);

    return GestureDetector(
      onTap: () {
        // Navigate to tracking page
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
              // TODO: Change to pet image
              backgroundImage: const AssetImage("assets/images/default_profile.png"),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nong ${trackerNotiInfo?.petName ?? 'Unknown Pet'} Found",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "Near $address",
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              timeAgo,
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
            ),
            const SizedBox(width: 8.0),
            Icon(
              Icons.circle,
              color: widget.isRead ? Colors.grey[200] : Colors.pink[200],
              size: 11,
            ),
          ],
        ),
      ),
    );
  }
}
