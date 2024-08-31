import 'package:flutter/material.dart';
import 'package:nonghai/components/custom_appbar.dart';
import 'package:nonghai/components/tracking_object.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
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
                foregroundImage: const AssetImage('assets/images/test.jpg'),
              ),
              const SizedBox(height: 15),
              Text(
                'Ella',
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
