import 'package:flutter/material.dart';
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';
import 'success_screen.dart';

// Votre clé API publique ici
const String publicApiKey = "2b8e553045da11efba1789f22fb73fae";

void callback(response, context) {
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
      debugPrint(PAYMENT_SUCCESS);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(PAYMENT_SUCCESS),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            amount: response['requestData']['amount'],
            transactionId: response['transactionId'],
          ),
        ),
      );
      break;

    case PAYMENT_FAILED:
      debugPrint(PAYMENT_FAILED);
      break;

    default:
      debugPrint(UNKNOWN_EVENT);
      break;
  }
}

class PaiementPage extends StatelessWidget {
  final int transactionId;
  final int montant;

  PaiementPage({required this.transactionId, required this.montant});

  @override
  Widget build(BuildContext context) {
    final kkiapay = KKiaPay(
      amount: montant,
      countries: ["BJ", "CI", "SN", "TG"],
      phone: "22961000000",
      name: "John Doe",
      email: "email@mail.com",
      reason: 'Paiement pour transaction $transactionId',
      data: 'Data for transaction $transactionId',
      sandbox: true,
      apikey: publicApiKey,
      callback: callback,
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
