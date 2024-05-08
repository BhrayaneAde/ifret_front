import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Transporteurs/NotificationTransporteur.dart';
import 'package:ifret/composant/Transporteurs/profilTransporteur.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
          if (_notificationCount != 0)
            Positioned(
              top: 0,
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
        /*  buildTextField(
          label: 'Numéro d\'immatriculation :',
          onChanged: (value) {
            setState(() {
              matricule = value;
            });
          },
        ), */
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
        SizedBox(height: 10),
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
                fontSize: 18,
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

class Catalogue extends StatelessWidget {
  // Définir des valeurs par défaut pour les camions
  int camionsEnregistres = 100;
  int camionsValides = 50;
  int camionsEnAttente = 30;
  int camionsRejetes = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Afficher le nombre total de camions enregistrés
              Text(
                'Nombre de camions enregistrés : $camionsEnregistres',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20), // Espacement
              // Utilisation de CustomPaint pour dessiner le diagramme circulaire
              Container(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: PieChartPainter(
                    camionsValides: camionsValides,
                    camionsRejetes: camionsRejetes,
                    camionsEnAttente: camionsEnAttente,
                  ),
                ),
              ),
              SizedBox(height: 20), // Espacement
              // Légende du diagramme
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Color(0xff316eb5), 'Camions validés'),
                  _buildLegendItem(Color(0xffe7324c), 'Camions rejetés'),
                  _buildLegendItem(Color(0xfff5af19), 'Camions en attente'),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Action à effectuer lors du clic sur le bouton "Voir raison de rejet"
                        // Par exemple, afficher une boîte de dialogue avec la raison du rejet
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            Color(0xFFFCCE00), // foreground/text color
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Voir raison de rejet'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode utilitaire pour construire un élément de légende
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 20, height: 20, color: color),
        SizedBox(width: 5),
        Text(label),
        SizedBox(width: 10),
      ],
    );
  }
}

// Classe pour dessiner le diagramme circulaire
class PieChartPainter extends CustomPainter {
  final int camionsValides;
  final int camionsRejetes;
  final int camionsEnAttente;

  PieChartPainter({
    required this.camionsValides,
    required this.camionsRejetes,
    required this.camionsEnAttente,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(centerX, centerY);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Dessiner la section des camions validés
    paint.color = Color(0xff316eb5);
    _drawSection(canvas, centerX, centerY, radius, 0, camionsValides, paint);

    // Dessiner la section des camions rejetés
    paint.color = Color(0xffe7324c);
    _drawSection(canvas, centerX, centerY, radius,
        _calculateAngle(camionsValides), camionsRejetes, paint);

    // Dessiner la section des camions en attente
    paint.color = Color(0xFFFCCE00);
    _drawSection(
        canvas,
        centerX,
        centerY,
        radius,
        _calculateAngle(camionsValides) + _calculateAngle(camionsRejetes),
        camionsEnAttente,
        paint);
  }

  void _drawSection(Canvas canvas, double centerX, double centerY,
      double radius, double startAngle, int camions, Paint paint) {
    final double sweepAngle = _calculateAngle(camions);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      startAngle,
      sweepAngle,
      true,
      paint,
    );

    // Afficher le nombre de camions à côté de chaque section
    final double sectionCenterAngle = startAngle + sweepAngle / 2;
    final double sectionCenterX =
        centerX + (radius * 0.8) * math.cos(sectionCenterAngle);
    final double sectionCenterY =
        centerY + (radius * 0.8) * math.sin(sectionCenterAngle);

    final TextSpan span = TextSpan(
      style: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      text: camions.toString(),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas,
        Offset(sectionCenterX - tp.width / 2, sectionCenterY - tp.height / 2));
  }

  double _calculateAngle(int camions) {
    final int totalCamions = camionsValides + camionsRejetes + camionsEnAttente;
    return (camions / totalCamions) * 2 * math.pi;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
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
class NotificationPage extends StatelessWidget {
  List<Map<String, dynamic>> _notifications = [];
  int _notificationCount = 0; // Ajout du compteur de notifications

  NotificationPage() {
    // Simulation de l'ajout de notifications pour démonstration
    _notifications.addAll([
      {
        'message': 'Nouvelle commande reçue',
        'date': '10 avril 2024',
        'read': false,
      },
      {
        'message': 'Mise à jour de l\'application disponible',
        'date': '8 avril 2024',
        'read': true,
      },
      {
        'message': 'Nouvelle fonctionnalité ajoutée',
        'date': '6 avril 2024',
        'read': false,
      },
    ]);

    _notificationCount = _notifications.length;
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
        title: Text('Notification'),
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
          );
        },
      ),
    );
  }
}
