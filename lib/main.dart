import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ifret/composant/Transporteurs/accueilTransporteur.dart';
import 'package:ifret/develop/login.dart';
import 'package:ifret/develop/phone.dart';

import 'package:ifret/develop/splash/splash_screen.dart';
import 'package:ifret/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
    print('initialise_Successfully');
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I-FRET',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/phone': (context) => const MyPhone(),
        '/login': (context) => Login(),
        '/transporteur': (context) => Transporteurs(
              name: '',
              profileUrl: '',
              username: '',
            ),
      },
    );
  }
}
/* 
class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
} */
/* 
class _loginPageState extends State<loginPage> {
  String verifyId = '';
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                print('coucou');
                FirebaseAuth _auth = FirebaseAuth.instance;
                await _auth.verifyPhoneNumber(
                    phoneNumber: "+22990205486",
                    timeout: Duration(seconds: 60),
                    verificationCompleted: (credential) {
                      print("Verify successfuly");
                    },
                    verificationFailed: (FirebaseAuthException e) {
                      print('field Code ${e.code} ${e.message}');
                    },
                    codeSent: (verificationId, resendToken) {
                      print('VerificationID ${verificationId}');
                      setState(() {
                        verifyId = verificationId;
                      });
                    },
                    codeAutoRetrievalTimeout: (codeAutoRetrievalTimeout) {
                      return;
                    });
              },
              child: Text("Verifier")),
          ElevatedButton(
              onPressed: () {
                signWithCode('123456');
              },
              child: Text('Se connecter'))
        ],
      ),
    );
  }

  Future signWithCode(String code) async {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final cred =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: code);
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(cred);
      if (userCredential.user != null) {
        print(
            "User login in ${userCredential.user!.displayName} ${userCredential.user!.phoneNumber}");
      } else {
        print("Invalid code");
      }
    } on FirebaseAuthException catch (e) {
      print("error ${e.code} ${e.message}");
    }
  }
}
 */