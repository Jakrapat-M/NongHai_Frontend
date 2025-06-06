import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/components/tracking_object.dart';
import 'package:nonghai/main.dart';
import 'package:nonghai/services/caller.dart';
import 'package:nonghai/services/noti/noti_service.dart';
import 'package:nonghai/types/tracking_info.dart';

// ignore: must_be_immutable
class TrackingPage extends StatefulWidget {
  final String petId;
  String? petName;
  String? petImage;
  TrackingPage({super.key, required this.petId, this.petName, this.petImage});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  bool isLoading = true;
  String loadName = '';
  String loadImage = '';
  List<TrackingInfo> trackingInfo = [];
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;
  void getTracking() async {
    try {
      final resp = await Caller.dio.get(
        '/tracking/getTracking?petId=${widget.petId}',
      );
      if (resp.statusCode == 200) {
        setState(() {
          trackingInfo = resp.data['data']['tracking_info']
              .map<TrackingInfo>((e) => TrackingInfo.fromJson(e))
              .toList();
        });
        isLoading = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
  }

  void getPetInfo() async {
    try {
      final resp = await Caller.dio.get(
        '/pet/${widget.petId}',
      );
      if (resp.statusCode == 200) {
        setState(() {
          widget.petName = resp.data['data']['name'];
          widget.petImage = resp.data['data']['image'];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error occurred: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize notification service and setup listeners
    NotificationService(navigatorKey: navigatorKey).initialize();
    _setupFirebaseListeners();

    if (widget.petName == null ||
        widget.petImage == null ||
        widget.petName!.isEmpty ||
        widget.petImage!.isEmpty) {
      getPetInfo();
    }
    getTracking();
  }

  @override
  void dispose() {
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();
    super.dispose();
  }

  void _setupFirebaseListeners() {
    _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data['navigate_to'] == 'tracking') {
        getTracking();
      }
    });

    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      NotificationService(navigatorKey: navigatorKey).handleMessage(message);
    });
  }

  ImageProvider getImage() {
    if (widget.petImage == null || widget.petImage!.isEmpty) {
      return const AssetImage("assets/images/Logo.png");
    } else {
      return NetworkImage(widget.petImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(title: 'Tracking'),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundImage: getImage(),
              ),
              const SizedBox(height: 15),
              Text(
                widget.petName ?? loadName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: trackingInfo.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 330),
                              child: TrackingObject(
                                key: Key(trackingInfo[index].trackingId),
                                username: trackingInfo[index].finderName,
                                phone: trackingInfo[index].finderPhone,
                                address: trackingInfo[index].address,
                                lat: trackingInfo[index].lat,
                                long: trackingInfo[index].long,
                                chat: trackingInfo[index].finderChat,
                                image: trackingInfo[index].finderImage,
                                dateTime: trackingInfo[index].createdAt,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
