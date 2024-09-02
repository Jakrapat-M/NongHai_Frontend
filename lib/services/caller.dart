import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Caller {
  static BaseOptions options = BaseOptions(
    baseUrl: dotenv.get('API_URL'),
    headers: {
      'Authorization': 'Bearer ${dotenv.get('TOKEN')}',
    },
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  );

  static Dio dio = Dio(options);
}
