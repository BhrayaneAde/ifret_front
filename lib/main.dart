import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ifret/composant/Chargeurs/accueilChargeur.dart';
import 'package:ifret/composant/Chauffeurs/accueilChauffeur.dart';
import 'package:ifret/composant/Transporteurs/accueilTransporteur.dart';
import 'package:ifret/develop/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ifret/develop/phone.dart';
import 'package:ifret/develop/splash/splash_screen.dart';
import 'package:ifret/firebase_options.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
    print('initialise_Successfully');
  });

  // Configuration des notifications locales
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

// Récupérer le jeton et le type de compte depuis les préférences partagées
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? role = prefs.getString('type_compte');

  print('Token: $token'); // Vérifiez si le jeton est correctement récupéré
  print('Role: $role'); // Vérifiez si le rôle est correctement récupéré

  // Déterminer la route initiale en fonction de la présence du jeton et du type de compte
  String initialRoute = token != null && role != null ? '/home' : '/login';

  runApp(MyApp(initialRoute: initialRoute, role: role));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final String? role;

  const MyApp({required this.initialRoute, required this.role, Key? key})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I-FRET',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/notifications': (context) => NotificationPage(),
        '/splash': (context) => const SplashScreen(),
        '/phone': (context) => const MyPhone(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) {
          // Redirigez l'utilisateur vers la page appropriée en fonction de son type
          switch (role) {
            case "Transporteur":
              return Transporteurs(
                name: '',
                profileUrl: '',
                username: '',
              );
            case "Chauffeur":
              return Chauffeur(
                name: '',
                ParametreeUrl: '',
                username: '',
              );
            case "Chargeur":
              return Chargeur(
                name: '',
                profileUrl: '',
                username: '',
              );
            // Ajoutez d'autres cas pour d'autres types d'utilisateurs si nécessaire
            default:
              // Redirigez vers la page par défaut si le type d'utilisateur n'est pas reconnu
              return const LoginScreen();
          }
        },
      },
      builder: EasyLoading.init(),
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