import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Chargeurs/accueilChargeur.dart';
import 'package:ifret/composant/Chauffeurs/accueilChauffeur.dart';
import 'package:ifret/composant/Transporteurs/accueilTransporteur.dart';
import 'package:ifret/develop/auth_service.dart';
import 'package:ifret/develop/login.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Otp_login extends StatefulWidget {
  final String phoneNumber;

  Map? data;
  Otp_login({
    super.key,
    required this.phoneNumber,
    this.data,
  });

  @override
  _Otp_loginState createState() => _Otp_loginState();
}

class _Otp_loginState extends State<Otp_login> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController countryController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  var phone = "";

  bool isCodeValid = false;

  @override
  void initState() {
    countryController.text = "+229";
    super.initState();
  }

  @override
  void dispose() {
    countryController.dispose();
    _codeController.dispose();
    super.dispose();
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Veuillez entrer le code envoyé au numéro ** ** ** ** ",
                    style: TextStyle(
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
                            onPressed: () async {
                              try {
                                // Appel de la fonction submitVerificationCodeLogin
                                await submitVerificationCodeLogin();
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
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color(0xFFFCCE00)),
                              shape: WidgetStateProperty.all<
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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
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
                                    builder: (context) => const Login(),
                                  ),
                                );
                              },
                              child: const Text(
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
                  const SizedBox(
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

  Future<void> submitVerificationCodeLogin() async {
    print(_codeController.text);
    try {
      bool isConnected = await AuthService().signWithCode(_codeController.text);
      if (isConnected) {
        print("User login");
        // Redirection vers la page souhaitée après la vérification réussie du code OTP
        Fluttertoast.showToast(
          msg: "Verification Réussie",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          timeInSecForIosWeb: 5,
        );

        final response = await ApiRequest.register(widget);
        print(response?.toString());

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response?['token']);

        switch (response?["role"]) {
          case "Transporteur":
            () => {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Transporteurs(
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
                      builder: (context) => const Chargeur(
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
                      builder: (context) => const Chauffeur(
                        name: '',
                        ParametreeUrl: '',
                        username: '',
                      ),
                    ),
                  )
                };
            break;
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
      await auth.signInWithCredential(credential);

      // Assurez-vous d'envoyer le numéro de téléphone correctement
      String phoneNumber = widget?['numero_tel'];

      Dio.Options options =
          Dio.Options(contentType: Dio.Headers.jsonContentType);
      Dio.Response response = await dio().post('/login',
          data: {
            'numero_tel': phoneNumber
          }, // Ajoutez le numéro de téléphone à la requête
          options: options);

      print('Code de Statut de la Réponse : ${response.statusCode}');
      print('Corps de la Réponse : ${response}');

      if (response.statusCode == 201) {
        if (response != null &&
            response is Map<String, dynamic> &&
            response.containsKey('token') &&
            response.containsKey('type_compte')) {
          // store token and type_compte
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final response = await ApiRequest.login(widget);
          print(response?.toString());
          await prefs.setString('token', response?['token']);

          await prefs.setString('type_compte', response?['type']);

          // Redirect to the appropriate page based on type_compte

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
