import 'package:dio/dio.dart' as Dio;
import 'package:iltfret/api/dio.dart';

class ApiRequest {
  static Future<Dio.Response?> register(data) async {
    try {
      Dio.Options options = Dio.Options(
        contentType: Dio.Headers.jsonContentType,
        validateStatus: (status) {
          return status! < 500; // Ignorer les codes d'état 500
        },
      );
      Dio.Response? response =
          await dio().post('/register', data: data, options: options);

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      throw Exception(" $e Erreur lors de l'inscription");
    }
    return null;
  }

  static Future<Dio.Response?> login(data) async {
    try {
      Dio.Options options = Dio.Options(
        contentType: Dio.Headers.jsonContentType,
        validateStatus: (status) {
          return status! < 500; // Ignorer les codes d'état 500
        },
      );
      Dio.Response? response =
          await dio().post('/login', data: data, options: options);

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      throw Exception(" $e Erreur lors de la connexion");
    }
    return null;
  }
}
