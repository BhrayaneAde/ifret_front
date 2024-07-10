import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

import 'package:intl/intl.dart';

import 'détailsChauffeur.dart';

class TrafficChauffeur extends StatefulWidget {
  @override
  _TrafficChauffeurState createState() => _TrafficChauffeurState();
}

class _TrafficChauffeurState extends State<TrafficChauffeur> {
  Map<String, dynamic> voyage = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVoyageDetails(); // Charger les détails du premier voyage par défaut
  }

  // Fonction pour charger les détails du voyage et du chauffeur associé
  Future<void> loadVoyageDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Supposons que vous récupérez l'ID du voyage d'une source dynamique
      int voyageId =
          await _getVoyageId(); // Appel à une fonction pour récupérer l'ID du voyage

      Map<String, dynamic> fetchedVoyage =
          await ApiRequest.fetchVoyageDetails(voyageId);

      setState(() {
        voyage = fetchedVoyage;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading voyage details: $e');
      setState(() {
        isLoading = false;
      });
      // Gérer l'erreur, par exemple afficher un message à l'utilisateur
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('Erreur lors du chargement des détails du voyage.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  // Fonction fictive pour récupérer l'ID du voyage (à adapter selon votre logique)
  Future<int> _getVoyageId() async {
    // Ici, vous pouvez implémenter la logique pour récupérer l'ID du voyage
    // Par exemple, à partir d'une liste de voyages, d'une sélection utilisateur, etc.
    return 1; // Retourne un ID fictif pour cet exemple, à remplacer par votre propre logique
  }

  // Fonction pour formater la date et l'heure
  String formatDateTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique Parcours Chauffeurs',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFFCCE00),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : voyage.isEmpty
              ? Center(
                  child: Text('Aucun voyage disponible'),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      onTap: () async {
                        int chauffeurId = voyage['chauffeur']
                            ['id']; // Récupérer l'ID du chauffeur
                        int voyageId = voyage['id']; // Récupérer l'ID du voyage

                        // Utiliser Navigator pour aller à DetailChauffeur avec l'ID
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailChauffeur(
                              chauffeurId: chauffeurId,
                              voyageId:
                                  voyageId, // Passer voyageId à DetailChauffeur
                            ),
                          ),
                        );
                        // Après retour de DetailChauffeur, rafraîchir les détails du voyage si nécessaire
                        loadVoyageDetails();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      tileColor: Colors.white,
                      title: Text(
                        formatDateTime(voyage['date_creation']),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                        voyage['vehicule_matricule'] ?? 'N/A',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      leading:
                          Icon(Icons.directions_car, color: Color(0xFFFCCE00)),
                      trailing: Container(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () async {
                            int chauffeurId = voyage['chauffeur']
                                ['id']; // Récupérer l'ID du chauffeur
                            int voyageId =
                                voyage['id']; // Récupérer l'ID du voyage

                            // Utiliser Navigator pour aller à DetailChauffeur avec l'ID
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailChauffeur(
                                  chauffeurId: chauffeurId,
                                  voyageId:
                                      voyageId, // Passer voyageId à DetailChauffeur
                                ),
                              ),
                            );
                            // Après retour de DetailChauffeur, rafraîchir les détails du voyage si nécessaire
                            loadVoyageDetails();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFFFCCE00)),
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
      backgroundColor: Colors.grey[200],
    );
  }
}
