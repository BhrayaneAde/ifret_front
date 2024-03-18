import 'package:flutter/material.dart';
import 'package:iltfret/api/api_request.dart';
import 'package:iltfret/develop/auth_service.dart';
import 'package:iltfret/develop/otp2.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final GlobalKey<FormState> formKey = GlobalKey<FormState>();

class Register extends StatefulWidget {
  Register({Key? key}) : super(key: key);
  static String verify = "";
  static String? resendToken;

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Controllers pour les champs de texte
  TextEditingController _nomController = TextEditingController();
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _dateNaissanceController = TextEditingController();
  TextEditingController _villeController = TextEditingController();
  TextEditingController _telephoneController = TextEditingController();

  late AuthService _authService;

  String selectedCountry = '+229'; // Pays par défaut
  var phone = "";
  bool isInsertingNumber = false;

  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    _authService = AuthService();
    _telephoneController.text = "";
    super.initState();
  }

  List<String> countries = [
    '+229',
    '+228',
    '+221',
    '+234',
    '+223',
    '+226',
    '+227'
  ];

  // Valeur et liste pour le champ de sélection
  String _selectedType = '';
  List<String> _types = ['', 'Transporteur', 'Chauffeur', 'Chargeur'];

  // DateTime pour le champ de date
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Création de compte'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/background0.png'),
            fit: BoxFit.cover,
          ),
          color: Colors.black.withOpacity(1),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Champ de texte pour le nom
                    buildTextField(_nomController, 'Nom', (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est obligatoire';
                      }
                      return null;
                    }),
                    SizedBox(height: 10.0),
                    buildDivider(),
                    SizedBox(height: 10.0),
                    // Champ de texte pour le prénom
                    buildTextField(_prenomController, 'Prénom', (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le prénom est obligatoire';
                      }
                      return null;
                    }),
                    SizedBox(height: 10.0),
                    buildDivider(),
                    // Champ de date
                    buildDateField(),
                    SizedBox(height: 10.0),
                    buildDivider(),
                    SizedBox(height: 10.0),
                    // Champ de texte pour la ville
                    buildTextField(_villeController, 'Ville de résidence',
                        (value) {
                      if (value == null || value.isEmpty) {
                        return 'La ville de résidence est obligatoire';
                      }
                      return null;
                    }),
                    SizedBox(height: 10.0),
                    buildDivider(),
                    SizedBox(height: 10.0),
                    // Champ de sélection (dropdown)
                    buildDropdownField(),
                    SizedBox(height: 10.0),
                    buildDivider(),
                    Row(
                      children: [
                        Container(
                            child: DropdownButton<String>(
                          value: selectedCountry,
                          onChanged: (String? value) {
                            setState(() {
                              selectedCountry = value!;
                            });
                          },
                          items: countries.map((String country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Text(
                                country,
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        )),
                        Expanded(
                          child: buildTextField(
                            _telephoneController,
                            'Numéro de téléphone',
                            (value) {
                              if (value == null || value.isEmpty) {
                                return 'Le numéro de téléphone est obligatoire';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.phone,
                            hintText: 'Numéro de Téléphone',
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    // Bouton pour la soumission du formulaire
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          Map<String, dynamic> data = {
                            'nom': _nomController.text,
                            'prenom': _prenomController.text,
                            'ville': _villeController.text,
                            'date_naissance': _dateNaissanceController.text,
                            'numero_tel':
                                selectedCountry + _telephoneController.text,
                            'type_compte': _selectedType
                          };
                          formKey.currentState?.save();
                          await AuthService()
                              .sendVerificationCodeForRegistration(
                            selectedCountry,
                            _telephoneController.text,
                          );
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Otp2(
                                phoneNumber: _telephoneController.text,
                                verificationId: '',
                                verificationCode: '',
                                data: data,
                              ),
                            ),
                          );

                          print(data);
                        }
                      },
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xFFFCCE00)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      child: const Text('Créer le compte'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context)
                .size
                .width), // Limite la largeur maximale du conteneur
        color: Color(0xFF222222), // Couleur du fond du pied de page
        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
                ),
              ],
            ),
            // Informations à droite enveloppées dans un Expanded
            Expanded(
              child: Text(
                'Suivez-nous sur les réseaux sociaux',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12, // Taille de la police réduite à 12 points
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String labelText,
    String? Function(String?)? validator, {
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (value) {
        setState(() {
          isInsertingNumber = value.isNotEmpty;
          phone = value;
        });
      },
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white),
        labelStyle: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFCCE00)),
        ),
        contentPadding: EdgeInsets.all(10.0),
      ),
      style: TextStyle(fontSize: 16, color: Colors.white),
      validator: validator,
    );
  }

  Widget buildDropdownField() {
    return DropdownButtonFormField(
      value: _selectedType,
      style: TextStyle(fontSize: 12),
      items: _types.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value.toString();
        });
      },
      decoration: const InputDecoration(
        labelText: 'Type de compte',
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w300, color: Colors.white),
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFCCE00)),
        ),
        contentPadding: EdgeInsets.all(12.0),
      ),
    );
  }

  Widget buildDateField() {
    return InkWell(
      onTap: () {
        _selectDate(context);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date de Naissance',
          hintStyle: TextStyle(color: Colors.white),
          labelStyle: TextStyle(color: Colors.white),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFCCE00)),
          ),
          contentPadding: EdgeInsets.all(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _selectedDate != null
                ? Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  )
                : Text(
                    'Sélectionner une date',
                    style: TextStyle(color: Colors.white),
                  ),
            Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateNaissanceController.text =
            DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Widget buildDivider() {
    return Divider(
      color: Colors.white,
      height: 1.0,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Register(),
  ));
}
