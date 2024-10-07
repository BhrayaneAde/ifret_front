import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:ifret/api/api_request.dart';

import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:ifret/composant/Chargeurs/paiement.dart';
import 'package:ifret/composant/Chargeurs/profilChargeur.dart';

import 'package:dio/dio.dart' as Dio;
import 'package:flutter_tts/flutter_tts.dart';

class Chargeur extends StatefulWidget {
  final String name;
  final String profileUrl;
  final String username;

  const Chargeur({
    super.key,
    required this.name,
    required this.profileUrl,
    required this.username,
  });

  @override
  State<Chargeur> createState() => _ChargeurState();
}

class _ChargeurState extends State<Chargeur> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  int _currentIndex = 0;
  String? _currentUserNumeroTel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFCCE00),
        unselectedItemColor: Colors.black,
        items: [
          _bottomNavigationBarItem(
            icon: Icons.mail,
            label: 'Initiation Fret',
            index: 0,
          ),
          _bottomNavigationBarItem(
            icon: Icons.payment,
            label: 'Paiement',
            index: 1,
          ),
          _bottomNavigationBarItem(
            icon: Icons.car_crash,
            label: 'Tracking',
            index: 2,
          ),
          _bottomNavigationBarItem(
            icon: Icons.person,
            label: 'Profil',
            index: 3,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _bottomNavigationBarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
      backgroundColor: Colors.white,
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _getMessages();
      case 1:
        return const Paiement();
      case 2:
        return MapsHomePage();
      case 3:
        return const ProfilChargeur();
      default:
        return Container();
    }
  }

  Widget _getMessages() {
    return const FretFormScreen(); // Ajout du formulaire de fret ici
  }
}

class Message {
  final String text;
  final String type;
  final DateTime createdAt;

  Message({required this.text, required this.createdAt, required this.type});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      type: json['type'],
    );
  }
}

class FretFormScreen extends StatefulWidget {
  const FretFormScreen({super.key});

  @override
  _FretFormScreenState createState() => _FretFormScreenState();
}

