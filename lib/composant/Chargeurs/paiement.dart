import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';
import 'success_screen.dart';

const String publicApiKey = "2b8e553045da11efba1789f22fb73fae";

class PaiementPage extends StatelessWidget {
  final String transactionId;
  final int montant;

  PaiementPage({
    required this.transactionId,
    required this.montant,
  });

  void callback(Map<String, dynamic> response, BuildContext context) async {
    print('Callback triggered');
    print('Response: ${response.toString()}'); // Imprime la réponse complète

    switch (response['status']) {
      case PAYMENT_CANCELLED:
        debugPrint(PAYMENT_CANCELLED);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PAYMENT_CANCELLED),
        ));
        break;

      case PENDING_PAYMENT:
        debugPrint(PENDING_PAYMENT);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PENDING_PAYMENT),
        ));
        break;

      case PAYMENT_INIT:
        debugPrint(PAYMENT_INIT);
        break;

      case PAYMENT_SUCCESS:
        print(response['status']);
        debugPrint(PAYMENT_SUCCESS);
        print('Transaction ID: ${response['transactionId']}');
        print('Montant Payé: ${response['requestData']['amount']}');

        String kkiapayTransactionId =
            response['transactionId']?.toString() ?? '';
        int montantPaye =
            int.tryParse(response['requestData']['amount']?.toString() ?? '') ??
                0;

        try {
          // Appeler la méthode avec les valeurs converties
          await ApiRequest.storeTransaction(
              transactionId, kkiapayTransactionId, montantPaye);
        } catch (e) {
          print('Erreur lors du stockage de la transaction: $e');
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PAYMENT_SUCCESS),
        ));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              montantPaye: montantPaye,
              transactionId: transactionId,
            ),
          ),
        );
        break;

      case PAYMENT_FAILED:
        debugPrint(PAYMENT_FAILED);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PAYMENT_FAILED),
        ));
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
      countries: ["BJ", "CI", "SN", "TG"],
      phone: "22961000000",
      name: "John Doe",
      email: "email@mail.com",
      reason: 'Paiement',
      data: 'Donnée de transaction',
      sandbox: true,
      apikey: publicApiKey,
      callback: callback, // Utiliser le callback correct
      theme: defaultTheme,
      partnerId: 'AxXxXXxId',
      paymentMethods: ["momo", "card"],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff222F5A),
        title: const Text('Paiement'),
        centerTitle: true,
      ),
      body: Center(
        child: kkiapay,
      ),
    );
  }
}
