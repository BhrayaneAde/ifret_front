import 'package:dio/dio.dart' as Dio;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iltfret/composant/Chargeurs/accueilChargeur.dart';
import 'package:iltfret/composant/Transporteurs/accueilTransporteur.dart';

import 'package:iltfret/api/dio.dart';
import 'package:iltfret/develop/Login.dart';
import 'package:pinput/pinput.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../composant/Chauffeurs/accueilChauffeur.dart';

class Otp extends StatefulWidget {
  Map? data;
  Otp(
      {Key? key,
      required String phoneNumber,
      required Object verificationId,
      this.data})
      : super(key: key);

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String code = "";
  TextEditingController countryController = TextEditingController();
  var phone = "";

  bool isCodeValid = false; // Variable pour vérifier si le code est valide

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
                              isCodeValid = value.length ==
                                  6; // Vérifier si le code est complet
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
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: Login.verify, smsCode: code);
      await auth.signInWithCredential(credential);

      // Redirection vers la page souhaitée après la vérification réussie du code OTP
      Fluttertoast.showToast(
        msg: "Verification Réussie",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        timeInSecForIosWeb: 5,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Transporteurs(
            name: '',
            profileUrl: '',
            username: '',
          ),
        ),
      );
    } catch (e) {
      // Gestion des erreurs
      print("Erreur de Code de Vérification: $e");
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
}
