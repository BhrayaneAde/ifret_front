import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ifret/develop/auth_service.dart';
import 'package:ifret/develop/otp2.dart'; // Importez la page OTP2
import 'package:ifret/develop/otp_login.dart';
import 'package:ifret/develop/register.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController phoneController = TextEditingController();
  String selectedCountry = '+229';
  var phone = "";
  String verifyId = "";

  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    phoneController.text = "";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/aaaa.png'),
            fit: BoxFit.cover,
          ),
          color: Colors.black.withOpacity(1),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 18,
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Transform.scale(
                      scale: 1.5,
                      child: Image.asset(
                        'assets/images/ifret.png',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
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
                    height: 28,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Form(
                          key: phoneFormKey,
                          child: Column(
                            children: [
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
                                      controller: phoneController,
                                      keyboardType: TextInputType.phone,
                                      onChanged: (value) {
                                        setState(() {
                                          phone = value;
                                        });
                                      },
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
                                height: 22,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      if (phoneFormKey.currentState
                                              ?.validate() ??
                                          false) {
                                        // Envoi du code de vérification et navigation vers la page OTP2
                                        await AuthService()
                                            .sendVerificationCodeForLogin(
                                          selectedCountry,
                                          phone,
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Otp_login(
                                              phoneNumber:
                                                  '$selectedCountry$phone',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      print(
                                          "Erreur lors de l'envoi du code de vérification : $e");
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
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Register(),
                                  ),
                                );
                              },
                              child: const Center(
                                child: Text(
                                  "Vous n'avez pas de Compte ? Inscrivez-vous",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
        ),
        color: const Color(0xFF222222),
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
            Expanded(
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
}
