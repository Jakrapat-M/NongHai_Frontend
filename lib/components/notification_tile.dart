import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/pages/tracking_page.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/services/noti/send_noti_service.dart';
import 'package:nonghai/types/noti_info.dart';
import 'package:nonghai/types/noti_object_data.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationTile extends StatefulWidget {
  final NotificationObject notiObject;
  const NotificationTile({
    super.key,
    required this.notiObject,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  TrackingNotiInfo? trackerNotiInfo;
  bool isLoading = true;

  getNotificationData() async {
    try {
      final resp = await Caller.dio.get(
        '/tracking/getTrackingById?trackingId=${widget.notiObject.trackingId}',
      );

      if (resp.statusCode == 200) {
        setState(() {
          trackerNotiInfo = TrackingNotiInfo.fromJson(resp.data['data']);
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred on get noti data for: ${widget.notiObject.trackingId} $e');
      }
    }
  }

  handleTap() async {
    SendNotiService().readNotification(widget.notiObject.id!);
    debugPrint('Navigate to TrackingPage with petId: ${widget.notiObject.petId}');
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => TrackingPage(
        petId: widget.notiObject.petId,
      ),
    );
    Navigator.of(context).push(materialPageRoute).then((value) {
      // Refresh data when returning from TrackingPage
      setState(() {
        isLoading = true;
        widget.notiObject.isRead = true;
      });

      getNotificationData();
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getNotificationData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notiObject = widget.notiObject;
    if (isLoading) {
      return const SizedBox();
    }

    final address = trackerNotiInfo?.address ?? 'Unknown';
    String timeAgo = timeago.format(trackerNotiInfo!.createdAt);

    return GestureDetector(
      onTap: () {
        // Navigate to tracking page
        handleTap();
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
              backgroundImage: notiObject.image != null && notiObject.image!.isNotEmpty
                  ? NetworkImage(notiObject.image!)
                  : const AssetImage("assets/images/default_profile.png") as ImageProvider,
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
              color: notiObject.isRead ? Colors.grey[200] : Colors.pink[200],
              size: 11,
            ),
          ],
        ),
      ),
    );
  }
}
