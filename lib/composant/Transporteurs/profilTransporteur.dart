import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Chargeurs/trafficChargeur.dart';
import 'package:ifret/composant/Transporteurs/trafficTransporteur.dart';
import 'package:ifret/composant/service/clientele.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilTransporteur extends StatefulWidget {
  @override
  _ProfilTransporteurState createState() => _ProfilTransporteurState();
}

class _ProfilTransporteurState extends State<ProfilTransporteur> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  String _dateOfBirth = '';
  String _residence = '';
  String _accountType = '';
  File? _image;
  String authToken = ''; // Variable pour stocker le token d'authentification

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _getAuthToken(); // Appelez la méthode pour obtenir le token d'authentification
  }

  Future<void> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('auth_token') ??
          ''; // Utilisez une chaîne vide si le token n'est pas trouvé
    });
    _fetchUserData(); // Appelez la méthode pour récupérer les données de l'utilisateur une fois que vous avez le token
  }

  Future<void> _fetchUserData() async {
    try {
      // Appeler la fonction fetchUserData depuis la classe ApiRequest
      Map<String, dynamic>? userData = await ApiRequest.fetchUserData();
      if (userData != null) {
        // Mettre à jour l'état de l'application avec les données récupérées
        setState(() {
          _firstNameController.text = userData['prenom'];
          _lastNameController.text = userData['nom'];

          _dateOfBirth = userData['date_naissance'];
          _residence = userData['ville'];
          _accountType = userData['type_compte'];
        });
      } else {
        print('Aucune donnée utilisateur récupérée');
      }
    } catch (e) {
      print('Erreur lors de la récupération des données de l\'utilisateur: $e');
    }
  }

  bool _isImagePickerActive = false;

  Future<void> _getImage() async {
    if (!_isImagePickerActive) {
      setState(() {
        _isImagePickerActive = true; // Activer le sélecteur d'image
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        _isImagePickerActive =
            false; // Désactiver le sélecteur d'image après la sélection
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('Aucune image sélectionnée.');
        }
      });
    } else {
      print(
          'Le sélecteur d\'image est déjà actif.'); // Gérer le cas où le sélecteur d'image est déjà actif
    }
  }

  Future<void> _getImageAndUpload() async {
    if (!_isImagePickerActive) {
      setState(() {
        _isImagePickerActive = true; // Activer le sélecteur d'image
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        _isImagePickerActive =
            false; // Désactiver le sélecteur d'image après la sélection
        if (pickedFile != null) {
          _image = File(pickedFile.path);

          // Appeler la méthode pour mettre à jour le profil avec l'image sélectionnée
          _updateProfileWithImage(_image!);
        } else {
          print('Aucune image sélectionnée.');
        }
      });
    } else {
      print(
          'Le sélecteur d\'image est déjà actif.'); // Gérer le cas où le sélecteur d'image est déjà actif
    }
  }

  Future<void> _updateProfileWithImage(File image) async {
    try {
      // Récupérer les autres informations de l'utilisateur
      Map<String, dynamic> userData = {
        'prenom': _firstNameController.text,
        'nom': _lastNameController.text,
        'date_naissance': _dateOfBirth,
        'ville': _residence,
        'type_compte': _accountType,
      };

      // Appeler la méthode pour mettre à jour le profil avec l'image
      await ApiRequest.updateUserProfileWithImage(
          userData: userData, image: image);
    } catch (e) {
      print('Erreur lors de la mise à jour du profil avec image: $e');
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifierProfil(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          dateOfBirth: _dateOfBirth,
          residence: _residence,
          accountType: _accountType,
          onUpdate: _updateProfileData,
        ),
      ),
    );
  }

  void _updateProfileData({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String residence,
    required String accountType,
  }) {
    setState(() {
      _firstNameController.text = firstName;
      _lastNameController.text = lastName;

      _dateOfBirth = dateOfBirth;
      _residence = residence;
      _accountType = accountType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(), // Pousser le widget RichText vers la droite
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                      text: 'Profil', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor:
            Color(0xFFFCCE00), // Définir la couleur de fond en noir
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Votre contenu actuel ici

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors
                        .grey[200], // Set the background color to light grey
                    borderRadius: BorderRadius.circular(
                        10.0), // Add rounded corners (optional)
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : Image.asset('assets/images/profil.jpg')
                                      .image,
                              child: _image == null
                                  ? SizedBox() // Si aucune image n'est sélectionnée, ne pas afficher de texte
                                  : null,
                            ),
                            Positioned(
                              bottom: 2,
                              right: 45,
                              child: GestureDetector(
                                onTap: () {
                                  if (!_isImagePickerActive) {
                                    _getImage();
                                  } else {
                                    print(
                                        'Le sélecteur d\'image est déjà actif.');
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    size: 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                '${_firstNameController.text.toUpperCase()} ',
                                /* ${_lastNameController.text} */
                                textAlign: TextAlign.start,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  shadows: [
                                    Shadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                _accountType,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  shadows: [
                                    Shadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      blurRadius: 2,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              // Deuxième ligne
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 10), // Padding horizontal de 10
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Forme du ListTile
                  ),
                  child: ListTile(
                    onTap: _editProfile,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Forme du ListTile
                    ),
                    tileColor: Color(0xfffcce00), // Couleur de fond du ListTile
                    title: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 30,
                        ),
                        SizedBox(
                            width: 16), // Espacement entre l'icône et le texte
                        Text(
                          'Modifier le profil',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: _editProfile,
                      color: Colors.black,
                      splashRadius: 20,
                      padding: EdgeInsets
                          .zero, // Supprimer le rembourrage autour de l'icône
                      constraints:
                          BoxConstraints(), // Permet à l'IconButton de se redimensionner en fonction de son contenu
                      alignment:
                          Alignment.center, // Alignement de l'icône au centre
                      visualDensity: VisualDensity
                          .compact, // Densité visuelle compacte pour réduire l'espace autour de l'icône
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(10), // Padding horizontal de 10
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Forme du ListTile
                  ),
                  child: ListTile(
                    onTap: () {
                      // Action pour la liste des trafics
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrafficTransporteur(),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Forme du ListTile
                    ),
                    tileColor: Color(0xfffcce00), // Couleur de fond du ListTile
                    title: Row(
                      children: [
                        Icon(
                          Icons.list,
                          color: Colors.black,
                          size: 30,
                        ),
                        SizedBox(
                            width: 16), // Espacement entre l'icône et le texte
                        Text(
                          'Historique Voyage',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        // Action pour le bouton ">"
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrafficTransporteur(),
                          ),
                        );
                      },
                      color: Colors.black,
                      splashRadius: 20,
                      padding: EdgeInsets
                          .zero, // Supprimer le rembourrage autour de l'icône
                      constraints:
                          BoxConstraints(), // Permet à l'IconButton de se redimensionner en fonction de son contenu
                      alignment:
                          Alignment.center, // Alignement de l'icône au centre
                      visualDensity: VisualDensity
                          .compact, // Densité visuelle compacte pour réduire l'espace autour de l'icône
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5), // Espacement entre les boutons
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 10), // Padding horizontal de 10
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Forme du ListTile
                  ),
                  child: ListTile(
                    onTap: () {
                      // Action pour la liste des trafics
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Clientele(),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10.0), // Forme du ListTile
                    ),
                    tileColor: Color(0xfffcce00), // Couleur de fond du ListTile
                    title: Row(
                      children: [
                        Icon(
                          Icons.support_agent_rounded,
                          color: Colors.black,
                          size: 30,
                        ),
                        SizedBox(
                            width: 16), // Espacement entre l'icône et le texte
                        Text(
                          'Service Clientèle',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        // Action pour le bouton ">"
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Clientele(),
                          ),
                        );
                      },
                      color: Colors.black,
                      splashRadius: 20,
                      padding: EdgeInsets
                          .zero, // Supprimer le rembourrage autour de l'icône
                      constraints:
                          BoxConstraints(), // Permet à l'IconButton de se redimensionner en fonction de son contenu
                      alignment:
                          Alignment.center, // Alignement de l'icône au centre
                      visualDensity: VisualDensity
                          .compact, // Densité visuelle compacte pour réduire l'espace autour de l'icône
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Action pour la politique de confidentialité
                            },
                            child: Text(
                              'Politique de confidentialité',
                              style: TextStyle(
                                color: Color(0xfffcce00),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Action pour les conditions générales d'utilisation
                            },
                            child: Text(
                              'Conditions générales',
                              style: TextStyle(
                                color: Color(0xfffcce00),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    height: 10), // Espacement par rapport au bas de l'écran
                Text(
                  'Version 1.0', // Texte de la version de l'application
                  style: TextStyle(
                    color: Colors.grey, // Couleur du texte
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

class ModifierProfil extends StatelessWidget {
  final String firstName;
  final String lastName;

  final String dateOfBirth;
  final String accountType; // Nouveau champ pour le type de compte
  final String residence;
  final Function onUpdate;

  void _showToast() {
    Fluttertoast.showToast(
      msg: "Profil mis à jour avec succès",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.black,
      fontSize: 20.0,
    );
  }

  // Définir des clés pour chaque champ
  static const String KEY_FIRST_NAME = 'prenom';
  static const String KEY_LAST_NAME = 'nom';

  static const String KEY_DATE_OF_BIRTH = 'date_naissance';
  static const String KEY_ACCOUNT = 'type_compte';
  static const String KEY_RESIDENCE = 'ville';

  ModifierProfil({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.accountType,
    required this.residence,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController _newFirstNameController =
        TextEditingController(text: firstName);
    TextEditingController _newLastNameController =
        TextEditingController(text: lastName);

    TextEditingController _newDateOfBirthController =
        TextEditingController(text: dateOfBirth);

    TextEditingController _newResidenceController =
        TextEditingController(text: residence);
    TextEditingController _newAccountTypeController =
        TextEditingController(text: accountType);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(), // Pousser le widget RichText vers la droite
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                      text: 'Information  ',
                      style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor:
            Color(0xFFFCCE00), // Définir la couleur de fond en noir
        leading: IconButton(
          icon: Icon(Icons
              .arrow_back), // Supposant que vous voulez un bouton de retour
          color: Colors.black, // Définir la couleur du bouton en blanc
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableInfoItem(
              'Prénom:',
              _newFirstNameController,
              Icons.person,
              () => _showEditDialog(
                  context, 'Prénom', _newFirstNameController, KEY_FIRST_NAME),
            ),
            SizedBox(height: 20),
            _buildEditableInfoItem(
              'Nom:',
              _newLastNameController,
              Icons.person,
              () => _showEditDialog(
                  context, 'Nom', _newLastNameController, KEY_LAST_NAME),
            ),
            SizedBox(height: 20),
            _buildEditableInfoItem(
              'Date de naissance:',
              _newDateOfBirthController,
              Icons.calendar_today,
              () => _showEditDialog(context, 'Date de naissance',
                  _newDateOfBirthController, KEY_DATE_OF_BIRTH),
            ),
            SizedBox(height: 20),
            _buildEditableInfoItem(
              'Lieu de résidence:',
              _newResidenceController,
              Icons.location_city,
              () => _showEditDialog(context, 'Lieu de résidence',
                  _newResidenceController, KEY_RESIDENCE),
            ),
            SizedBox(height: 20),
            _buildInfoContainer(
              'Compte:', // Label du champ
              _newAccountTypeController.text, // Contrôleur du champ
              Icons.account_circle, // Icône associée
            ),
            SizedBox(height: 50),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  onUpdate(
                    firstName: _newFirstNameController.text,
                    lastName: _newLastNameController.text,
                    dateOfBirth: _newDateOfBirthController.text,
                    residence: _newResidenceController.text,
                    accountType: _newAccountTypeController.text,
                  );

                  // Appeler la fonction pour mettre à jour le profil sur le backend
                  _updateUserProfile(
                    firstName: _newFirstNameController.text,
                    lastName: _newLastNameController.text,
                    dateOfBirth: _newDateOfBirthController.text,
                    residence: _newResidenceController.text,
                    accountType: _newAccountTypeController.text,
                  );

                  _showToast(); // Afficher le toast après la mise à jour

                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFFFCCE00)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                    'Enregistrer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour mettre à jour le profil sur le backend
  Future<void> _updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? dateOfBirth,
    String? residence,
    String? accountType,
  }) async {
    try {
      // Appeler la fonction d'API pour mettre à jour le profil
      await ApiRequest.updateUserProfile({
        ModifierProfil.KEY_FIRST_NAME: firstName,
        ModifierProfil.KEY_LAST_NAME: lastName,
        ModifierProfil.KEY_DATE_OF_BIRTH: dateOfBirth,
        ModifierProfil.KEY_RESIDENCE: residence,
        ModifierProfil.KEY_ACCOUNT: accountType,
      });
    } catch (e) {
      // Gérer les erreurs de mise à jour du profil
      print('Erreur lors de la mise à jour du profil: $e');
      // Afficher un message d'erreur à l'utilisateur si nécessaire
    }
  }

  Future<void> _showDatePicker(
      BuildContext context, TextEditingController controller) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          DateTime.parse(controller.text), // Set initial date from controller
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      controller.text = selectedDate
          .toString()
          .split(' ')[0]; // Update controller with formatted date
    }
  }

  Widget _buildEditableInfoItem(
    String label,
    TextEditingController controller,
    IconData iconData,
    VoidCallback onPressed,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Forme du Card
      ),
      child: ListTile(
        onTap: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Forme du ListTile
        ),
        tileColor: const Color(0xfffcce00), // Couleur de fond du ListTile
        title: Row(
          children: [
            Icon(
              iconData,
              size: 20,
              color: Colors.black, // Couleur de l'icône
            ),
            SizedBox(width: 10), // Espacement entre l'icône et le texte
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black, // Couleur du texte
              ),
            ),
            SizedBox(width: 10), // Espacement avant le champ de texte
            Expanded(
              child: TextFormField(
                controller: controller,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                enabled: false,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit),
          onPressed: onPressed,
          color: Colors.black, // Couleur de l'icône de modification
        ),
      ),
    );
  }

  Widget _buildInfoContainer(
    String label,
    String value,
    IconData iconData,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 5.0, horizontal: 5), // Ajout du padding horizontal
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Forme du Card
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Forme du ListTile
          ),
          tileColor: const Color(0xfffcce00), // Couleur de fond du ListTile
          title: Row(
            children: [
              Icon(
                iconData,
                size: 20,
                color: Colors.black, // Couleur de l'icône
              ),
              SizedBox(width: 10), // Espacement entre l'icône et le texte
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,

                  color: Colors.black, // Couleur du texte
                ),
              ),
              SizedBox(width: 10), // Espacement avant la valeur
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    String fieldName,
    TextEditingController controller,
    String key_first_name,
  ) async {
    String newValue = controller.text;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier $fieldName'),
          content: TextFormField(
            onChanged: (value) {
              newValue = value;
            },
            controller: controller,
            decoration: InputDecoration(hintText: 'Nouvelle valeur'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                controller.text = newValue;
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilTransporteur(),
  ));
}
