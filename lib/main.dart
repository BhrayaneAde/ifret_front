/* import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iltfret/develop/login.dart';
import 'package:iltfret/develop/phone.dart';
import 'package:iltfret/develop/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDDj3FlUivtF15rRGLZwVmCHpmrsVFAHZY",
      projectId: "iltfret-3313a",
      storageBucket: "iltfret-3313a.appspot.com",
      messagingSenderId: "161567952250",
      appId: "1:161567952250:android:2d7585a605e6c05f6f1ac3",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IFRet',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        'phone': (context) => const MyPhone(),
        '/login': (context) => Login(),
      },
    );
  }
} */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iltfret/develop/login.dart';
import 'package:iltfret/develop/phone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iltfret/develop/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDDj3FlUivtF15rRGLZwVmCHpmrsVFAHZY",
      projectId: "iltfret-3313a",
      messagingSenderId: "161567952250",
      appId: "1:161567952250:android:2d7585a605e6c05f6f1ac3",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/phone': (context) => const MyPhone(),
        '/login': (context) => Login(),
      },
    );
  }
}
