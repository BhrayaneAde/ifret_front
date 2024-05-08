import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class Clientele extends StatelessWidget {
  // Sample customer service number (replace with actual number)
  final String customerServiceNumber = '+1234567890';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: 'Service Clientèle',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFFFCCE00),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Support',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  onTap: () => _makeCall(context, customerServiceNumber),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  tileColor: Color(0xFF14337C),
                  title: Row(
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Service Clientèle',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.phone),
                    onPressed: () => _makeCall(context, customerServiceNumber),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makeCall(BuildContext context, String phoneNumber) async {
    // Check if phone number is valid (optional)
    if (phoneNumber.isEmpty) {
      return;
    }

    // Print if the number is retrieved
    print('Numéro récupéré : $phoneNumber');

    // Create a valid Uri object from the phone number
    final url = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(url)) {
      // Print if the redirection is successful
      print('Redirection vers le numéro $phoneNumber réussie');
      await launchUrl(url);
    } else {
      // Print the reason if the redirection fails
      print('Échec de la redirection vers le numéro $phoneNumber');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de lancer l\'application téléphone.'),
        ),
      );
    }
  }
}
