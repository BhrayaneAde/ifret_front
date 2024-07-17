import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as Dio;
import 'package:dio/dio.dart';
import 'package:ifret/api/dio.dart';
import 'package:ifret/composant/Chargeurs/accueilChargeur.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageResponse {
  final List<dynamic> messages;

  MessageResponse({required this.messages});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      messages:
          json['messages'] != null ? List<dynamic>.from(json['messages']) : [],
    );
  }
}

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
    if (token != null) {
      // If token exists, use it to fetch user details
      Options options = Options(headers: {'Authorization': 'Bearer $token'});
      Response response = await dio().get('/who', options: options);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store user details in SharedPreferences
        prefs.setString('user_numero_tel', response.data['numero_tel']);
      }
    }
    return token;
  }

  static Future<String?> getUserNumeroTel() async {
    // Get the SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the user number from SharedPreferences
    return prefs.getString('user_numero_tel');
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

      if (response.statusCode == 201) {
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

  static Future<Dio.Response?> soumissionner(Map<String, dynamic> data) async {
    try {
      // Récupérer le token d'authentification
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('Token d\'authentification non disponible');
      }

      // Définir les options de la requête avec le token d'authentification
      var options = Dio.Options(
        contentType: Dio.Headers.jsonContentType,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
        validateStatus: (status) => status! < 500,
      );

      // Faire la requête POST pour soumissionner
      Dio.Response response =
          await dio().post('/soumissionnaires', data: data, options: options);

      // Retourner la réponse pour un traitement ultérieur
      return response;
    } catch (e) {
      // Gérer l'exception
      print('Erreur lors de la soumission : $e');
      return null; // Retourner null en cas d'erreur
    }
  }

// Fonction pour récupérer les voyages
  static Future<List<Map<String, dynamic>>> fetchVoyages() async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('Token d\'authentification non disponible');
      }

      var options = Options(
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      Response response = await dio().get('/voyages', options: options);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        print(
            'Erreur lors de la récupération des données : ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      // Gérer les exceptions spécifiques à Dio
      print(
          'Erreur lors de la récupération des voyages (DioException) : ${e.response?.statusCode} - ${e.response?.data}');
      return [];
    } catch (e) {
      // Gérer les exceptions génériques
      print('Erreur lors de la récupération des voyages : $e');
      return [];
    }
  }

  // Fonction pour récupérer les détails d'un voyage par demandeId
  static Future<Map<String, dynamic>> fetchVoyageDetails(int demandeId) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response =
          await dio().get('/voyages/$demandeId', options: options);

      if (response.statusCode == 200) {
        Map<String, dynamic> voyageDetails =
            Map<String, dynamic>.from(response.data);

        if (voyageDetails.containsKey('demande_details')) {
          voyageDetails['fret_details'] = {
            'type_vehicule': voyageDetails['demande_details']
                    ['type_vehicule'] ??
                'Non spécifié',
            'date_depart': voyageDetails['demande_details']['date_depart'] ??
                'Non spécifié',
            'date_arrive': voyageDetails['demande_details']['date_arrive'] ??
                'Non spécifié',
            'montant':
                voyageDetails['demande_details']['montant'] ?? 'Non spécifié',
            'lieu_depart': voyageDetails['demande_details']['lieu_depart'] ??
                'Non spécifié',
            'lieu_arrive': voyageDetails['demande_details']['lieu_arrive'] ??
                'Non spécifié',
            'description_fret': voyageDetails['demande_details']
                    ['description_fret'] ??
                'Aucune description disponible',
          };
        } else {
          voyageDetails['fret_details'] = {
            'type_vehicule': 'Non spécifié',
            'date_depart': 'Non spécifié',
            'date_arrive': 'Non spécifié',
            'montant': 'Non spécifié',
            'lieu_depart': 'Non spécifié',
            'lieu_arrive': 'Non spécifié',
            'description_fret': 'Aucune description disponible',
          };
        }

        return voyageDetails;
      } else if (response.statusCode == 404) {
        throw Exception('Voyage not found');
      } else {
        throw Exception(
            'Error fetching voyage details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Gérer les exceptions spécifiques à Dio
      print(
          'Erreur lors de la récupération des détails du voyage (DioException) : ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(
          'Erreur lors de la récupération des détails du voyage : ${e.response?.statusCode} - ${e.response?.data}');
    } catch (e) {
      // Gérer les exceptions génériques
      print('Erreur lors de la récupération des détails du voyage : $e');
      throw Exception(
          'Erreur lors de la récupération des détails du voyage : $e');
    }
  }

  /*  static Future<Map<String, dynamic>> fetchFretDetailsA(int fretId) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response = await dio().get('/fretsA/$fretId', options: options);

      if (response.statusCode == 200) {
        // Succès : La réponse est déjà sous forme de Map<String, dynamic>
        Map<String, dynamic> fretDetails = response.data;

        // Ajouter des détails supplémentaires si nécessaire
        /* fretDetails['additional_info'] = 'Some extra details'; */

        print(fretDetails); // Pour déboguer et voir les données reçues

        return fretDetails;
      } else if (response.statusCode == 404) {
        // Fret non trouvé : Gérer l'erreur avec une exception ou une réponse vide
        throw Exception('Fret not found');
      } else {
        // Autres erreurs : Gérer selon le code d'erreur
        throw Exception('Error fetching fret details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching fret details: $e');
      throw Exception('Error fetching fret details: $e');
    }
  } */

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
          "accept": "application/json", // Correction de l'en-tête accept
          'content-type':
              'multipart/form-data', // Correction de l'en-tête content-type
          'Authorization': 'Bearer $authToken',
        },
        validateStatus: (status) => status! < 500,
        followRedirects: false,
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

      if (response.statusCode == 201) {
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
          "accept": "application/json", // Correction de l'en-tête accept
          'content-type':
              'multipart/form-data', // Correction de l'en-tête content-type
          'Authorization': 'Bearer $authToken',
        },
        validateStatus: (status) => status! < 500,
        followRedirects: false,
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

  static Future<Map<String, dynamic>?> sendMessage(String messageText) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        return null;
      }
      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response = await dio().post(
        '/send', // Utilisation de la route '/send' pour envoyer un message à l'administrateur
        data: {'message': messageText},
        options: options,
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        print('Error sending message to admin: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error sending message to admin: $e');
      throw Exception('Error sending message to admin: $e');
    }
  }

  static Future<Map<String, dynamic>?> createTransaction(
      Map<String, dynamic> transaction) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        return null;
      }

      Options options = Options(
        headers: {'Authorization': 'Bearer $authToken'},
      );

      Dio.Response response = await dio().post(
        '/transactions',
        data: transaction,
        options: options,
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        print('Error creating transaction: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating transaction: $e');
      throw Exception('Error creating transaction: $e');
    }
  }

  static Future<Map<String, dynamic>?> fetchMessages() async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        return null;
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response = await dio().get(
        '/receive',
        options: options,
      );
      if (response.statusCode == 201) {
        return response.data;
      } else {
        print('Error receiving message: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error receiving message: $e');
      throw Exception('Error receiving message: $e');
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchNotifications() async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response = await dio().get('/frets', options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Convertir les données reçues en une liste de maps
        List<dynamic> data = response.data['data'];
        List<Map<String, dynamic>> notifications = data.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
        return notifications;
      } else {
        print('Error fetching notifications: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception('Error fetching notifications: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchFretDetails(int id) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response = await dio().get('/frets/$id', options: options);

      if (response.statusCode == 201) {
        // Succès : Convertir les données en Map<String, dynamic>
        return response.data['data'] as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        // Fret non trouvé : Gérer l'erreur avec une exception ou une réponse vide
        throw Exception('Fret non trouvé');
      } else {
        // Autres erreurs : Gérer selon le code d'erreur
        throw Exception('Error fetching fret details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching fret details: $e');
      throw Exception('Error fetching fret details: $e');
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchTransactions() async {
    try {
      // Remplacez par votre méthode pour obtenir le token d'authentification
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response = await dio().get('/frets', options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = response.data;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('Error fetching transactions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      throw Exception('Error fetching transactions: $e');
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchTrafficData() async {
    try {
      // Get the authentication token from SharedPreferences
      String? authToken = await _getAuthToken();

      // If no token is available, return null
      if (authToken == null) {
        return null;
      }

      // Define request options with the authentication token
      Options options = Options(
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      // Make the HTTP request to fetch traffic data
      Response response = await dio().get('/traffic', options: options);

      if (response.statusCode == 201) {
        // If the request is successful, return the traffic data
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        // If the request fails, print the error and return null
        print('Error fetching traffic data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // If an error occurs, print the error and throw an exception
      print('Error fetching traffic data: $e');
      throw Exception('Error fetching traffic data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchNotification(
      Map<String, dynamic> data) async {
    try {
      // Faites une requête GET à votre API Laravel
      Response response = await dio().get('/notification', data: data);
      // Vérifiez si la réponse est réussie (code 201)
      if (response.statusCode == 201) {
        // Récupérez la notification depuis la réponse JSON
        return {
          'message': response.data['message'],
          'date': response.data['date'],
        };
      } else {
        throw Exception('Failed to load notification');
      }
    } catch (error) {
      throw Exception('Error fetching notification: $error');
    }
  }

  static Future<Map<String, dynamic>?> registerTruck({
    required String matricule,
    required List<File> files,
    required File photoCamion,
    required File carteGrise,
    required File visiteTechnique,
    required File assurance,
  }) async {
    try {
      // Vérifie si l'utilisateur est connecté (par exemple, si un jeton d'authentification est disponible)
      String? authToken = await _getAuthToken();
      print(authToken);

      if (authToken == null) {
        // Affiche un message d'erreur ou redirige l'utilisateur vers l'écran de connexion
        print('L\'utilisateur n\'est pas connecté');
        return null; // Ajout d'un retour null en cas d'utilisateur non connecté
      } else {
        print("l\'utilisateur est connecté");
      }
      // Define request options with the authentication token
      Dio.Options options = Dio.Options(
        contentType: Dio.Headers.jsonContentType,
        headers: {
          "accept": "application/json", // Correction de l'en-tête accept
          'content-type':
              'multipart/form-data', // Correction de l'en-tête content-type
          'Authorization': 'Bearer $authToken',
        },
        validateStatus: (status) => status! < 500,
        followRedirects: false,
      );

      if (matricule.isEmpty) {
        throw Exception("Le numéro de matricule ne peut pas être vide");
      }

      if (files.isEmpty) {
        throw Exception("La liste de fichiers ne peut pas être vide");
      }

      FormData formData = FormData();

      formData.fields.add(MapEntry('matricule', matricule));

      // Add image files directly using MapEntry objects
      formData.files.add(MapEntry(
          'photo_camion', await MultipartFile.fromFile(photoCamion.path)));
      formData.files.add(MapEntry(
          'carte_grise', await MultipartFile.fromFile(carteGrise.path)));
      formData.files.add(MapEntry('visite_technique',
          await MultipartFile.fromFile(visiteTechnique.path)));
      formData.files.add(
          MapEntry('assurance', await MultipartFile.fromFile(assurance.path)));

      print('Sending request to register truck...');
      Dio.Response response = await dio()
          .post('/enregistrementCamion', data: formData, options: options);

      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 201) {
        print('Truck registration successful');
        return response.data;
      } else {
        throw Exception(
            "Échec de l'enregistrement du camion: ${response.statusCode}");
      }
    } catch (e) {
      print('Error during truck registration: $e');
      throw Exception("Erreur lors de l'enregistrement du camion: $e");
    }
  }

  static Future<List<dynamic>?> getChauffeurs() async {
    try {
      // Récupérer le jeton d'authentification depuis SharedPreferences
      String? authToken = await _getAuthToken();

      // Vérifier si le jeton d'authentification est disponible
      if (authToken == null) {
        throw Exception('Auth token not available');
      }

      // Définir les options de la requête avec le jeton d'authentification
      Options options = Options(
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      // Faire la requête GET à l'API pour récupérer les chauffeurs
      Response response = await dio().get(
        '/chauffeurs', // Remplacez par votre URL d'API Laravel
        options: options,
      );

      // Vérifier le code de statut de la réponse
      if (response.statusCode == 201) {
        // Convertir les données JSON en une liste dynamique
        List<dynamic> chauffeurs = response.data['chauffeurs'];
        return chauffeurs;
      } else {
        throw Exception('Failed to fetch chauffeurs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chauffeurs: $e');
      throw Exception('Error fetching chauffeurs: $e');
    }
  }

  static Future<List<dynamic>> getUserCamions() async {
    try {
      // Get the authentication token from SharedPreferences
      String? authToken = await _getAuthToken();

      // If no token is available, return null
      if (authToken == null) {}

      // Define request options with the authentication token
      Options options = Options(
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      // Make the HTTP request to fetch traffic data
      Response response = await dio().get('/camions', options: options);

      if (response.statusCode == 201) {
        // If the request is successful, return the traffic data
        return response.data['data'];
      } else {
        // If the request fails, print the error and return null
        print('Error fetching traffic data: ${response.statusCode}');
        throw Exception('Erreur lors de la récupération des camions');
      }
    } catch (e) {
      // If an error occurs, print the error and throw an exception
      print('Erreur API: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>> getCamionDetails(String matricule) async {
    try {
      String? authToken = await _getAuthToken();

      if (authToken == null) {
        throw Exception('Token d\'authentification non disponible');
      }

      Options options = Options(
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      Response response =
          await dio().get('/camions/$matricule', options: options);

      if (response.statusCode == 201) {
        return response.data['data'];
      } else {
        throw Exception('Erreur lors de la récupération des détails du camion');
      }
    } catch (e) {
      print('Erreur API: $e');
      throw e;
    }
  }

  Future<void> updateCamion(String matricule, Map<String, dynamic> data) async {
    try {
      String? authToken = await _getAuthToken();

      if (authToken == null) {
        throw Exception('Token d\'authentification non disponible');
      }

      Options options = Options(
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      FormData formData = FormData.fromMap(data);

      Response response = await dio()
          .put('/updateCamion/$matricule', data: formData, options: options);

      if (response.statusCode == 201) {
        print('Camion profile updated successfully.');
        return response.data;
      } else {
        print('Error updating user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur API: $e');
      throw e;
    }
  }
}
