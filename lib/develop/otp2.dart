import 'package:dio/dio.dart' as Dio;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/api/dio.dart';
import 'package:ifret/composant/Chargeurs/accueilChargeur.dart';
import 'package:ifret/composant/Chauffeurs/accueilChauffeur.dart';
import 'package:ifret/composant/Transporteurs/accueilTransporteur.dart';
import 'package:ifret/develop/login.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Otp2 extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String
      verificationCode; // Nouveau paramètre pour le code de vérification
  Map? data;
  Otp2({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    required this.verificationCode, // Ajout du nouveau paramètre
    this.data,
  }) : super(key: key);

  @override
  _Otp2State createState() => _Otp2State();
}

class _Otp2State extends State<Otp2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String code = "";
  TextEditingController countryController = TextEditingController();
  var phone = "";

  bool isCodeValid = false;

  @override
  void initState() {
    countryController.text = "+229";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(),
        alignment: Alignment.center,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 18,
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/2.png',
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  const Text(
                    "VERIFICATION DU NUMERO DE TELEPHONE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Veuillez entrer le code envoyé au numéro ** ** ** ** ",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 114, 114, 114),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    padding: EdgeInsets.all(28),
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
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          length: 6,
                          showCursor: true,
                          onChanged: (value) {
                            setState(() {
                              code = value;
                              isCodeValid = value.length == 6;
                            });
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                // Appel de la fonction submitVerificationCode
                                await submitVerificationCode();
                              } catch (e) {
                                print(
                                    "Erreur lors de la vérification du code OTP : $e");
                                Fluttertoast.showToast(
                                  msg:
                                      'Erreur lors de la vérification du code OTP',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
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
                            child: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                "Verifier Numéro de Téléphone",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  ),
                                );
                              },
                              child: Text(
                                "Modifier le Numéro",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submitVerificationCode() async {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    final cred = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: code);
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(cred);
      if (userCredential.user != null) {
        print(
            "User login in ${userCredential.user!.displayName} ${userCredential.user!.phoneNumber}");
        // Redirection vers la page souhaitée après la vérification réussie du code OTP
        Fluttertoast.showToast(
          msg: "Verification Réussie",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          timeInSecForIosWeb: 5,
        );

        final response = await ApiRequest.register(widget.data);
        print(response?.toString());

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response?['token']);

        switch (response?["role"]) {
          case "Transporteur":
            () => {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Transporteurs(
                        name: '',
                        profileUrl: '',
                        username: '',
                      ),
                    ),
                  )
                };
            break;
          case "Chargeur":
            () => {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chargeur(
                        name: '',
                        profileUrl: '',
                        username: '',
                      ),
                    ),
                  )
                };
            break;
          case "Chauffeur":
            () => {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chauffeur(
                        name: '',
                        ParametreeUrl: '',
                        username: '',
                      ),
                    ),
                  )
                };
          default:
        }
      } else {
        print("Invalid code");
      }
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs
      print("Erreur ${e.code} ${e.message}");
      // Afficher un message d'erreur à l'utilisateur
      Fluttertoast.showToast(
        msg: "Erreur de Vérification. Veuillez Reprendre le processus",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        timeInSecForIosWeb: 5,
      );

      // Affichage de la boîte de dialogue avec un message d'erreur
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Erreur de Vérification"),
            content: const Text(
                "Une erreur s'est produite lors de la vérification du code. Veuillez réessayer."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  /*  Future<void> checkIfNumberExists() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: Login.verify, smsCode: code);
      await _auth.signInWithCredential(credential);

      // Assurez-vous d'envoyer le numéro de téléphone correctement
      String phoneNumber = widget.data?['numero_tel'];

      Dio.Options options =
          Dio.Options(contentType: Dio.Headers.jsonContentType);
      Dio.Response response = await dio().post('/login',
          data: {
            'numero_tel': phoneNumber
          }, // Ajoutez le numéro de téléphone à la requête
          options: options);

      print('Code de Statut de la Réponse : ${response.statusCode}');
      print('Corps de la Réponse : ${response.data}');

      if (response.statusCode == 201) {
        if (response.data != null &&
            response.data is Map<String, dynamic> &&
            response.data.containsKey('token') &&
            response.data.containsKey('type_compte')) {
          // store token and type_compte
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final response = await ApiRequest.login(widget.data);
          print(response?.data.toString());
          await prefs.setString('token', response?.data['token']);

          await prefs.setString('type_compte', response?.data['type']);

          // Redirect to the appropriate page based on type_compte

          switch (response?.data["role"]) {
            case "Transporteur":
              () => {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Transporteurs(
                          name: '',
                          profileUrl: '',
                          username: '',
                        ),
                      ),
                    )
                  };
              break;
            case "Chargeur":
              () => {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chargeur(
                          name: '',
                          profileUrl: '',
                          username: '',
                        ),
                      ),
                    )
                  };
              break;
            case "Chauffeur":
              () => {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chauffeur(
                          name: '',
                          profileUrl: '',
                          username: '',
                        ),
                      ),
                    )
                  };
              break;
            default:
          }
        } else {
          print(
              "La propriété 'token' ou 'type_compte' est manquante dans la réponse du serveur.");
        }
      } else {
        print("Une erreur s'est produite lors de la connexion");
      }
    } catch (e) {
      print("Erreur de Code de Vérification: $e");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Erreur de Vérification"),
            content: const Text(
                "Une erreur s'est produite lors de la vérification du code. Veuillez réessayer."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
 */
}
