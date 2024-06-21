import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Transporteurs/d%C3%A9tailsTransporteur.dart';
import 'package:intl/intl.dart';

class TrafficTransporteur extends StatefulWidget {
  @override
  _TrafficTransporteurState createState() => _TrafficTransporteurState();
}

class _TrafficTransporteurState extends State<TrafficTransporteur> {
  List<Map<String, dynamic>> voyages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVoyages();
  }

  Future<void> loadVoyages() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> fetchedVoyages =
          await ApiRequest.fetchVoyages();
      print(
          'Fetched Voyages: $fetchedVoyages'); // Log pour vérifier les données

      setState(() {
        voyages = fetchedVoyages; // Charger tous les voyages sans filtre
        isLoading = false;
      });
    } catch (e) {
      print('Error loading voyages: $e');
      setState(() {
        isLoading = false;
      });
      // Gérer l'erreur
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('Erreur lors du chargement des voyages.'),
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

  // Fonction pour formater la date et l'heure
  String formatDateTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Fonction pour gérer le tap sur un voyage
  Future<void> handleVoyageTap(Map<String, dynamic> voyageDetails) async {
    if (voyageDetails.containsKey('demande_id')) {
      int demandeId = voyageDetails['demande_id'];
      print('Demande ID: $demandeId');

      try {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTransporteur(
              demandeId: demandeId,
            ),
          ),
        );
        // Vous pouvez ajouter ici des actions après la navigation si nécessaire
      } catch (e) {
        print('Erreur lors de la navigation vers les détails du voyage: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erreur'),
            content: Text(
                'Détails du voyage non disponibles pour cet ID de demande.'),
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
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('ID de la demande manquant.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique Parcours',
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
          : voyages.isEmpty
              ? Center(
                  child: Text('Aucun voyage disponible'),
                )
              : ListView.builder(
                  itemCount: voyages.length,
                  itemBuilder: (context, index) {
                    final voyage = voyages[index];

                    // Vérifier si voyage est null ou vide
                    if (voyage == null || voyage.isEmpty) {
                      return SizedBox.shrink(); // Retourner un widget vide
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          onTap: () => handleVoyageTap(voyage),
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
                          leading: Icon(Icons.directions_car,
                              color: Color(0xFFFCCE00)),
                          trailing: Container(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () => handleVoyageTap(voyage),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
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
                    );
                  },
                ),
      backgroundColor: Colors.grey[400],
    );
  }
}
