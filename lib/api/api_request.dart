import 'dart:io';

import 'package:dio/dio.dart' as Dio;
import 'package:dio/dio.dart';
import 'package:ifret/api/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* 
class KkiapayApi {
  static const String baseUrl = 'https://api.kkiapay.com';
  static const String kkiapaySecretKey = '2b8e553045da11efba1789f22fb73fae';

  static Future<Map<String, dynamic>?> createPayment({
    required double amount,
  }) async {
    try {
      // Récupérer le token d'authentification
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('Token d\'authentification non disponible');
      }

      final response = await dio().post(
        '/payment/init',
        options: Options(
          headers: {
            'Authorization': 'Bearer $kkiapaySecretKey',
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode({
          'amount': amount,

          // Ajoute d'autres paramètres nécessaires ici
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        print('Erreur lors de la création du paiement: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la création du paiement: $e');
      return null;
    }
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

  /*  static Future<Map<String, dynamic>?> verifyPayment(
      String transactionId) async {
    try {
      final response = await dio().get(
        '$baseUrl/v1/transactions/$transactionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $kkiapaySecretKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print(
            'Erreur lors de la vérification du paiement: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la vérification du paiement: $e');
      return null;
    }
  }
 */
}
 */
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

  Future<Map<String, dynamic>?> initializePayment(double amount) async {
    try {
      String? numeroTel = await getUserNumeroTel();
      if (numeroTel == null) throw Exception("Numéro de téléphone non trouvé");

      Options options = Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500,
      );

      Response response = await dio().post('/initialize-payment',
          data: {'amount': amount, 'numero_tel': numeroTel}, options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      throw Exception("Erreur lors de l'initialisation du paiement : $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPaymentStatus() async {
    try {
      String? numeroTel = await getUserNumeroTel();
      if (numeroTel == null) throw Exception("Numéro de téléphone non trouvé");

      Options options = Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500,
      );

      Response response =
          await dio().get('/payment-status/$numeroTel', options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      throw Exception(
          "Erreur lors de la récupération du statut du paiement : $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> updatePaymentStatus(double paidAmount) async {
    try {
      String? numeroTel = await getUserNumeroTel();
      if (numeroTel == null) throw Exception("Numéro de téléphone non trouvé");

      Options options = Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500,
      );

      Response response = await dio().put('/update-payment-status',
          data: {'paid_amount': paidAmount, 'numero_tel': numeroTel},
          options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour du paiement : $e");
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
          'Erreur lors de la récupération des voyages (DioError) : ${e.response?.statusCode} - ${e.response?.data}');
      return [];
    } catch (e) {
      // Gérer les exceptions génériques
      print('Erreur lors de la récupération des voyages : $e');
      return [];
    }
  }

  // Fonction pour récupérer les détails d'un voyage par fretId
  static Future<Map<String, dynamic>> fetchVoyageDetails(int fretId) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response = await dio().get('/frets/$fretId', options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> voyageDetails =
            Map<String, dynamic>.from(response.data);

        // Vérification des détails du fret
        if (voyageDetails.containsKey('fret_details')) {
          // Assigner tous les champs du fret, y compris l'image
          voyageDetails['fret_details'] = {
            'type_vehicule': voyageDetails['fret_details']['type_vehicule'] ??
                'Non spécifié',
            'date_depart':
                voyageDetails['fret_details']['date_depart'] ?? 'Non spécifié',
            'date_arrive':
                voyageDetails['fret_details']['date_arrive'] ?? 'Non spécifié',
            'montant':
                voyageDetails['fret_details']['montant'] ?? 'Non spécifié',
            'lieu_depart':
                voyageDetails['fret_details']['lieu_depart'] ?? 'Non spécifié',
            'lieu_arrive':
                voyageDetails['fret_details']['lieu_arrive'] ?? 'Non spécifié',
            'description': voyageDetails['fret_details']['description'] ??
                'Aucune description disponible',
            'image_url': voyageDetails['fret_details']
                ['image_url'], // Ajouter l'image ici
          };
        } else {
          // Si 'fret_details' n'existe pas, assigner des valeurs par défaut
          voyageDetails['fret_details'] = {
            'type_vehicule': 'Non spécifié',
            'date_depart': 'Non spécifié',
            'date_arrive': 'Non spécifié',
            'montant': 'Non spécifié',
            'lieu_depart': 'Non spécifié',
            'lieu_arrive': 'Non spécifié',
            'description': 'Aucune description disponible',
            'image_url': null, // Image non disponible
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
      print(
          'Erreur lors de la récupération des détails du voyage (DioException) : ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(
          'Erreur lors de la récupération des détails du voyage : ${e.response?.statusCode} - ${e.response?.data}');
    } catch (e) {
      print('Erreur lors de la récupération des détails du voyage : $e');
      throw Exception(
          'Erreur lors de la récupération des détails du voyage : $e');
    }
  }

  static Future<Map<String, dynamic>> fetchFretVoyageDetails(int fretId) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response = await dio().get('/voyages/$fretId', options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> voyageDetails =
            Map<String, dynamic>.from(response.data);

        if (voyageDetails.containsKey('fret_details')) {
          voyageDetails['fret_details'] = {
            'type_vehicule': voyageDetails['type_vehicule'] ?? 'Non spécifié',
            'date_depart':
                voyageDetails['fret_details']['date_depart'] ?? 'Non spécifié',
            'date_arrive':
                voyageDetails['fret_details']['date_arrive'] ?? 'Non spécifié',
            'montant':
                voyageDetails['fret_details']['montant'] ?? 'Non spécifié',
            'lieu_depart':
                voyageDetails['fret_details']['lieu_depart'] ?? 'Non spécifié',
            'lieu_arrive':
                voyageDetails['fret_details']['lieu_arrive'] ?? 'Non spécifié',
            'description': voyageDetails['fret_details']['description'] ??
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
            'description': 'Aucune description disponible',
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

  static Future<Response> createFret(Map<String, dynamic> fretData) async {
    String? authToken = await _getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token available');
    }

    Options options = Options(
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type':
            'multipart/form-data', // Assurez-vous que l'en-tête est configuré pour multipart
      },
    );

    try {
      // Si l'image est incluse, on utilise FormData pour l'envoi
      FormData formData = FormData.fromMap(fretData);

      Response response =
          await dio().post('/initfrets', data: formData, options: options);

      if (response.statusCode == 201) {
        print('Fret créé avec succès');
      }

      return response;
    } catch (e) {
      print('Erreur lors de la création du fret: $e');
      throw Exception('Erreur lors de la création du fret: $e');
    }
  }

  static Future<void> updateFretStatus(
      int fretId, String kkiapayTransactionId) async {
    try {
      // Fonction pour obtenir le token d'authentification
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      print('Auth Token: $authToken');
      print('Fret ID: $fretId');
      print('Kkiapay Transaction ID: $kkiapayTransactionId');

      // Préparer les headers avec l'authentification
      Options options = Options(
        headers: {'Authorization': 'Bearer $authToken'},
      );

      // Corps de la requête pour mettre à jour le fret
      Map<String, dynamic> data = {
        'kkiapay_transaction_id': kkiapayTransactionId,
        'statut_paiement': 'Payé',
      };

      // Faire la requête PUT pour mettre à jour le fret
      Response response = await dio().post(
        '/frets/$fretId/update-status',
        options: options,
        data: data,
      );

      if (response.statusCode == 200) {
        print('Statut de paiement et montant mis à jour avec succès !');
      } else {
        print('Erreur lors de la mise à jour : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour : $e');
      throw Exception('Erreur lors de la mise à jour du statut : $e');
    }
  }

  static Future<void> updateFeedbackAndStatut(
      int fretId, String feedback) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});

      // Envoie la requête POST pour mettre à jour le feedback
      Response response = await dio().post(
        '/frets/$fretId/update-feedback-statut',
        options: options,
        data: {
          'feedback': feedback, // Le feedback est envoyé en tant que chaîne
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la mise à jour du feedback et du statut.');
      }
    } catch (e) {
      print('Error updating feedback and status: $e');
      throw Exception('Error updating feedback and status: $e');
    }
  }

  static Future<List<Map<String, dynamic>>?>
      fetchSoumissionsForConnectedUser() async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options = Options(
        headers: {'Authorization': 'Bearer $authToken'},
        // Accepter les codes d'état inférieurs à 500, donc 404 ne lèvera pas une exception
        validateStatus: (status) {
          return status != null && status < 500;
        },
      );

      Response response = await dio().get('/soumissions', options: options);

      if (response.statusCode == 200) {
        // Convertir les données reçues en une liste de maps
        List<dynamic> data = response.data;
        List<Map<String, dynamic>> soumissions = data.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
        return soumissions;
      } else if (response.statusCode == 404) {
        // Si le code de statut est 404, on renvoie null et on affiche un message
        print('No soumissions found (404)');
        return null;
      } else {
        // Gérer d'autres erreurs possibles
        print('Error soumissions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching soumissions: $e');
      throw Exception('Error fetching soumissions: $e');
    }
  }

  static Future<void> updateFretTransactionId(
      int fretId, String kkiapayTransactionId) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      print('Auth Token: $authToken');
      print('Fret ID: $fretId');
      print('Kkiapay Transaction ID: $kkiapayTransactionId');

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});

      // Conversion de fretId en String pour l'URL
      Response response = await dio().post(
        '/update-fret-transaction-id/${fretId.toString()}', // Convertir fretId en String ici
        options: options,
        data: {
          'kkiapay_transaction_id': kkiapayTransactionId,
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la mise à jour du kkiapay_transaction_id.');
      }
    } catch (e) {
      print('Error updating kkiapay transaction ID: $e');
      throw Exception('Error updating kkiapay transaction ID: $e');
    }
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

  static Future<List<Map<String, dynamic>>> checkTransporteursValides(
      int fretId) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      final response = await dio().get(
        '/frets/$fretId/check-transporteurs',
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Error checking transporteurs validity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking transporteurs validity: $e');
    }
  }

  static Future<void> updateMontantFret(
      int fretId, int montantAvecInteret) async {
    try {
      // Récupération du jeton d'authentification
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      final response = await dio().post(
        '/updatemontantfret', // Assurez-vous de remplacer cette URL par la vôtre
        data: {
          'fret_id': fretId, // Inclure le fret_id dans les données envoyées
          'montant': montantAvecInteret
              .toString(), // Convertir montant en chaîne pour correspondre à l'attente de Laravel
        },
        options: Options(
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Error updating montant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating montant: $e');
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

  static Future<void> storeTransaction(
      String fretId, String kkiapayTransactionId, int montantPaye) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      print('Auth Token: $authToken');
      print('Transaction ID: $kkiapayTransactionId');
      print('Montant Payé: $montantPaye');

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response = await dio().post(
        '/store-transaction',
        options: options,
        data: {
          'fretId': fretId,
          'transactionId': kkiapayTransactionId,
          'montant_paye': montantPaye,
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Erreur lors de l\'enregistrement de la transaction.');
      }
    } catch (e) {
      print('Error storing transaction: $e');
      throw Exception('Error storing transaction: $e');
    }
  }

  static Future<int> fetchTotalPaidAmount(String fretId) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response =
          await dio().get('/frets/$fretId/paid-amount', options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['total_paid'];
      } else {
        print('Error fetching total paid amount: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error fetching total paid amount: $e');
      throw Exception('Error fetching total paid amount: $e');
    }
  }

  // Récupérer les transactions d'un fret spécifique
  Future<List<dynamic>> getTransactionsForFret(int fretId) async {
    try {
      final response = await dio().get('/recupere-transac/$fretId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Erreur lors de la récupération des transactions.');
      }
    } catch (e) {
      print('Erreur lors de la récupération des transactions: $e');
      throw Exception('Erreur lors de la récupération des transactions: $e');
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

      if (response.statusCode == 201 || response.statusCode == 200) {
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
      Response response =
          await dio().get('/notification', queryParameters: data);
      // Vérifiez si la réponse est réussie (code 201)
      if (response.statusCode == 201 || response.statusCode == 200) {
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
    required String typeVehicule, // Nouveau paramètre
  }) async {
    try {
      String? authToken = await _getAuthToken();

      if (authToken == null) {
        print('L\'utilisateur n\'est pas connecté');
        return null;
      }

      Dio.Options options = Dio.Options(
        contentType: Dio.Headers.jsonContentType,
        headers: {
          "accept": "application/json",
          'content-type': 'multipart/form-data',
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

      formData.files.addAll([
        MapEntry(
            'photo_camion', await MultipartFile.fromFile(photoCamion.path)),
        MapEntry('carte_grise', await MultipartFile.fromFile(carteGrise.path)),
        MapEntry('visite_technique',
            await MultipartFile.fromFile(visiteTechnique.path)),
        MapEntry('assurance', await MultipartFile.fromFile(assurance.path)),
      ]);

      formData.fields
        ..add(MapEntry('type_vehicule', typeVehicule))
        ..add(MapEntry('matricule', matricule));

      Dio.Response response = await dio()
          .post('/enregistrementCamion', data: formData, options: options);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception("Erreur lors de l'enregistrement du camion.");
      }
    } on DioException catch (e) {
      throw Exception("Erreur de réseau: ${e.response?.statusCode}");
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

      if (response.statusCode == 201 || response.statusCode == 200) {
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
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>?> getSoumissionsForFret(
      String fretId) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response =
          await dio().get('/frets/$fretId/soumissions', options: options);

      if (response.statusCode == 200) {
        // Convertir les données reçues en une liste de maps
        List<dynamic> data = response.data;
        List<Map<String, dynamic>> soumissions = data.map((item) {
          return {
            'description': item['description'] ?? 'N/A',
            'montant_propose': item['montant_propose'] ?? 'N/A',
            'nom_transporteur': item['nom_transporteur'] ?? 'N/A',
            'prenom_transporteur': item['prenom_transporteur'] ?? 'N/A',
          };
        }).toList();
        return soumissions;
      } else {
        print('Error fetching soumissions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching soumissions: $e');
      throw Exception('Error fetching soumissions: $e');
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchSoumissions(
      String fretId) async {
    try {
      String? authToken = await _getAuthToken();
      if (authToken == null) {
        throw Exception('No auth token available');
      }

      Options options =
          Options(headers: {'Authorization': 'Bearer $authToken'});
      Response response =
          await dio().get('/frets/$fretId/soumissions', options: options);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        List<Map<String, dynamic>> soumissions = data.map((item) {
          return {
            'nom_transporteur': item['nom_transporteur'] ?? 'N/A',
            'prenom_transporteur': item['prenom_transporteur'] ?? 'N/A',
            'montant_propose': item['montant_propose']?.toString() ?? 'N/A',
          };
        }).toList();
        return soumissions;
      } else {
        print('Error fetching soumissions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching soumissions: $e');
      return null;
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

      // Log du code de statut HTTP
      print('Status Code: ${response.statusCode}');

      // Log de la réponse brute
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // Log si les détails sont sous 'data' ou non
        if (response.data.containsKey('data')) {
          print('Camion Details (from data): ${response.data['data']}');
          return response.data['data'];
        } else {
          print('Camion Details (direct): ${response.data}');
          return response.data; // Si 'data' n'est pas un wrapper
        }
      } else {
        throw Exception(
            'Erreur lors de la récupération des détails du camion, code: ${response.statusCode}');
      }
    } catch (e) {
      // Log de l'erreur
      print('Erreur API: $e');
      rethrow;
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
      rethrow;
    }
  }
}
