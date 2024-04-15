import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ifret/develop/auth/register_screen.dart';
import 'package:pinput/pinput.dart';

import '../../loading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late StreamSubscription<bool> keyboardSubscription;

  final PageController _pageController = PageController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final phoneFormKey = GlobalKey<FormState>();
  String selectedCountry = '+229';

  int currentIndex = 0;
  bool isKeyboardVisible = false;

  String _verificationId = "";
  bool _loading = false;
  bool isCodeValid = false;
  bool isValidPhone = false;
  List<String> countries = [
    '+229',
    '+228',
    '+221',
    '+234',
    '+223',
    '+226',
    '+227'
  ];

  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    // Subscribe
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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          children: [
            /// verify phoneNumber
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/aaaa.png'),
                  fit: BoxFit.cover,
                ),
                color: Colors.black.withOpacity(1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Center(
                      child: Form(
                        key: phoneFormKey,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 24, horizontal: 32),
                            child: Column(
                              children: [
                                Transform.scale(
                                  scale: 1.5,
                                  child: Image.asset(
                                    'assets/images/ifret.png',
                                    height: 200,
                                    width: 200,
                                  ),
                                ),
                                const Text(
                                  "VERIFICATION OTP",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFCCE00),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    DropdownButton<String>(
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
                                              color: Color(0xFFFCCE00),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        onChanged: (value) {},
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Numéro de Téléphone",
                                          hintStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Veuillez entrer un numéro de téléphone';
                                          }
                                          return null;
                                        },
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (phoneFormKey.currentState!
                                          .validate()) {
                                        String phone =
                                            '$selectedCountry${_phoneController.text}';
                                        verifyPhone(phone);
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        const Color(0xFFFCCE00),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                        ),
                                      ),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        'Se Connecter',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Vous n'avez pas un compte?",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Inscrivez-vous",
                                          style: TextStyle(
                                              color: Colors.yellow,
                                              fontSize: 12),
                                        ))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !isKeyboardVisible,
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
                  )
                ],
              ),
            ),

            /// send Code
            Padding(
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
                      "Veuillez entrer le code envoyé au \nnuméro $selectedCountry${maskNumber(_phoneController.text)}",
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
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color(0xFFFCCE00)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
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
                          Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeIn);
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
            )
          ],
        ),
      ),
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
    try {
      setState(() {
        _loading = true;
      });
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: _codeController.text);

      // Sign the user in (or link) with the credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        _loading = false;
      });

      if (userCredential.user != null) {
        ShowToastDialog.showToast("Utilisateur connecté avec succès");
        _pageController.nextPage(
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
      });
      print(e);
      if (e.code == "invalid-verification-code") {
        ShowToastDialog.showToast("Le code renseigné est invalide");
      } else if (e.code == "session-expired") {
        ShowToastDialog.showToast(
            "Le code est déja expiré veuillez faire un renvoie de code");
      } else {
        ShowToastDialog.showToast("Une erreur s'est produite");
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
