import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Chargeurs/accueilChargeur.dart';
import 'package:ifret/composant/Chauffeurs/accueilChauffeur.dart';
import 'package:ifret/composant/Transporteurs/accueilTransporteur.dart';
import 'package:ifret/loading.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<FormState> formKey = GlobalKey<FormState>();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late StreamSubscription<bool> keyboardSubscription;

  late PageController _pageController;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  String selectedCountry = '+229';
  bool isKeyboardVisible = false;
  String phone = "";
  String completePhoneNumber = "";
  String _verificationId = "";
  bool _loading = false;
  bool isCodeValid = false;
  bool isValidPhone = false;
  bool isInsertingNumber = false;

  final List<String> countries = [
    '+229',
    '+228',
    '+221',
    '+234',
    '+223',
    '+226',
    '+227'
  ];

  String _selectedType = '';
  final List<String> _types = ['', 'Transporteur', 'Chauffeur', 'Chargeur'];

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialisation de _pageController
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Création de compte'),
        centerTitle: true,
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController, // Ajout du contrôleur de page
        children: [
          buildFirstPage(),
          buildSecondPage(),
        ],
      ),
      bottomNavigationBar: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context)
                .size
                .width), // Limite la largeur maximale du conteneur
        color: const Color(0xFF222222), // Couleur du fond du pied de page
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(FontAwesomeIcons.facebook,
                      color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(FontAwesomeIcons.twitter,
                      color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const FaIcon(FontAwesomeIcons.instagram,
                      color: Colors.white),
                ),
              ],
            ),
            const Expanded(
              child: Text(
                'Suivez-nous sur les réseaux sociaux',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFirstPage() {
    return Container(
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
                  buildTextField(_nomController, 'Nom', (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est obligatoire';
                    }
                    return null;
                  }),
                  const SizedBox(height: 10.0),
                  buildDivider(),
                  const SizedBox(height: 10.0),
                  buildTextField(_prenomController, 'Prénom', (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le prénom est obligatoire';
                    }
                    return null;
                  }),
                  const SizedBox(height: 10.0),
                  buildDivider(),
                  buildDateField(),
                  const SizedBox(height: 10.0),
                  buildDivider(),
                  const SizedBox(height: 10.0),
                  buildTextField(_villeController, 'Ville de résidence',
                      (value) {
                    if (value == null || value.isEmpty) {
                      return 'La ville de résidence est obligatoire';
                    }
                    return null;
                  }),
                  const SizedBox(height: 10.0),
                  buildDivider(),
                  const SizedBox(height: 10.0),
                  buildDropdownField(),
                  const SizedBox(height: 10.0),
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
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        // Vérifier d'abord si le numéro de téléphone est valide
                        String phoneNumber = _telephoneController.text;
                        if (phoneNumber.isEmpty) {
                          // Afficher un message d'erreur ou une notification indiquant que le numéro de téléphone est vide
                          return;
                        }

                        completePhoneNumber = selectedCountry + phoneNumber;
                        /*  Map<String, dynamic> data = {
                          'nom': _nomController.text,
                          'prenom': _prenomController.text,
                          'ville': _villeController.text,
                          'date_naissance': _dateNaissanceController.text,
                          'numero_tel': completePhoneNumber,
                          'type_compte': _selectedType
                        }; */
                        formKey.currentState?.save();
                        verifyPhone(completePhoneNumber);
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor: WidgetStateProperty.all<Color>(
                          const Color(0xFFFCCE00)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                    child: const Text('Créer le compte'),
                  ),
                  /*  ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> data = {
                          'nom': "_nomController.text",
                          'prenom': " _prenomController.text",
                          'ville': "_villeController.text",
                          'date_naissance': "_dateNaissanceController.text",
                          'numero_tel': "completePhoneNumber",
                          'type_compte': " _selectedType"
                        };

                        print(data);

                        final response = await ApiRequest.register(data);
                        print(response?.data.toString());

                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('token', response?.data['token']);
                      },
                      child: Text("test")), */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSecondPage() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 18,
            ),
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/2.png',
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            const Text(
              "VERIFICATION DU NUMERO DE TELEPHONE",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Veuillez entrer le code envoyé au \nnuméro $selectedCountry${maskNumber(_telephoneController.text)}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 114, 114, 114),
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Pinput(
                    controller: _codeController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    length: 6,
                    showCursor: true,
                    onChanged: (value) {
                      setState(() {
                        isCodeValid = value.length == 6;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _signInWithPhoneCredential(_verificationId);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color(0xFFFCCE00)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Verifier Numéro de Téléphone",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                  ),

                  //test

                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          _pageController.previousPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeIn);
                        },
                        child: const Text(
                          "Modifier le Numéro",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 18,
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
        hintStyle: const TextStyle(color: Colors.white),
        labelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
        border: InputBorder.none,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFCCE00)),
        ),
        contentPadding: const EdgeInsets.all(10.0),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.white),
      validator: validator,
    );
  }

  Widget buildDropdownField() {
    return DropdownButtonFormField(
      value: _selectedType,
      style: const TextStyle(fontSize: 12),
      items: _types.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            type,
            style: TextStyle(
              color: _selectedType == type ? Colors.white : Colors.black,
            ),
          ),
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
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  )
                : const Text(
                    'Sélectionner une date',
                    style: TextStyle(color: Colors.white),
                  ),
            const Icon(
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
    return const Divider(
      color: Colors.white,
      height: 1.0,
    );
  }

  verifyPhone(String phone) async {
    ShowToastDialog.showLoader("Envoi en cours...");
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {
        print(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ShowToastDialog.closeLoader();
        if (e.code == 'invalid-phone-number') {
          ShowToastDialog.showToast(
              "Le numéro renseigné n'est un numéro valide");
        } else {
          ShowToastDialog.showToast(
              "Une erreur s'est produite lors de la vérification du numéro");
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Code de vérification envoyé avec succès ");
        setState(() {
          _verificationId = verificationId;
        });
        _pageController.nextPage(
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        ShowToastDialog.showToast("Temps de vérification terminer");
      },
    );
  }

  Future<void> _signInWithPhoneCredential(String verificationId) async {
    print(verificationId);
    print(_codeController.text);

    try {
      setState(() {
        _loading = true;
      });

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: _codeController.text);

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        _loading = false;
      });

      if (userCredential.user != null) {
        ShowToastDialog.showToast("Utilisateur connecté avec succès");

        Map<String, dynamic> data = {
          'nom': _nomController.text,
          'prenom': _prenomController.text,
          'ville': _villeController.text,
          'date_naissance': _dateNaissanceController.text,
          'numero_tel': completePhoneNumber,
          'type_compte': _selectedType
        };

        print(data);

        // Envoyer les données à l'API pour l'enregistrement de l'utilisateur
        final response = await ApiRequest.register(data);
        print(response?.toString());

        // Vérifier si la réponse de l'API contient le token et le rôle de l'utilisateur
        if (response != null &&
            response.containsKey('token') &&
            response.containsKey('role')) {
          // Récupérer le token et le rôle de l'utilisateur depuis la réponse de l'API
          String token = response['token'];
          String role = response['role'];

          // Enregistrer le token dans les préférences partagées
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('type_compte', role);

          // Naviguer vers la page correspondant au rôle de l'utilisateur
          switch (role) {
            case "Transporteur":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Transporteurs(
                    name: '',
                    profileUrl: '',
                    username: '',
                  ),
                ),
              );
              break;
            case "Chargeur":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Chargeur(
                    name: '',
                    profileUrl: '',
                    username: '',
                  ),
                ),
              );
              break;
            case "Chauffeur":
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Chauffeur(
                    name: '',
                    ParametreeUrl: '',
                    username: '',
                  ),
                ),
              );
              break;
            default:
          }
        } else {
          // Gérer le cas où la réponse de l'API ne contient pas le token ou le rôle
          print("Token ou rôle manquant dans la réponse de l'API");
        }
      } else {
        print("Invalid code");
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
      });
      print(e);
      if (e.code == "invalid-verification-code") {
        // Le code saisi est invalide
        ShowToastDialog.showToast("Le code renseigné est invalide");
      } else if (e.code == "session-expired") {
        // Le code a expiré, demandez un nouveau code
        ShowToastDialog.showToast(
            "Le code est déja expiré veuillez faire un renvoie de code");
      } else {
        // Une erreur s'est produite pendant l'authentification
        ShowToastDialog.showToast("Une erreur s'est produite lors de l'Auth");
        print(e.code);
        print(verificationId);
        return;
      }
    }
  }

  String maskNumber(String phone) {
    String masque = '';
    if (phone.length > 4) {
      final int longueurMasque = phone.length - 4;

      for (int i = 0; i < longueurMasque; i++) {
        masque += '*';
      }
      masque += phone.substring(longueurMasque);
    }

    return masque;
  }
}

void main() {
  runApp(const MaterialApp(
    home: RegisterScreen(),
  ));
}
