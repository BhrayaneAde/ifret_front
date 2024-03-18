import 'package:dio/dio.dart';

Dio dio() {
  Dio dio = Dio();

  dio.options.baseUrl = 'http://10.0.2.2:8000/api';
  dio.options.headers['accept'] = 'Application/json';
  dio.options.connectTimeout = const Duration(seconds: 60);
  dio.options.receiveTimeout = const Duration(seconds: 60);

  return dio;
}
