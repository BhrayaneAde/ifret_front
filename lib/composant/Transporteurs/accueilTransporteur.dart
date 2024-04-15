import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
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
  int _currentIndex = 0;

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
        backgroundColor: Colors.white, // Couleur de fond blanc
        selectedItemColor:
            Color(0xFFFCCE00), // Couleur de l'élément sélectionné
        unselectedItemColor:
            Colors.black, // Couleur des éléments non sélectionnés
        items: [
          _bottomNavigationBarItem(
            icon: Icons.home_filled,
            label: 'Home',
            index: 0,
          ),
          _bottomNavigationBarItem(
            icon: Icons.bookmark_add,
            label: 'Enregistrement',
            index: 1,
          ),
          _bottomNavigationBarItem(
            icon: Icons.car_crash,
            label: 'Tracking',
            index: 2,
          ),
          _bottomNavigationBarItem(
            icon: Icons.notifications_active,
            label: 'Notification',
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
      backgroundColor: Colors.white, // Fond blanc pour tous les éléments
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return ProfilTransporteur();
      case 1:
        return EnregistrementPage();
      case 2:
        return Tracking();
      case 3:
        return Notification();
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
    _controller = YoutubePlayerController(
      initialVideoId: 'u8H652UY-L8', // ID de la vidéo YouTube
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*   appBar: AppBar(
        title: Text('Youtube Player Flutter'),
      ), */
      body: Column(children: [
        _buildHeader(context),
        SizedBox(height: 50),
        Center(
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            onReady: () {
              // Ajoutez ici tout code nécessaire une fois que la vidéo est prête
              print('La vidéo est prête à être lue');
            },
            onEnded: (data) {
              print('La vidéo est terminée');
            },
          ),
        ),
      ]),
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
  List<File?> _files = List.filled(4, null);
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
        _files[index] = File(filePath);
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

class Enregistrements extends StatefulWidget {
  final List<File?> files;
  final Function(int) pickFile;
  final TextEditingController matriculeController;

  Enregistrements(this.files, this.pickFile, this.matriculeController);

  @override
  _EnregistrementsState createState() => _EnregistrementsState();
}

class _EnregistrementsState extends State<Enregistrements> {
  bool validated = false;
  List<String> fileLabels = [
    "Photo du Camion",
    "Carte Grise",
    "Visite Technique",
    "Assurance",
  ];
  List<bool> fileImported = [
    false,
    false,
    false,
    false
  ]; // Pour suivre l'état d'importation de chaque fichier

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        /* SizedBox(height: 10), */
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Numéro d\'immatriculation :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 190,
              height: 42,
              child: TextField(
                controller: widget.matriculeController,
                decoration: InputDecoration(
                  hintText: ' Ex: 22442890',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45),
                  ),
                  filled: true, // Activer le remplissage de l'arrière-plan
                  fillColor: Colors
                      .grey[200], // Couleur de remplissage de l'arrière-plan
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45),
                    borderSide:
                        BorderSide(color: Colors.black), // Bordure en focus
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10.0, // Réduire la hauteur du TextField
                    horizontal: 15.0, // Réduire la largeur du TextField
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            for (int i = 0; i < 4; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileLabels[i],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _pickAndSetFile(i), // Nouvelle méthode
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            if (fileImported[i]) {
                              return Colors
                                  .green; // Fond vert lorsque le fichier est importé
                            } else if (states.contains(MaterialState.pressed)) {
                              return Colors
                                  .grey; // Fond gris lorsqu'appuyé avant l'importation
                            } else {
                              return Colors.white; // Fond blanc par défaut
                            }
                          }),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                            if (fileImported[i]) {
                              return Colors
                                  .white; // Texte blanc lorsque le fichier est importé
                            } else if (states.contains(MaterialState.pressed)) {
                              return Colors
                                  .black; // Texte noir lorsqu'appuyé avant l'importation
                            } else {
                              return Colors.grey; // Texte gris par défaut
                            }
                          }),
                          side: MaterialStateProperty.all<BorderSide>(
                            BorderSide(
                              color: Colors.black, // Bordure noire
                            ),
                          ),
                        ),
                        child: Text('Sélectionner un fichier'),
                      ),
                      SizedBox(width: 10),
                      if (widget.files[i] != null)
                        Expanded(
                          child: Text(
                            widget.files[i]!.path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
          ],
        ),
        SizedBox(height: 20),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              validated = true;
            });
            // Enregistrez les fichiers et le numéro de matricule
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

  Future<void> _pickAndSetFile(int index) async {
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
        widget.files[index] = File(filePath);
        fileImported[index] = true; // Mettre à jour l'état d'importation
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

class Notification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: Center(
        child: Text('Contenu de Notification'),
      ),
    );
  }
}
