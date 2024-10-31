import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nonghai/services/caller.dart';

class LocationService {
  Future<Position?> getLocation() async {
    print("test getLocaion");
    bool serviceEnabled;
    LocationPermission permission;

    print('Checking location');
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied");
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }
    print("get location success");

    return await Geolocator.getCurrentPosition();
  }
}
