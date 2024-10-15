import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Transporteurs/EnregistrerCamionModif.dart';
import 'package:ifret/composant/Transporteurs/FretDetailsPage.dart';
import 'package:ifret/composant/Transporteurs/profilTransporteur.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent,
    ),
  );
  runApp(const MaterialApp(
    home: Transporteurs(
      name: "John Doe Transporteur",
      profileUrl: "profile_url",
      username: "john_doe Transport",
    ),
  ));
}

class Transporteurs extends StatefulWidget {
  final String name;
  final String profileUrl;
  final String username;

  const Transporteurs({
    super.key,
    required this.name,
    required this.profileUrl,
    required this.username,
  });

  @override
  State<Transporteurs> createState() => _TransporteursState();
}

class _TransporteursState extends State<Transporteurs> {
  int _selectedIndex = 0;
  final int _notificationCount = 3; // Example notification count

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
            items: [
              _bottomNavigationBarItem(
                icon: Icons.bookmark_add,
                label: 'Enregistrement',
                index: 0,
              ),
              _bottomNavigationBarItem(
                icon: Icons.car_crash,
                label: 'Tracking',
                index: 1,
              ),
              _bottomNavigationBarItem(
                icon: Icons.notifications_active,
                label: 'Notifications',
                index: 2,
              ),
              _bottomNavigationBarItem(
                icon: Icons.person,
                label: 'Profil',
                index: 3,
              ),
            ],
            selectedItemColor:
                const Color(0xFFFCCE00), // Couleur de l'élément sélectionné
            unselectedItemColor:
                Colors.black, // Couleur des éléments non sélectionnés
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
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
    switch (_selectedIndex) {
      case 0:
        return const EnregistrementPage();
      case 1:
        return const Tracking();
      case 2:
        return const NotificationPage();
      case 3:
        return const ProfilTransporteur();
      default:
        return Container();
    }
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      /*   appBar: AppBar(
        title: Text('Youtube Player Flutter'),
      ), */
      body: Column(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/hautTransport.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(),
            child:
                SizedBox.expand(), // Pour étendre le dégradé sur toute l'image
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Image.asset(
              'assets/images/ifret.png', // Chemin de votre image
              width: 70, // Largeur de l'image
              height: 70, // Hauteur de l'image
              fit: BoxFit.cover, // Ajustement de l'image
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
                    'Bienvenue sur I-FRET',
                    style: TextStyle(
                      color: Color(0xFFFCCE00),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  /* SizedBox(height: 5), */
                  Text(
                    'La plateforme de Gestion de FRET',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class EnregistrementPage extends StatefulWidget {
  const EnregistrementPage({super.key});

  @override
  _EnregistrementPageState createState() => _EnregistrementPageState();
}

class _EnregistrementPageState extends State<EnregistrementPage> {
  int _currentTabIndex = 0;
  late final List<File> _files =
      List.filled(4, File('')); // Initialisation avec des fichiers vides
  final TextEditingController _matriculeController = TextEditingController();

  Future<void> _pickFile(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png'
      ], // Définir les extensions autorisées
    );

    if (result != null) {
      final filePath = result.files.single.path!;
      setState(() {
        _files[index] = File(filePath); // Mettre à jour la liste des fichiers
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          Expanded(
            child: _currentTabIndex == 0
                ? Enregistrements(_files, _pickFile, _matriculeController)
                : const Catalogue(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentTabIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border:
                    Border.all(color: const Color.fromARGB(255, 252, 250, 250)),
                color: _currentTabIndex == 0 ? const Color(0xFFFCCE00) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_sharp,
                      color:
                          _currentTabIndex == 0 ? Colors.white : Colors.black),
                  const SizedBox(width: 8.0),
                  Text(
                    'Enregistrements',
                    style: TextStyle(
                        color: _currentTabIndex == 0
                            ? Colors.white
                            : Colors.black),
                  ),
                ],
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border:
                    Border.all(color: const Color.fromARGB(255, 247, 245, 245)),
                color: _currentTabIndex == 1 ? const Color(0xFFFCCE00) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_sharp,
                      color:
                          _currentTabIndex == 1 ? Colors.white : Colors.black),
                  const SizedBox(width: 8.0),
                  Text(
                    'Catalogue',
                    style: TextStyle(
                        color: _currentTabIndex == 1
                            ? Colors.white
                            : Colors.black),
                  ),
                ],
              ),
            ),
            label: '',
          ),
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
            'assets/images/hautTransport.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
                /*  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Color.fromARGB(255, 248, 134, 3).withOpacity(0.3),
                ],
              ), */
                ),
            child:
                SizedBox.expand(), // Pour étendre le dégradé sur toute l'image
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Image.asset(
              'assets/images/ifret.png', // Chemin de votre image
              width: 70, // Largeur de l'image
              height: 70, // Hauteur de l'image
              fit: BoxFit.cover, // Ajustement de l'image
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 27, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentTabIndex == 0 ? 'Enregistrement' : 'Catalogue',
                    style: const TextStyle(
                      color: Color(0xFFFCCE00),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  /* SizedBox(height: 5), */
                  const Text(
                    'Camion',
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

enum PhotoField { PhotoCamion, CarteGrise, VisiteTechnique, Assurance }

class Enregistrements extends StatefulWidget {
  final List<File> files;
  final Function(int) pickFile;
  final TextEditingController matriculeController;

  const Enregistrements(this.files, this.pickFile, this.matriculeController,
      {super.key});

  @override
  _EnregistrementsState createState() => _EnregistrementsState();
}

class _EnregistrementsState extends State<Enregistrements> {
  String matricule = ""; // Champ pour le numéro de matricule
  File? photoCamion;
  File? carteGrise;
  File? visiteTechnique;
  File? assurance;
  String?
      selectedTypeVehicule; // Variable pour stocker la sélection du type de véhicule

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Champ pour le numéro de matricule
        buildTextField(
          label: 'Numéro d\'immatriculation :',
          onChanged: (value) => setState(() => matricule = value),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          textFieldWidth: 190,
          textFieldHeight: 42,
          hintText: 'Ex: 22442890',
        ),
        const SizedBox(height: 10),

        // Ajout du champ de sélection pour le type de véhicule
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Type de véhicule'),
          value: selectedTypeVehicule,
          onChanged: (String? newValue) {
            setState(() {
              selectedTypeVehicule = newValue;
            });
          },
          items: <String>[
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
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        // Champ d'image pour la photo du camion
        buildImageField(
          label: "Photo du Camion",
          file: photoCamion,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          textFieldWidth: 190,
          textFieldHeight: 42,
          onPressed: () => _pickAndSetFile(PhotoField.PhotoCamion),
        ),
        const SizedBox(height: 10),

        // Champ d'image pour la carte grise
        buildImageField(
          label: "Carte Grise",
          file: carteGrise,
          onPressed: () => _pickAndSetFile(PhotoField.CarteGrise),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          textFieldWidth: 190,
          textFieldHeight: 42,
        ),
        const SizedBox(height: 10),

        // Champ d'image pour la visite technique
        buildImageField(
          label: "Visite Technique",
          file: visiteTechnique,
          onPressed: () => _pickAndSetFile(PhotoField.VisiteTechnique),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          textFieldWidth: 190,
          textFieldHeight: 42,
        ),
        const SizedBox(height: 10),

        // Champ d'image pour l'assurance
        buildImageField(
          label: "Assurance",
          file: assurance,
          onPressed: () => _pickAndSetFile(PhotoField.Assurance),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          textFieldWidth: 190,
          textFieldHeight: 42,
        ),
        const SizedBox(height: 30),

        ElevatedButton(
          onPressed: () async {
            if (matricule.isEmpty || selectedTypeVehicule == null) {
              // Vérifier que tous les champs obligatoires sont remplis
              _showAlertDialog(context, "Erreur",
                  "Veuillez remplir tous les champs obligatoires");
              return;
            }

            if (photoCamion == null ||
                carteGrise == null ||
                visiteTechnique == null ||
                assurance == null) {
              // Gérer l'erreur de fichiers d'image manquants
              _showAlertDialog(
                  context, "Erreur", "Veuillez sélectionner toutes les images");
              return;
            }

            List<File> files = [
              photoCamion!,
              carteGrise!,
              visiteTechnique!,
              assurance!,
            ];

            try {
              final response = await ApiRequest.registerTruck(
                matricule: matricule,
                files: files,
                photoCamion: photoCamion!,
                carteGrise: carteGrise!,
                visiteTechnique: visiteTechnique!,
                assurance: assurance!,
                typeVehicule: selectedTypeVehicule!, // Ajoutez ce champ ici
              );

              _showAlertDialog(
                  context, "Succès", "Enregistrement effectué avec succès");
            } on Exception catch (e) {
              _showAlertDialog(context, "Erreur",
                  "Erreur lors de l'enregistrement: ${e.toString()}");
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              const Color(0xFFFCCE00),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            minimumSize: WidgetStateProperty.all<Size>(
              const Size(120, 48), // Définir la largeur minimale du bouton
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Valider',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Méthode pour afficher une boîte de dialogue d'alerte
  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fonction pour créer un champ de texte
  Widget buildTextField(
      {required String label,
      required ValueChanged<String> onChanged,
      required EdgeInsets padding,
      required int textFieldWidth,
      required int textFieldHeight,
      required String hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 190,
          height: 42,
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: ' Ex: 22442890',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide: const BorderSide(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Fonction pour créer chaque champ d'image
  Widget buildImageField({
    required String label,
    required File? file,
    required VoidCallback onPressed,
    required EdgeInsets padding,
    required int textFieldWidth,
    required int textFieldHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            ElevatedButton(
              onPressed: onPressed,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  const Color(0xFFFCCE00), // Existing background color
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white; // White text when pressed
                    } else {
                      return Colors.black; // Black text by default
                    }
                  },
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(45),
                  ),
                ),
                minimumSize: WidgetStateProperty.all<Size>(
                  const Size(120, 48), // Minimum button size
                ),
              ),
              child: const Text('Sélectionner un fichier'), // Button text
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                file != null
                    ? file.path.split('/').last
                    : 'Aucun fichier sélectionné',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Fonction pour sélectionner et définir un fichier pour chaque champ d'image
  Future<void> _pickAndSetFile(PhotoField field) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      final filePath = result.files.single.path!;
      setState(() {
        switch (field) {
          case PhotoField.PhotoCamion:
            photoCamion = File(filePath);
            break;
          case PhotoField.CarteGrise:
            carteGrise = File(filePath);
            break;
          case PhotoField.VisiteTechnique:
            visiteTechnique = File(filePath);
            break;
          case PhotoField.Assurance:
            assurance = File(filePath);
            break;
        }
      });
    }
  }
}

class Catalogue extends StatefulWidget {
  const Catalogue({super.key});

  @override
  _CatalogueState createState() => _CatalogueState();
}

class _CatalogueState extends State<Catalogue> {
  List<dynamic> _camionsEnAttente = [];
  List<dynamic> _camionsValides = [];
  List<dynamic> _camionsRejetes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCamions();
  }

  Future<void> _fetchCamions() async {
    try {
      List<dynamic> camions = await ApiRequest.getUserCamions();
      setState(() {
        _camionsEnAttente =
            camions.where((camion) => camion['statut'] == 'En attent').toList();
        _camionsValides =
            camions.where((camion) => camion['statut'] == 'Validé').toList();
        _camionsRejetes =
            camions.where((camion) => camion['statut'] == 'Rejeté').toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToCorrectionPage(String matricule) async {
    try {
      Map<String, dynamic> camionDetails =
          await ApiRequest.getCamionDetails(matricule);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnregistrerCamionModifPage(
              matricule: matricule, details: camionDetails),
        ),
      );
    } catch (e) {
      print('Erreur lors de la récupération des détails du camion: $e');
      // Gérez les erreurs ici, par exemple, en affichant un message d'erreur à l'utilisateur
    }
  }

  Widget _buildCamionTable(List<dynamic> camions, bool showActions) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15), // Espace entre chaque camion
          ...camions.map((camion) {
            bool isModifiable =
                camion['statut'] != 'Validé' && camion['statut'] != 'En attent';

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  onTap: () {
                    if (isModifiable) {
                      _navigateToCorrectionPage(camion['matricule']);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  tileColor: Colors.white,
                  leading: const Icon(Icons.directions_car,
                      color: Color(0xFFFCCE00)),
                  title: Text(
                    camion['matricule'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(camion['created_at']),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        camion['statut'],
                        style: TextStyle(
                          color: _getStatutColor(camion['statut']),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing:
                      isModifiable ? const Icon(Icons.arrow_forward_ios) : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd MMM yyyy - kk:mm').format(dateTime);
    return formattedDate;
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'En attent':
        return const Color(0xFFFCCE00);
      case 'Validé':
        return Colors.green;
      case 'Rejeté':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('En attente',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildCamionTable(_camionsEnAttente, false),
                      const SizedBox(height: 20),
                      const Text('Validé(s)',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildCamionTable(_camionsValides, false),
                      const SizedBox(height: 20),
                      const Text('Rejeté(s)',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildCamionTable(_camionsRejetes, true),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

const kGoogleApiKey =
    "AIzaSyA26h7EKkKUUYcy-PvyFDS_Zc2DJmsWVVw"; // Remplacez par votre clé API Google

class Tracking extends StatelessWidget {
  const Tracking({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapsHomePage(); // Remplacer par la carte Google Maps
  }
}

class MapsHomePage extends StatefulWidget {
  const MapsHomePage({super.key});

  @override
  _MapsHomePageState createState() => _MapsHomePageState();
}

class _MapsHomePageState extends State<MapsHomePage> {
  GoogleMapController? mapController;
  TextEditingController _searchController = TextEditingController();
  final GoogleMapsPlaces places =
      GoogleMapsPlaces(apiKey: kGoogleApiKey); // Google Places API

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte Google Maps'),
      ),
      body: Stack(
        children: [
          // Carte Google Maps
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.3702928, 2.3912365), // Coordonnées de Cotonou
              zoom: 12,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // Barre de recherche pour les adresses
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Row(
              children: [
                Expanded(
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: _searchController,
                    googleAPIKey: kGoogleApiKey,
                    countries: ["bj"], // Limiter la recherche au Bénin
                    boxDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    inputDecoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Rechercher votre adresse à Cotonou",
                      hintStyle: GoogleFonts.inter(
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                    containerHorizontalPadding: 10,
                    itemClick: (prediction) async {
                      // Effacer le texte de recherche
                      _searchController.clear();

                      // Obtenir les détails du lieu sélectionné
                      PlacesDetailsResponse detail =
                          await places.getDetailsByPlaceId(prediction.placeId!);
                      final lat = detail.result.geometry!.location.lat;
                      final lng = detail.result.geometry!.location.lng;

                      // Rediriger la carte vers le lieu sélectionné
                      mapController?.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(lat, lng),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  int _notificationCount = 0; // Ajout du compteur de notifications

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    ApiRequest().fetchNotification({}).then((notification) {
      setState(() {
        _notifications.add(notification);
        _notificationCount++; // Incrémentation du compteur de notifications
      });
    }).catchError((error) {
      print('Error fetching notification: $error');
    });
  }

  void _markNotificationAsRead(int index) {
    setState(() {
      // Marquer la notification comme lue
      _notifications[index]['read'] = true;
      _notificationCount--; // Décrémentation du compteur de notifications
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tri des notifications en fonction de leur état de lecture
    _notifications.sort((a, b) {
      if (a['read'] == true && b['read'] == false) {
        return 1;
      } else if (a['read'] == false && b['read'] == true) {
        return -1;
      } else {
        return 0;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _notifications[index]['message'],
              // Utiliser le fontWeight en fonction de l'état de lecture de la notification
              style: TextStyle(
                fontWeight: _notifications[index]['read'] == true
                    ? FontWeight.normal
                    : FontWeight.bold,
              ),
            ),
            subtitle: Text(_notifications[index]['date']),
            onTap: () {
              // Lorsque l'utilisateur appuie sur la notification,
              // elle est marquée comme lue et retirée de la liste
              _markNotificationAsRead(index);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.notifications_active),
                if (_notificationCount !=
                    0) // Afficher l'indice uniquement si le compteur est différent de zéro
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}
 */
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _notifications = [];
  int _notificationCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      List<Map<String, dynamic>>? notifications =
          await ApiRequest.fetchNotifications();
      if (notifications != null) {
        setState(() {
          _notifications = notifications.map((notification) {
            // Formater la date ici
            String formattedDate = _formatDate(notification['created_at']);

            return {
              'id': notification['id'],
              'message': 'Fret Disponible', // Message fixe
              'date': formattedDate, // Date formatée
              'read': false, // par défaut non lu
            };
          }).toList();
          _updateNotificationCount(); // Mettre à jour le compteur initial
          _isLoading = false; // Arrêter l'indicateur de chargement
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        _isLoading =
            false; // Arrêter l'indicateur de chargement même en cas d'erreur
      });
    }
  }

  // Nouvelle fonction pour formater la date
  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
    return formattedDate;
  }

  // Fonction pour mettre à jour le compteur de notifications non lues
  void _updateNotificationCount() {
    setState(() {
      _notificationCount =
          _notifications.where((notification) => !notification['read']).length;
    });
  }

  // Fonction pour marquer une notification comme lue
  void _markAsRead(Map<String, dynamic> notification) {
    if (!notification['read']) {
      setState(() {
        notification['read'] = true;
        _updateNotificationCount(); // Mettre à jour le compteur après avoir marqué comme lu
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications ($_notificationCount)'),
        backgroundColor: Colors.grey[200],
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Afficher l'indicateur de chargement pendant le fetch
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                      height: 15), // Espace entre chaque notification
                  ..._notifications.map((notification) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          onTap: () {
                            _markAsRead(
                                notification); // Marquer la notification comme lue
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          tileColor: Colors.white,
                          leading: const Icon(Icons.notifications,
                              color: Color(0xFFFCCE00)),
                          title: Text(
                            notification['message'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: notification['read']
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            notification['date'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              print(
                                  'ID de la notification sélectionnée : ${notification['id']}'); // Print pour vérifier l'ID

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FutureBuilder<Map<String, dynamic>>(
                                    future: ApiRequest.fetchFretDetails(
                                        notification['id']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Erreur : ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data == null) {
                                        return const Center(
                                            child: Text(
                                                'Aucun détail disponible pour ce fret'));
                                      } else {
                                        final fret = snapshot.data!;
                                        return FretDetailsPage(
                                            fretDetails: fret);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color(0xFFFCCE00)),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Détails',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
      backgroundColor: Colors.grey[200], // Couleur de fond du Scaffold
    );
  }
}
