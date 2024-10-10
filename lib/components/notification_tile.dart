import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/pages/tracking_page.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/services/noti/send_noti_service.dart';
import 'package:nonghai/types/noti_info.dart';
import 'package:nonghai/types/noti_object_data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationTile extends StatefulWidget {
  final String notiId;

  const NotificationTile({
    super.key,
    required this.notiId,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  TrackingNotiInfo? trackerNotiInfo;
  NotificationObject? notiObject;
  bool isLoading1 = true;
  bool isLoading2 = true;

  getNotiData() async {
    print('getNotiData for notiId: ${widget.notiId}');
    try {
      final response = await Caller.dio.get(
        '/notification/getNotification',
        data: {"noti_id": widget.notiId},
      );

      if (response.statusCode == 200) {
        setState(() {
          notiObject = NotificationObject.fromJson(response.data['data']);
          isLoading1 = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
  }

  getNotificationData() async {
    print('getNotificationData for notiId: ${widget.notiId}');
    try {
      final resp = await Caller.dio.get(
        '/tracking/getTrackingById',
        data: {"tracking_id": notiObject?.trackingId},
      );

      if (resp.statusCode == 200) {
        setState(() {
          trackerNotiInfo = TrackingNotiInfo.fromJson(resp.data['data']);
          isLoading2 = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred on get noti data: $e');
      }
    }
  }

  handleTap() async {
    SendNotiService().readNotification(widget.notiId);

    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => TrackingPage(
        petId: notiObject?.petId ?? 'Unknown Pet',
        petName: trackerNotiInfo?.petName ?? 'Unknown Pet',
        petImage: trackerNotiInfo?.petImage ?? '',
      ),
    );
    Navigator.of(context).push(materialPageRoute).then((value) {
      // Refresh data when returning from TrackingPage
      setState(() {
        isLoading1 = true; // Reset loading states
        isLoading2 = true;
      });
      getNotiData().then((_) {
        getNotificationData();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getNotiData().then((value) {
        getNotificationData();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading1 || isLoading2) {
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
              color: notiObject!.isRead ? Colors.grey[200] : Colors.pink[200],
              size: 11,
            ),
          ],
        ),
      ),
    );
  }
}
