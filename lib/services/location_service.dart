import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nonghai/services/caller.dart';

class LatLong {
  final double lat;
  final double lng;

  LatLong({required this.lat, required this.lng});
}

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

  Future<LatLong?> getLatLong(String address) async {
    //replace space with +
    address = address.replaceAll(' ', '+');
    print("address: $address");

    String? key = dotenv.env['GOOGLE_API_KEY'];
    print("ket: $key");

    double lat = 0;
    double lng = 0;
    try {
      final resp = await Caller.dio.get(
          "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$key");
      if (resp.statusCode == 200) {
        print("getLatLong success");
        lat = resp.data['results'][0]['geometry']['location']['lat'];
        lng = resp.data['results'][0]['geometry']['location']['lng'];
      }
    } catch (e) {
      print("getLatLong error: $e");
    }
    return LatLong(lat: lat, lng: lng);
  }
}
