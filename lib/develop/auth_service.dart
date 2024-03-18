import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:iltfret/api/dio.dart';
import 'package:iltfret/composant/Chargeurs/accueilChargeur.dart';
import 'package:iltfret/composant/Chauffeurs/accueilChauffeur.dart';
import 'package:iltfret/composant/Transporteurs/accueilTransporteur.dart';

import 'package:iltfret/develop/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode pour envoyer le code de vérification pour l'enregistrement
  Future<void> sendVerificationCodeForRegistration(
      String selectedCountry, String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '$selectedCountry$phoneNumber',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          Login.verify = verificationId;
          Login.resendToken = resendToken.toString();
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        // Ignorer la vérification de l'application
        forceResendingToken: 0,
      );
    } catch (e) {
      print("Erreur : $e");
    }
  }

  // Méthode pour envoyer le code de vérification pour la connexion
  Future<void> sendVerificationCodeForLogin(
      String selectedCountry, String phone) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '$selectedCountry$phone',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          print("Erreur de vérification : ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          Login.verify = verificationId;
          Login.resendToken = resendToken.toString();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print(
              "Timeout de récupération automatique du code : $verificationId");
        },
        // Ignorer la vérification de l'application
        forceResendingToken: 0,
      );
    } catch (e) {
      print("Erreur : $e");
    }
  }

  // Méthode pour renvoyer le code de vérification pour la connexion
  Future<void> resendVerificationCodeForLogin(
      String selectedCountry, String phone) async {
    try {
      if (Login.resendToken != null) {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '$selectedCountry$phone',
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {},
          codeSent: (String verificationId, int? resendToken) {
            Login.verify = verificationId;
            Login.resendToken = resendToken.toString();
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          // Ignorer la vérification de l'application
          forceResendingToken: int.parse(Login.resendToken!),
        );
      }
    } catch (e) {
      print("Erreur : $e");
    }
  }

}
