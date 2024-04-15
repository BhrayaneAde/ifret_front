import 'dart:io';

import 'package:dio/dio.dart' as Dio;
import 'package:dio/dio.dart';
import 'package:ifret/api/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiRequest {
  static Future<Map<String, dynamic>?> register(data) async {
    try {
      Dio.Options options = Dio.Options(
        contentType: Dio.Headers.jsonContentType,
        validateStatus: (status) {
          return status! < 500; // Ignorer les codes d'état 500
        },
      );
      Dio.Response response =
          await dio().post('/register', data: data, options: options);

      if (response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      throw Exception(" $e Erreur lors de l'inscription");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> checkPhoneNumberExists(
      String phoneNumber,
      {required Duration timeout}) async {
    try {
      // Envoyer une requête à l'API pour vérifier si le numéro existe
      final response = await dio().post('/checkPhoneNumber', data: {
        'phone_number': phoneNumber,
      });

      // Vérifier le code de statut de la réponse
      if (response.statusCode == 201) {
        if (response.data != null &&
            response.data.containsKey('type_compte') &&
            response.data.containsKey('token')) {
          String typeCompte = response.data['type_compte'];
          String token = response.data['token'];

          // Sauvegarder le type de compte et le token dans les préférences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('type_compte', typeCompte);
          await prefs.setString('token', token);

          // Retourner les données récupérées depuis l'API
          return response.data;
        } else {
          // Les clés attendues ne sont pas présentes dans la réponse
          throw Exception('Clés manquantes dans la réponse de l\'API');
        }
      } else {
        // Le numéro n'existe pas dans la base de données
        throw Exception('Numéro de téléphone non trouvé');
      }
    } catch (e) {
      // Gérer les erreurs
      print("Erreur lors de la vérification du numéro de téléphone: $e");
      throw Exception("Erreur lors de la vérification du numéro de téléphone");
    }
  }

  // Function to retrieve user data using authentication token
  static Future<Map<String, dynamic>?> fetchUserData() async {
    // Get the authentication token from SharedPreferences
    String? authToken = await _getAuthToken();

    // If no token is available, return null
    if (authToken == null) {
      return null;
    }

    // Call the fetchUserDataWithToken function with the token
    return await fetchUserDataWithToken(authToken);
  }

// Helper function to retrieve the authentication token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    // Get the SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the token from SharedPreferences under the 'token' key
    String? token = prefs.getString('token');
    return token;
  }

// Function to fetch user data using the provided authentication token
  static Future<Map<String, dynamic>?> fetchUserDataWithToken(
      String authToken) async {
    try {
      print('Retrieving authentication token...');
      print('Authentication token: $authToken');

      // Define request options with the authentication token
      Dio.Options options = Dio.Options(
        contentType: Dio.Headers.jsonContentType,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
        validateStatus: (status) => status! < 500,
      );

      print('Retrieving user data...');
      Dio.Response response = await dio().get('/who', options: options);

      if (response.statusCode == 200) {
        print('User data retrieved successfully.');
        print(response.data);
        return response.data;
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      throw Exception('Error retrieving user data: $e');
    }

    return null;
  }

  static Future<Map<String, dynamic>?> updateUserProfileWithImage({
    required Map<String, dynamic> userData,
    required File image,
  }) async {
    try {
      // Get the authentication token from SharedPreferences
      String? authToken = await _getAuthToken();

      // If no token is available, return null
      if (authToken == null) {
        return null;
      }

      // Define request options with the authentication token
      Dio.Options options = Dio.Options(
        contentType: Dio.Headers.jsonContentType,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
        validateStatus: (status) => status! < 500,
      );

      // Convert image to FormData
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
        ...userData,
      });

      // Send a PUT request with the form data to the endpoint
      Dio.Response response = await dio().put(
        '/photoImport',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('Profil mis à jour avec succès.');
        return response.data;
      } else {
        print(
            'Erreur lors de la mise à jour du profil: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
    }

    return null;
  }

  static Future<Map<String, dynamic>?> updateUserProfile(
      Map<String, dynamic> data) async {
    try {
      // Get the authentication token from SharedPreferences
      String? authToken = await _getAuthToken();

      // If no token is available, return null
      if (authToken == null) {
        return null;
      }

      // Define request options with the authentication token
      Dio.Options options = Dio.Options(
        contentType: Dio.Headers.jsonContentType,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
        validateStatus: (status) => status! < 500,
      );

      // Send a POST request with the user data to the endpoint
      Dio.Response response =
          await dio().put('/edit-profil', data: data, options: options);

      if (response.statusCode == 200) {
        print('User profile updated successfully.');
        return response.data;
      } else {
        print('Error updating user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }

    return null;
  }
}
