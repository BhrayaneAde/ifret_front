import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';
import 'success_screen.dart';

// Votre clé API publique ici
const String publicApiKey = "be4ad9b0652011efbf02478c5adba4b8";

class PaiementPage extends StatelessWidget {
  final String transactionId;
  final int montant;
  final int fretId; // Ajoutez le fretId ici en tant que variable de classe

  const PaiementPage({
    super.key,
    required this.transactionId,
    required this.montant,
    required this.fretId, // Passez le fretId en paramètre
  });

  // Le callback n'a plus besoin de recevoir le fretId en paramètre, il l'utilise directement depuis la classe
  void callback(Map<String, dynamic> response, BuildContext context) async {
    print('Callback triggered');
    print('Response: ${response.toString()}'); // Imprime la réponse complète

    final String kkiapayTransactionId =
        response['transactionId']?.toString() ?? '';
    final int montantPaye =
        int.tryParse(response['requestData']['amount']?.toString() ?? '') ?? 0;

    switch (response['status']) {
      case PAYMENT_CANCELLED:
        debugPrint(PAYMENT_CANCELLED);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(PAYMENT_CANCELLED)),
        );
        break;

      case PENDING_PAYMENT:
        debugPrint(PENDING_PAYMENT);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(PENDING_PAYMENT)),
        );
        break;

      case PAYMENT_INIT:
        debugPrint(PAYMENT_INIT);
        break;

      case PAYMENT_SUCCESS:
        print('Payment successful');
        debugPrint(PAYMENT_SUCCESS);

        print('Kkiapay Transaction ID: $kkiapayTransactionId');
        print('Montant Payé: $montantPaye');

        // Enregistrement de la transaction dans la base de données
        try {
          // Utilisation du fretId directement depuis la classe
          await ApiRequest.updateFretTransactionId(
              fretId, kkiapayTransactionId); // fretId est accessible ici
        } catch (e) {
          print('Erreur lors de la mise à jour de la transaction: $e');
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(PAYMENT_SUCCESS)),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              montantPaye: montantPaye,
              transactionId: kkiapayTransactionId,
            ),
          ),
        );
        break;

      case PAYMENT_FAILED:
        debugPrint(PAYMENT_FAILED);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(PAYMENT_FAILED)),
        );
        break;

      default:
        debugPrint(UNKNOWN_EVENT);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kkiapay = KKiaPay(
      amount: montant,
      countries: const ["BJ", "CI", "SN", "TG"],
      phone: "22961000000",
      name: "John Doe",
      email: "email@mail.com",
      reason: 'Paiement pour transaction $transactionId',
      data: 'Data for transaction $transactionId',
      sandbox: true,
      apikey: publicApiKey,
      // Le callback n'a plus besoin du fretId comme paramètre
      callback: callback, // Simplification du callback
      theme: defaultTheme,
      partnerId: 'AxXxXXxId',
      paymentMethods: const ["momo", "card"],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff222F5A),
        title: const Text('Paiement'),
        centerTitle: true,
      ),
      body: Center(
        child: kkiapay,
      ),
    );
  }
}
