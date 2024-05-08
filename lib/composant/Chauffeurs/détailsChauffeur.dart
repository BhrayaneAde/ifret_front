import 'package:flutter/material.dart';

class DetailChauffeur extends StatelessWidget {
  final String dateEnvoi;
  final String matricule;

  DetailChauffeur({
    required this.dateEnvoi,
    required this.matricule,
  });

  static final List<Map<String, dynamic>> _trafficData = [
    {
      'vehicle': 'Camion 20 - 30 Tonnes',
      'freight': '200 sacs de charbon',
      'departure': 'Djougou',
      'destination': 'Cotonou',
      'datedepart': '18/10/2023',
      'datearrive': '20/10/2023',
      'status': 'Finalisé',
      'matricule': 'AX 5820', // Ajout du champ "matricule"
    },
  ];

  static final List<Map<String, dynamic>> _trafficDataUser = [
    {
      'nom': 'AKAKPO',
      'prenom': 'Jacques Bidossessi',
      'numero': '+229 90205486',
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
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                      text: 'Informations Completes',
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
          color: Colors.black, // Définir la couleur du bouton en blanc
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5), // Espace entre chaque Container
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Détails Fret',
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
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
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),
                      SizedBox(height: 5), // Espace entre chaque Container
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
                          title: Text(
                            'Matricule:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          subtitle: Text(
                            traffic['matricule'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          leading: Icon(Icons.local_shipping,
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),
                      SizedBox(height: 5), // Espace entre chaque Container

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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
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
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),
                      SizedBox(height: 5), // Espace entre chaque Container
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
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
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),

                      SizedBox(height: 5), // Espace entre chaque Container
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
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
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),
                      SizedBox(height: 5), // Espace entre chaque Container
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
                          title: Text(
                            'Date de Départ:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          subtitle: Text(
                            traffic['datedepart'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          leading: Icon(Icons.view_agenda,
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),
                      SizedBox(height: 5), // Espace entre chaque Container
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
                          title: Text(
                            'Date d\'Arrivée',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          subtitle: Text(
                            traffic['datearrive'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          leading: Icon(Icons.calendar_month,
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),
                      SizedBox(height: 5), // Espace entre chaque Container
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
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
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),
                      SizedBox(height: 5), // Espace entre chaque Container

                      SizedBox(height: 15), // Espace entre chaque Container
                    ],
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Détails Chauffeur',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5), // Espace entre chaque Container
              Column(
                children: _trafficDataUser.map<Widget>((traffic) {
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
                          title: Text(
                            'Nom:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          subtitle: Text(
                            traffic['nom'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          leading: Icon(Icons.supervised_user_circle,
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),
                      SizedBox(height: 5), // Espace entre chaque Container
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
                          title: Text(
                            'Prénom(s):',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          subtitle: Text(
                            traffic['prenom'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          leading: Icon(Icons.verified_user_rounded,
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),
                      SizedBox(height: 5), // Espace entre chaque Container
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
                            borderRadius: BorderRadius.circular(
                                10.0), // Forme du ListTile
                          ),
                          tileColor:
                              Colors.white, // Couleur de fond du ListTile
                          title: Text(
                            'Numero de Téléphone:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          subtitle: Text(
                            traffic['numero'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              decoration: TextDecoration.none,
                            ), // Couleur du texte
                          ),
                          leading: Icon(Icons.phone_callback,
                              color:
                                  Color(0xfffcce00)), // Icône devant le champ
                        ),
                      ),
                      SizedBox(height: 5), // Espace entre chaque Container
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Forme du ListTile
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      backgroundColor:
          Colors.grey[400], // Set "dirty white" background for body
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DetailChauffeur(
      dateEnvoi: '',
      matricule: '',
    ),
  ));
}
