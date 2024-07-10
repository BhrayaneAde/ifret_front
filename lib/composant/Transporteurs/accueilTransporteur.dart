import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Transporteurs/EnregistrerCamionModif.dart';
import 'package:ifret/composant/Transporteurs/FretDetailsPage.dart';
import 'package:ifret/composant/Transporteurs/NotificationTransporteur.dart';
import 'package:ifret/composant/Transporteurs/profilTransporteur.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';

import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent,
    ),
  );
  runApp(MaterialApp(
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

  Transporteurs({
    required this.name,
    required this.profileUrl,
    required this.username,
  });

  @override
  State<Transporteurs> createState() => _TransporteursState();
}

class _TransporteursState extends State<Transporteurs> {
  int _selectedIndex = 0;
  int _notificationCount = 3; // Example notification count

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
                Color(0xFFFCCE00), // Couleur de l'élément sélectionné
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
        return EnregistrementPage();
      case 1:
        return Tracking();
      case 2:
        return NotificationPage();
      case 3:
        return ProfilTransporteur();
      default:
        return Container();
    }
  }
}

class Home extends StatefulWidget {
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
    return Scaffold(
      /*   appBar: AppBar(
        title: Text('Youtube Player Flutter'),
      ), */
      body: Column(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
          DecoratedBox(
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
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 27, bottom: 10),
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
  const EnregistrementPage({Key? key}) : super(key: key);

  @override
  _EnregistrementPageState createState() => _EnregistrementPageState();
}

class _EnregistrementPageState extends State<EnregistrementPage> {
  int _currentTabIndex = 0;
  late List<File> _files =
      List.filled(4, File('')); // Initialisation avec des fichiers vides
  TextEditingController _matriculeController = TextEditingController();

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
          SizedBox(height: 20),
          Expanded(
            child: _currentTabIndex == 0
                ? Enregistrements(_files, _pickFile, _matriculeController)
                : Catalogue(),
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
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border:
                    Border.all(color: const Color.fromARGB(255, 252, 250, 250)),
                color: _currentTabIndex == 0 ? Color(0xFFFCCE00) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_sharp,
                      color:
                          _currentTabIndex == 0 ? Colors.white : Colors.black),
                  SizedBox(width: 8.0),
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
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Color.fromARGB(255, 247, 245, 245)),
                color: _currentTabIndex == 1 ? Color(0xFFFCCE00) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_sharp,
                      color:
                          _currentTabIndex == 1 ? Colors.white : Colors.black),
                  SizedBox(width: 8.0),
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
    return Container(
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
          DecoratedBox(
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
                    style: TextStyle(
                      color: Color(0xFFFCCE00),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  /* SizedBox(height: 5), */
                  Text(
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

  Enregistrements(this.files, this.pickFile, this.matriculeController);

  @override
  _EnregistrementsState createState() => _EnregistrementsState();
}

class _EnregistrementsState extends State<Enregistrements> {
  String matricule = ""; // Champ pour le numéro de matricule
  File? photoCamion;
  File? carteGrise;
  File? visiteTechnique;
  File? assurance;

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
        SizedBox(height: 10),
        // Champ d'image pour la photo du camion
        buildImageField(
          label: "Photo du Camion",
          file: photoCamion,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          textFieldWidth: 190,
          textFieldHeight: 42,
          onPressed: () => _pickAndSetFile(PhotoField.PhotoCamion),
        ),
        SizedBox(height: 10),
        // Champ d'image pour la carte grise
        buildImageField(
          label: "Carte Grise",
          file: carteGrise,
          onPressed: () => _pickAndSetFile(PhotoField.CarteGrise),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          textFieldWidth: 190,
          textFieldHeight: 42,
        ),
        SizedBox(height: 10),
        // Champ d'image pour la visite technique
        buildImageField(
          label: "Visite Technique",
          file: visiteTechnique,
          onPressed: () => _pickAndSetFile(PhotoField.VisiteTechnique),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          textFieldWidth: 190,
          textFieldHeight: 42,
        ),
        SizedBox(height: 10),
        // Champ d'image pour l'assurance
        buildImageField(
          label: "Assurance",
          file: assurance,
          onPressed: () => _pickAndSetFile(PhotoField.Assurance),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          textFieldWidth: 190,
          textFieldHeight: 42,
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            if (matricule.isEmpty) {
              // Gérer l'erreur de matricule vide
              _showAlertDialog(context, "Erreur",
                  "Le numéro de matricule ne peut pas être vide");
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
                files: [
                  photoCamion!,
                  carteGrise!,
                  visiteTechnique!,
                  assurance!
                ],
                photoCamion: photoCamion!,
                carteGrise: carteGrise!,
                visiteTechnique: visiteTechnique!,
                assurance: assurance!,
              );
              // Gérer la réponse réussie (par exemple, afficher un message de succès)
              _showAlertDialog(
                  context, "Succès", "Enregistrement effectué avec succès");
              print('Enregistrement effectué avec succès!');
              // Mettre à jour l'interface utilisateur ou effectuer d'autres actions

              // Update UI or perform other actions
            } on Exception catch (e) {
              // Gérer l'erreur de la requête API (par exemple, afficher un message d'erreur)
              _showAlertDialog(context, "Erreur",
                  "Erreur lors de l'enregistrement: ${e.toString()}");
              print('Erreur d\'enregistrement: ${e.toString()}');
              // Afficher un message d'erreur à l'utilisateur
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Color(0xFFFCCE00),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            minimumSize: MaterialStateProperty.all<Size>(
              Size(120, 48), // Définir la largeur minimale du bouton
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
              child: Text('OK'),
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
            style: TextStyle(fontWeight: FontWeight.bold),
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
                borderSide: BorderSide(color: Colors.black),
              ),
              contentPadding: EdgeInsets.symmetric(
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            ElevatedButton(
              onPressed: onPressed,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color(0xFFFCCE00), // Existing background color
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.white; // White text when pressed
                    } else {
                      return Colors.black; // Black text by default
                    }
                  },
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(45),
                  ),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(120, 48), // Minimum button size
                ),
              ),
              child: Text('Sélectionner un fichier'), // Button text
            ),
            SizedBox(width: 10),
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
        SizedBox(height: 10),
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
      if (camions != null) {
        setState(() {
          _camionsEnAttente = camions
              .where((camion) => camion['statut'] == 'En attent')
              .toList();
          _camionsValides =
              camions.where((camion) => camion['statut'] == 'Validé').toList();
          _camionsRejetes =
              camions.where((camion) => camion['statut'] == 'Rejeté').toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
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
          SizedBox(height: 15), // Espace entre chaque camion
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
                  leading: Icon(Icons.directions_car, color: Color(0xFFFCCE00)),
                  title: Text(
                    camion['matricule'],
                    style: TextStyle(
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
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 5),
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
                  trailing: isModifiable ? Icon(Icons.arrow_forward_ios) : null,
                ),
              ),
            );
          }).toList(),
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
        return Color(0xFFFCCE00);
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
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('En attente',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildCamionTable(_camionsEnAttente, false),
                      SizedBox(height: 20),
                      Text('Validé(s)',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildCamionTable(_camionsValides, false),
                      SizedBox(height: 20),
                      Text('Rejeté(s)',
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

class Tracking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking'),
      ),
      body: Center(
        child: Text('Contenu de Tracking'),
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
          ? Center(
              child:
                  CircularProgressIndicator()) // Afficher l'indicateur de chargement pendant le fetch
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15), // Espace entre chaque notification
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
                          leading: Icon(Icons.notifications,
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
                            style: TextStyle(
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
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Erreur : ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data == null) {
                                        return Center(
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFFFCCE00)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                            ),
                            child: Text(
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
                  }).toList(),
                ],
              ),
            ),
      backgroundColor: Colors.grey[200], // Couleur de fond du Scaffold
    );
  }
}
