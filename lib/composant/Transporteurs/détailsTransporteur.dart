import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

class DetailTransporteur extends StatefulWidget {
  final int demandeId;

  DetailTransporteur({required this.demandeId});

  @override
  _DetailTransporteurState createState() => _DetailTransporteurState();
}

class _DetailTransporteurState extends State<DetailTransporteur> {
  late Map<String, dynamic> _voyageDetails = {}; // Initialize with empty map
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchVoyageDetails();
  }

  Future<void> _fetchVoyageDetails() async {
    try {
      // Récupérer les détails du voyage
      Map<String, dynamic> details =
          await ApiRequest.fetchVoyageDetails(widget.demandeId);

      // Extraire les détails du fret si disponibles
      if (details.containsKey('fret_details')) {
        // Assurer que la clé 'description_fret' est correctement extraite
        details['fret_details']['description'] = details['fret_details']
                ['description_fret'] ??
            'Aucune description disponible';
      }

      setState(() {
        _voyageDetails = details;
        _isLoading = false;
      });
    } catch (error) {
      print('Erreur lors de la récupération des détails du voyage : $error');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Détails du Voyage',
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
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erreur lors du chargement des détails du voyage'),
                      SizedBox(height: 10),
                      Text('Détails de l\'erreur: $_errorMessage'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Détails du Fret'),
                        _buildDetailsCard(
                          'Type de Véhicule:',
                          _voyageDetails['fret_details']?['type_vehicule'] ??
                              'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Montant:',
                          _voyageDetails['fret_details']?['montant']
                                  ?.toString() ??
                              'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Lieu de Départ:',
                          _voyageDetails['fret_details']?['lieu_depart'] ??
                              'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Lieu d\'Arrivée:',
                          _voyageDetails['fret_details']?['lieu_arrive'] ??
                              'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Date de Départ:',
                          _voyageDetails['fret_details']?['date_depart'] ??
                              'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Date d\'Arrivée:',
                          _voyageDetails['fret_details']?['date_arrive'] ??
                              'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Description du Fret:',
                          _voyageDetails['fret_details']?['description'] ??
                              'Aucune description disponible',
                        ),
                        SizedBox(height: 15),
                        _buildSectionTitle('Détails du Voyage'),
                        _buildDetailsCard(
                          'Numéro de Téléphone du Transporteur:',
                          _voyageDetails['numero_tel_transport'] ??
                              'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Matricule du Véhicule:',
                          _voyageDetails['vehicule_matricule'] ??
                              'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Numéro de Téléphone du Chauffeur:',
                          _voyageDetails['numero_tel_chauffeur'] ??
                              'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Nom du Chauffeur:',
                          _voyageDetails['chauffeur_nom'] ?? 'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Prénom du Chauffeur:',
                          _voyageDetails['chauffeur_prenom'] ?? 'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'ID de la Demande:',
                          _voyageDetails['demande_id'].toString(),
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Statut de la Soumission:',
                          _voyageDetails['statut_soumission'] ?? 'Non spécifié',
                        ),
                        SizedBox(height: 5),
                        _buildDetailsCard(
                          'Statut de la Demande:',
                          _voyageDetails['statut_demande'] ?? 'Non spécifié',
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
      backgroundColor: Colors.grey[400],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        tileColor: Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
        leading: Icon(
          Icons.info,
          color: Color(0xfffcce00),
        ),
      ),
    );
  }
}