class _FretFormScreenState extends State<FretFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _description = '';
  String _lieuDepart = '';
  String _lieuArrive = '';
  String _infoComplementaires = '';
  String _typeCamion = '';
  String _typeMarchandise = '';

  final List<String> _cities = [
    'Abomey',
    'Abomey-Calavi',
    'Adja-Ouèrè',
    'Adjarra',
    'Adjohoun',
    'Agbangnizoun',
    'Aguégués',
    'Allada',
    'Aplahoué',
    'Athiémé',
    'Avrankou',
    'Banikoara',
    'Bantè',
    'Bassila',
    'Bembèrèkè',
    'Bohicon',
    'Bonou',
    'Bopa',
    'Boukombé',
    'Cobly',
    'Comè',
    'Copargo',
    'Cotonou',
    'Covè',
    'Dangbo',
    'Dassa-Zoumè',
    'Djakotomey',
    'Djidja',
    'Djougou',
    'Dogbo',
    'Glazoué',
    'Gogounou',
    'Grand-Popo',
    'Houéyogbé',
    'Ifangni',
    'Kalalé',
    'Kandi',
    'Karimama',
    'Kérou',
    'Kétou',
    'Klouékanmè',
    'Kouandé',
    'Kpomassè',
    'Lalo',
    'Lokossa',
    'Malanville',
    'Matéri',
    'Missérété',
    'N’dali',
    'Natitingou',
    'Nikki',
    'Ouaké',
    'Ouèssè',
    'Ouidah',
    'Ouinhi',
    'Parakou',
    'Pehunco',
    'Pèrèrè',
    'Pobè',
    'Porto-Novo',
    'Sakété',
    'Savalou',
    'Savè',
    'Ségbana',
    'Sèmè-Podji',
    'Sinendé',
    'Sô-Ava',
    'Tanguiéta',
    'Tchaourou',
    'Toffo',
    'Tori-Bossito',
    'Toucountouna',
    'Toviklin',
    'Zagnanado',
    'Za-Kpota',
    'Zè',
    'Zogbodomey',
  ];

  final List<String> _typeCamionOptions = [
    'Ampliroll',
    'Benne',
    'Benne grue',
    'Bétaillère',
    'Chariot élévateur',
    'Citerne',
    'Dépanneuse',
    'Fourgon',
    'Fourgon frigorifique',
    'Pickup',
    'Plateau 20',
    'Plateau 40',
    'Plateau double 20\'\'',
    'Plateau Grue',
    'Porte-Char',
    'Utilitaire',
    'Autre'
  ];

  final List<String> _typeMarchandiseOptions = [
    'Agriculture',
    'Alimentaire',
    'BTP',
    'Industrie',
    'Autre'
  ];

  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _speakInstructions(String instructions) async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setPitch(1.0);

    await _flutterTts.speak(instructions);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Si les champs sont vides, on attribue des valeurs par défaut
      _lieuDepart = _lieuDepart.isEmpty ? 'Porto' : _lieuDepart;
      _lieuArrive = _lieuArrive.isEmpty ? 'Cotonou' : _lieuArrive;

      // Préparer les données pour l'API
      Map<String, dynamic> data = {
        'description': _description,
        'lieu_depart': _lieuDepart,
        'lieu_arrive': _lieuArrive,
        'info_comp': _infoComplementaires,
        'type_camion': _typeCamion,
        'type_marchandise': _typeMarchandise,
        // Ajouter l'image si elle est sélectionnée
        if (_selectedImage != null)
          'image': await Dio.MultipartFile.fromFile(_selectedImage!.path),
      };

      try {
        Dio.Response? response = await ApiRequest.createFret(data);

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Afficher le dialogue de complétion avec un rappel
          _showCompletionDialog(() {
            // Réinitialiser les champs du formulaire
            _formKey.currentState!.reset();
            // Réinitialiser les variables associées aux champs du formulaire
            setState(() {
              _description = '';
              _lieuDepart = 'Porto'; // Réinitialiser avec la valeur par défaut
              _lieuArrive =
                  'Cotonou'; // Réinitialiser avec la valeur par défaut
              _infoComplementaires = '';
              _typeCamion = ''; // Mettre à null ou chaîne vide
              _typeMarchandise = ''; // Mettre à null ou chaîne vide
              _selectedImage = null; // Réinitialiser l'image
            });
          });
        } else {
          print('Erreur lors de l\'enregistrement du fret : ${response.data}');
        }
      } catch (error) {
        print('Erreur lors de la création du fret : $error');
      }
    }
  }

  void _showCompletionDialog(VoidCallback onOkPressed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Le fret a été créé avec succès.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la boîte de dialogue
              onOkPressed(); // Exécuter la fonction de rappel
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.white, // Background color
              filled: true, // Fill the background color
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            onSaved: onSaved,
            validator: validator,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () async {
            await _flutterTts.speak('Gɔ́n wè $label'); // Phrase en Fon
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String?> validator,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.white, // Background color
              filled: true, // Fill the background color
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () async {
            await _flutterTts.speak('Gɔ́n nù $label'); // Phrase en Fon
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  File? _selectedImage; // Permet de stocker une seule image

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery); // Choix de l'image
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Widget _buildImagePreview() {
    return _selectedImage == null
        ? const Text('Aucune image sélectionnée')
        : Image.file(_selectedImage!,
            width: 150, height: 150); // Aperçu de l'image
  }

  Widget _buildImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image du Fret à Transporter',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Sélectionner une image'),
        ),
        const SizedBox(height: 10),
        _buildImagePreview(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildSectionHeader('Informations de Réservation', Icons.info),
                _buildTextField(
                  label: 'Description',
                  onSaved: (value) => _description = value ?? '',
                  validator: (value) =>
                      value!.isEmpty ? 'Veuillez entrer une description' : null,
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  label: 'Lieu de Départ',
                  items: _cities,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _lieuDepart = value);
                    }
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Veuillez sélectionner un lieu de départ'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  label: 'Lieu d\'Arrivée',
                  items: _cities,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _lieuArrive = value);
                    }
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Veuillez sélectionner un lieu d\'arrivée'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Informations Complémentaires',
                  onSaved: (value) => _infoComplementaires = value!,
                  validator: (value) => value!.isEmpty
                      ? 'Veuillez entrer des informations complémentaires'
                      : null,
                ),
                const SizedBox(height: 30),
                _buildSectionHeader(
                    'Détails du Transport', Icons.directions_car),
                _buildDropdown(
                  label: 'Type de Camion',
                  items: _typeCamionOptions,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _typeCamion = value);
                    }
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Veuillez sélectionner un type de camion'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildDropdown(
                  label: 'Type de Marchandise',
                  items: _typeMarchandiseOptions,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _typeMarchandise = value);
                    }
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Veuillez sélectionner un type de marchandise'
                      : null,
                ),
                const SizedBox(height: 20),
                _buildSectionHeader('Image du Fret', Icons.photo),
                _buildImageField(), // Champ pour la sélection d'une seule image

                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFFCCE00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/hautPaiement1.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(),
            child: SizedBox.expand(),
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Image.asset(
              'assets/images/ifret.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 27, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Emission et Initiation',
                    style: TextStyle(
                      color: Color(0xFFFCCE00),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Fret',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Paiement extends StatefulWidget {
  const Paiement({super.key});

  @override
  _PaiementState createState() => _PaiementState();
}

class _PaiementState extends State<Paiement> {
  List<Map<String, dynamic>> _soumissions = [];
  Map<String, List<Map<String, dynamic>>> _groupedSoumissions = {};

  @override
  void initState() {
    super.initState();
    _fetchSoumissions();
  }

  Future<void> _fetchSoumissions() async {
    try {
      List<Map<String, dynamic>>? soumissions =
          await ApiRequest.fetchSoumissionsForConnectedUser();
      if (soumissions != null && soumissions.isNotEmpty) {
        // Groupement des soumissions comme dans votre code
        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (var soumission in soumissions) {
          final description = soumission['description_fret'] ?? 'N/A';
          if (!grouped.containsKey(description)) {
            grouped[description] = [];
          }
          grouped[description]!.add(soumission);
        }
        setState(() {
          _soumissions = soumissions;
          _groupedSoumissions = grouped;
        });
      } else {
        // Aucune soumission trouvée, afficher un message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Pas de soumissionnaire disponible pour votre demande pour l\'instant')),
        );
      }
    } catch (e) {
      // Gestion de l'erreur 404
      if (e.toString().contains('404')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune soumission n\'a été trouvée.')),
        );
      } else {
        // Gestion des autres erreurs
        print('Error fetching soumissions: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Une erreur est survenue lors de la récupération des soumissions.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 10),
          Expanded(child: _buildSoumissionsList()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/hautPaiement1.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(),
            child: SizedBox.expand(),
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Image.asset(
              'assets/images/ifret.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 27, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choix des Soumissions',
                    style: TextStyle(
                      color: Color(0xFFFCCE00),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Disponible',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoumissionsList() {
    if (_groupedSoumissions.isEmpty) {
      // Si aucune soumission n'est disponible
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Pas de soumissionnaire disponible pour votre demande pour l\'instant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Si des soumissions sont disponibles, afficher la liste
    return ListView(
      children: _groupedSoumissions.keys.map((description) {
        final soumissionsList = _groupedSoumissions[description]!;
        final firstSoumission = soumissionsList
            .first; // Récupérer la première soumission pour la date
        final date =
            firstSoumission['date'] ?? 'N/A'; // Assurer la validité de la date

        return ExpansionTile(
          leading: const Icon(Icons.local_shipping,
              color: Colors.blue, size: 30), // Icône de fret
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Date: $date',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey, // Couleur pour la date
                ),
              ),
            ],
          ),
          children: soumissionsList.map((soumission) {
            // Conversion de montant_propose de String à int
            final montantProposeStr = soumission['montant_propose'] as String;
            final montantPropose = int.tryParse(montantProposeStr) ?? 0;

            // Application de l'intérêt de 25%
            final montantAvecInteret = (montantPropose * 1.25).round();

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${soumission['nom_transporteur']} ${soumission['prenom_transporteur']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$montantAvecInteret', // Affichage du montant avec intérêt
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${soumission['numero_tel_transporteur'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Appel de la méthode _validerSoumission avec les paramètres corrects
                        _validerSoumission(soumission);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFFCCE00), // Couleur du bouton
                      ),
                      child: const Text(
                        'Valider',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Future<void> _validerSoumission(Map<String, dynamic> soumission) async {
    print('Soumission reçue : $soumission'); // Pour déboguer

    // Conversion de montant_propose de String à int
    final montantProposeStr = soumission['montant_propose'] as String?;
    if (montantProposeStr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur : Le montant proposé est invalide')),
      );
      return;
    }

    final montantPropose = int.tryParse(montantProposeStr);
    if (montantPropose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur : Impossible de convertir le montant proposé'),
        ),
      );
      return;
    }

    // Application de l'intérêt de 25%
    final montantAvecInteret = (montantPropose * 1.25).round();

    // Récupération de fretId
    final fretId = soumission['fret_id'] as int?;
    if (fretId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : fretId est null ou invalide')),
      );
      return;
    }

    /*   // Récupération du kkiapayTransactionId
    final kkiapayTransactionId =
        soumission['kkiapay_transaction_id'] as String? ?? ''; */

    try {
      // Met à jour le montant avec intérêt dans la base de données
      await ApiRequest.updateMontantFret(fretId, montantAvecInteret);

      // Récupération de kkiapayTransactionId si disponible
      final kkiapayTransactionId =
          soumission['kkiapay_transaction_id'] as String? ?? '';
      // Met à jour la transaction dans la base de données
      await ApiRequest.updateFretTransactionId(fretId, kkiapayTransactionId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant mis à jour avec succès')),
      );
      print(
          'Soumission validée : ${soumission['nom_transporteur']} ${soumission['prenom_transporteur']}');

      // Redirection vers la page de paiement avec le montant avec intérêt
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaiementPage(
            transactionId:
                montantProposeStr, // Assurez-vous que c'est une String
            montant: montantAvecInteret, // Assurez-vous que c'est un int
            fretId:
                fretId, // Convertir fretId en String, ou utiliser une valeur par défaut si null
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la validation de la soumission')),
      );
      print('Erreur lors de la validation de la soumission : $e');
    }
  }
}

const kGoogleApiKey =
    "AIzaSyB1ytAgVmhTWQUdOI73b2C9N-xTqvUn0lk"; // Remplacez par votre clé API Google

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapsHomePage(),
    );
  }
}

class MapsHomePage extends StatefulWidget {
  const MapsHomePage({super.key});

  @override
  _MapsHomePageState createState() => _MapsHomePageState();
}

class _MapsHomePageState extends State<MapsHomePage> {
  GoogleMapController? mapController;
  LatLng? startLocation;
  LatLng? endLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un lieu de départ et d\'arrivée'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              // Ouvrir un TextField pour que l'utilisateur entre un lieu de départ
              await _showPlaceSearchDialog(context, "Départ");
            },
            child: const Text("Choisir le lieu de départ"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Ouvrir un TextField pour que l'utilisateur entre un lieu d'arrivée
              await _showPlaceSearchDialog(context, "Arrivée");
            },
            child: const Text("Choisir le lieu d'arrivée"),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(48.8588443,
                    2.2943506), // Coordonnées de Paris (Tour Eiffel)
                zoom: 12,
              ),
              markers: _createMarkers(),
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};
    if (startLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId("start"),
        position: startLocation!,
        infoWindow: const InfoWindow(title: "Lieu de départ"),
      ));
    }
    if (endLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId("end"),
        position: endLocation!,
        infoWindow: const InfoWindow(title: "Lieu d'arrivée"),
      ));
    }
    return markers;
  }

  Future<void> _showPlaceSearchDialog(
      BuildContext context, String locationType) async {
    TextEditingController searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rechercher un lieu ($locationType)"),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(hintText: "Entrez un lieu"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              String query = searchController.text;
              if (query.isNotEmpty) {
                await _searchLocation(query, locationType);
              }
            },
            child: const Text("Rechercher"),
          ),
        ],
      ),
    );
  }

  // Rechercher un lieu via une requête HTTP à l'API Google Places
  Future<void> _searchLocation(String query, String locationType) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$kGoogleApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final lat = data['results'][0]['geometry']['location']['lat'];
        final lng = data['results'][0]['geometry']['location']['lng'];

        setState(() {
          if (locationType == "Départ") {
            startLocation = LatLng(lat, lng);
          } else {
            endLocation = LatLng(lat, lng);
          }
        });

        // Recentrer la carte sur la nouvelle position
        mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      }
    } else {
      throw Exception("Impossible de récupérer les détails du lieu.");
    }
  }
}
