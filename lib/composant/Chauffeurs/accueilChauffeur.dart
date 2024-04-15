import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Chauffeurs/profilChauffeur.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';

class Chauffeur extends StatefulWidget {
  final String name;
  final String ParametreeUrl;
  final String username;

  Chauffeur({
    required this.name,
    required this.ParametreeUrl,
    required this.username,
  });

  @override
  State<Chauffeur> createState() => _ChauffeurState();
}

class _ChauffeurState extends State<Chauffeur> {
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
            icon: Icons.person_outlined,
            label: 'Profil',
            index: 0,
          ),
          _bottomNavigationBarItem(
            icon: Icons.notifications_active,
            label: 'Notification',
            index: 1,
          ),
          _bottomNavigationBarItem(
            icon: Icons.settings,
            label: 'Parametre',
            index: 2,
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
        return ProfilChauffeur();
      case 1:
        return Notification();
      case 2:
        return Parametre();
      default:
        return Notification();
    }
  }
}

class Notification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(
        title: Text('Notification'),
      ), */
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 20),
            _buildAnnonces(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    var _currentTabIndex;
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
              width: 100, // Largeur de l'image
              height: 100, // Hauteur de l'image
              fit: BoxFit.cover, // Ajustement de l'image
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 27, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Alertes ',
                    style: TextStyle(
                      color: Color(0xFFFCCE00),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  /* SizedBox(height: 5), */
                  /*  Text(
                    'fret',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ), */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnonces(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSingleAnnonce(
          'Annonce 1',
          'Description brève de l\'annonce 1',
          '10 Nov 2023',
          'assets/images/2.png',
        ),
        SizedBox(height: 20),
        _buildSingleAnnonce(
          'Annonce 2',
          'Description brève de l\'annonce 2',
          '17 dec 2023',
          'assets/images/2.png',
        ),
        SizedBox(height: 20),
        _buildSingleAnnonce(
          'Annonce 3',
          'Description brève de l\'annonce 3',
          '19 dec 2023',
          'assets/images/2.png',
        ),
      ],
    );
  }

  Widget _buildSingleAnnonce(
    String title,
    String description,
    String date,
    String imagePath,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () {
          // Action à effectuer lorsque la colonne est pressée
          // Par exemple, vous pouvez naviguer vers la page de Parametre de l'utilisateur
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                        fontSize: 10, color: Color.fromARGB(255, 252, 206, 0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Parametre extends StatefulWidget {
  @override
  _ParametreState createState() => _ParametreState();
}

class _ParametreState extends State<Parametre> {
  final TextEditingController _numeroPermisController = TextEditingController();
  String _categorieVehicule = 'A1';
  DateTime? _dateOptention;
  DateTime? _dateExpiration;
  List<File> _images = [];

  Future<void> _pickImages() async {
    final List<XFile>? pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _images = pickedImages.map((image) => File(image.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Renseignez vos Informations'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formulaire de permis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _numeroPermisController,
                    decoration: InputDecoration(
                      labelText: 'Numéro de permis',
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFFCCE00), width: 2.0),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _categorieVehicule,
                    onChanged: (value) {
                      setState(() {
                        _categorieVehicule = value!;
                      });
                    },
                    items: ['A1', 'A2', 'A3', 'B', 'C', 'CI', 'D', 'E', 'F']
                        .map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Catégorie de véhicule',
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFFCCE00), width: 2.0),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Date d\'obtention du permis :',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateOptention = pickedDate;
                      });
                    }
                  },
                  icon: Icon(Icons.calendar_today),
                ),
              ],
            ),
            if (_dateOptention != null)
              Text(
                'Date : ${DateFormat('dd/MM/yyyy').format(_dateOptention!)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Date d\'expiration du permis :',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dateExpiration = pickedDate;
                      });
                    }
                  },
                  icon: Icon(Icons.calendar_today),
                ),
              ],
            ),
            if (_dateExpiration != null)
              Text(
                'Date : ${DateFormat('dd/MM/yyyy').format(_dateExpiration!)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFCCE00), // background color
              ),
              child: Text(
                'Importer des images du permis',
                style: TextStyle(color: Colors.white), // text color
              ),
            ),
            SizedBox(height: 20),
            if (_images.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Images sélectionnées :',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _images.map((image) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(image),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Valider les données
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFCCE00), // background color
                ),
                child: Text(
                  'Valider',
                  style: TextStyle(color: Colors.white), // text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
