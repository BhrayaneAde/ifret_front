import 'package:flutter/material.dart';

class TrafficTable extends StatelessWidget {
  static final List<Map<String, dynamic>> _trafficData = [
    {
      'vehicle': 'Camion 20 - 30 Tonnes',
      'freight': '200 sacs de charbon',
      'departure': 'Djougou',
      'destination': 'Cotonou',
      'status': 'Finalisé',
    },
  ];

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
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Information du Traffic',
                  ),
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
          color: Colors.black, // Définir la couleur du bouton en blanc
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Détails du Traffic',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 5), // Espace entre chaque Container
            Column(
              children: _trafficData.map<Widget>((traffic) {
                return Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Forme du ListTile
                      ),
                      child: ListTile(
                        onTap: () {
                          // Action à effectuer lorsque l'utilisateur appuie sur le ListTile
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Forme du ListTile
                        ),
                        tileColor:
                            Color(0xfffcce00), // Couleur de fond du ListTile
                        title: Text(
                          'Véhicule:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ), // Couleur du texte
                        ),
                        subtitle: Text(
                          traffic['vehicle'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ), // Couleur du texte
                        ),
                        leading: Icon(Icons.local_shipping,
                            color: Colors.white), // Icône devant le champ
                      ),
                    ),
                    SizedBox(height: 15), // Espace entre chaque Container
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Forme du ListTile
                      ),
                      child: ListTile(
                        onTap: () {
                          // Action à effectuer lorsque l'utilisateur appuie sur le ListTile
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Forme du ListTile
                        ),
                        tileColor:
                            Color(0xfffcce00), // Couleur de fond du ListTile
                        title: Text(
                          'Fret:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ), // Couleur du texte
                        ),
                        subtitle: Text(
                          traffic['freight'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ), // Couleur du texte
                        ),
                        leading: Icon(Icons.grain,
                            color: Colors.white), // Icône devant le champ
                      ),
                    ),
                    SizedBox(height: 15), // Espace entre chaque Container
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Forme du ListTile
                      ),
                      child: ListTile(
                        onTap: () {
                          // Action à effectuer lorsque l'utilisateur appuie sur le ListTile
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Forme du ListTile
                        ),
                        tileColor:
                            Color(0xfffcce00), // Couleur de fond du ListTile
                        title: Text(
                          'Lieu de départ:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ), // Couleur du texte
                        ),
                        subtitle: Text(
                          traffic['departure'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ), // Couleur du texte
                        ),
                        leading: Icon(Icons.location_on,
                            color: Colors.white), // Icône devant le champ
                      ),
                    ),
                    SizedBox(height: 15), // Espace entre chaque Container
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Forme du ListTile
                      ),
                      child: ListTile(
                        onTap: () {
                          // Action à effectuer lorsque l'utilisateur appuie sur le ListTile
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Forme du ListTile
                        ),
                        tileColor:
                            Color(0xfffcce00), // Couleur de fond du ListTile
                        title: Text(
                          'Lieu d\'arrivée:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ), // Couleur du texte
                        ),
                        subtitle: Text(
                          traffic['destination'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ), // Couleur du texte
                        ),
                        leading: Icon(Icons.location_on,
                            color: Colors.white), // Icône devant le champ
                      ),
                    ),
                    SizedBox(height: 15), // Espace entre chaque Container
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Forme du ListTile
                      ),
                      child: ListTile(
                        onTap: () {
                          // Action à effectuer lorsque l'utilisateur appuie sur le ListTile
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Forme du ListTile
                        ),
                        tileColor:
                            Color(0xfffcce00), // Couleur de fond du ListTile
                        title: Text(
                          'Statut:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ), // Couleur du texte
                        ),
                        subtitle: Text(
                          traffic['status'],
                          style: TextStyle(
                            color: traffic['status'] == 'En cours'
                                ? Colors.orange
                                : Colors.green,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ), // Couleur du texte
                        ),
                        leading: Icon(Icons.info_outline,
                            color: Colors.white), // Icône devant le champ
                      ),
                    ),
                    SizedBox(height: 15), // Espace entre chaque Container
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
      backgroundColor:
          Colors.grey[300], // Set "dirty white" background for body
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TrafficTable(),
  ));
}
