import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ifret/develop/login.dart';
import 'package:ifret/develop/register.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verifyId = "";

  // Méthode pour envoyer le code de vérification pour l'enregistrement
  Future<void> sendVerificationCodeForRegistration(
      String selectedCountry, String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '$selectedCountry$phoneNumber',
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          Register.verify = verificationId;
          Register.resendToken = resendToken.toString();
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
        verificationCompleted: (credential) {
          print("Verification Effectuée avec succès");
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Erreur de Vérification ${e.code} ${e.message}');
        },
        codeSent: (verificationId, resendToken) {
          print('Code OTP envoyé avec succès');
          print('VerificationID ${verificationId}');
          verifyId = verificationId;
        },
        codeAutoRetrievalTimeout: (codeAutoRetrievalTimeout) {
          return;
        },
      );
    } catch (e) {
      print("Erreur lors de l'envoi du code OTP : $e");
    }
  }

  // Méthode pour renvoyer le code de vérification pour la connexion
  /*  Future<void> resendVerificationCodeForLogin(
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
  }  */ /*  */
  Future<bool> signWithCode(String code) async {
    bool isConnected = false;
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final cred =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: code);

    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(cred);
      if (userCredential.user != null) {
        print(
            "User login in ${userCredential.user!.displayName} ${userCredential.user!.phoneNumber}");
        isConnected = true;
      }
    } on FirebaseAuthException catch (e) {
      print("error ${e.code} ${e.message}");
    }
    return isConnected;
  }
}
