import 'package:dio/dio.dart';

Dio dio() {
  Dio dio = Dio();
//ios
  // dio.options.baseUrl = 'http://10.0.2.2:8000/api';
  //android
  dio.options.baseUrl = 'http://10.0.2.2:8000/api';
  dio.options.headers['accept'] = 'Application/json';
  dio.options.connectTimeout = const Duration(minutes: 10);
  dio.options.receiveTimeout = const Duration(minutes: 10);

  return dio;
}
