import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ifret/composant/Chargeurs/d%C3%A9tailsChargeur.dart';

class TrafficChargeur extends StatelessWidget {
  final String dateEnvoi = '2024-04-12'; // Exemple de date
  final String fretEnvoye = '200 sacs de charbon'; // Exemple de fret envoyé

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(), // Pousser le widget RichText vers la droite
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                      text: 'Trajectoire Routière',
                      style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor:
            Color(0xFFFCCE00), // Définir la couleur de fond en noir
        leading: IconButton(
          icon: Icon(Icons
              .arrow_back), // Supposant que vous voulez un bouton de retour
          color: Colors.white, // Définir la couleur du bouton en blanc
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15), // Espace entre chaque Container
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      onTap: () {
                        // Action à effectuer lorsque l'utilisateur appuie sur le ListTile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrafficTable(),
                          ),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      tileColor: Colors.white,
                      title: Text(
                        '$dateEnvoi', // Utilisation de la variable de date
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                        '$fretEnvoye', // Utilisation de la variable de fret envoyé
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      leading:
                          Icon(Icons.directions_car, color: Color(0xfffcce00)),
                      trailing: Container(
                        width: 100, // Largeur fixe du bouton
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrafficTable(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xfffcce00),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                          child: Text(
                            'Détails',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor:
          Colors.grey[400], // Set "dirty white" background for body
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails du trafic'),
          content: Text('Ajoutez ici les détails complets du trafic.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
