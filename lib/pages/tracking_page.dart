import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/components/tracking_object.dart';
import 'package:nonghai/services/caller.dart';

class TrackingPage extends StatefulWidget {
  final String petId;
  final String petName;
  final String petImage;
  const TrackingPage(
      {super.key,
      required this.petId,
      required this.petName,
      required this.petImage});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  var trackingData;
  void getTracking() async {
    // fetch data
    try {
      final resp = await Caller.dio.get(
        '/tracking/getTracking?petId=${widget.petId}',
      );
      if (resp.statusCode == 200) {
        setState(() {
          trackingData = resp.data;
        });
        print(resp.data);
      }
    } catch (e) {
      print('Network error occurred: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getTracking();
  }

  @override
  void dispose() {
    super.dispose();
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
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                foregroundImage: AssetImage(widget.petImage),
              ),
              const SizedBox(height: 15),
              Text(
                widget.petName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              const TrackingObject(
                  dateTime: '11:11:00 AM , 11 March 2024',
                  username: 'username',
                  phone: 'phone',
                  chat: 'chat',
                  address:
                      '45 prachautid prachautid prachautid prachautid bangkok thailand '),
              const TrackingObject(
                  dateTime: '11:11:00 AM , 11 March 2024',
                  username: 'username',
                  phone: 'phone',
                  chat: 'chat',
                  address:
                      '45 prachautid prachautid prachautid prachautid bangkok thailand ')
            ],
          ),
        ),
      ),
    );
  }
}
