import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class Caller {
  // Define a static variable for the local IP
  static final String localIp = _getLocalIp();

  // Method to determine the local IP based on the platform
  static String _getLocalIp() {
    if (Platform.isIOS) {
      // Use localhost for iOS Simulator
      return 'IOS_API_URL';
    } else if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to refer to the host machine
      return 'ANDROID_API_URL';
    } else {
      // Fallback for other platforms if needed
      return '127.0.0.1';
    }
  }

  // Create BaseOptions with the appropriate baseUrl
  static BaseOptions options = BaseOptions(
    baseUrl: dotenv.get(_getLocalIp()),
    headers: {
      'Authorization': 'Bearer ${dotenv.get('TOKEN', fallback: '')}',
    },
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  );

  // Instantiate Dio with the options
  static Dio dio = Dio(options);
}
