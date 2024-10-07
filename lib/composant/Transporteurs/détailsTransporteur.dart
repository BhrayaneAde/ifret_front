import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

class DetailTransporteur extends StatefulWidget {
  final int fretId;

  const DetailTransporteur({super.key, required this.fretId});

  @override
  _DetailTransporteurState createState() => _DetailTransporteurState();
}

class _DetailTransporteurState extends State<DetailTransporteur> {
  late Map<String, dynamic> fretDetails = {}; // Initialize with empty map
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
      Map<String, dynamic> fretdetails =
          await ApiRequest.fetchFretVoyageDetails(widget.fretId);

      // Extraire les détails du fret si disponibles
      if (fretdetails.containsKey('fret_details')) {
        // Assurer que la clé 'description' est correctement extraite
        fretdetails['fret_details']['description'] = fretdetails['fret_details']
                ['description'] ??
            'Aucune description disponible';
      }

      setState(() {
        fretDetails = fretdetails;
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
              text: const TextSpan(
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
        backgroundColor: const Color(0xFFFCCE00),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                          'Erreur lors du chargement des détails du voyage'),
                      const SizedBox(height: 10),
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
                        _buildSectionTitle('Statut'),
                        const SizedBox(height: 5),
                        _buildDetailsCard(
                          'Statut:',
                          fretDetails['statut'] ?? 'Non spécifié',
                        ),
                        _buildSectionTitle('Fret'),
                        const SizedBox(height: 5),
                        _buildDetailsCard(
                          'Description :',
                          fretDetails['fret_details']?['description'] ??
                              'Aucune description disponible',
                        ),
                        const SizedBox(height: 5),
                        _buildDetailsCard(
                          'Montant:',
                          fretDetails['fret_details']?['montant']?.toString() ??
                              'Non spécifié',
                        ),
                        const SizedBox(height: 5),
                        _buildDetailsCard(
                          'Lieu de Départ:',
                          fretDetails['fret_details']?['lieu_depart'] ??
                              'Non spécifié',
                        ),
                        const SizedBox(height: 5),
                        _buildDetailsCard(
                          'Lieu d\'Arrivée:',
                          fretDetails['fret_details']?['lieu_arrive'] ??
                              'Non spécifié',
                        ),
                        _buildSectionTitle('Véhicule'),
                        _buildDetailsCard(
                          'Type :',
                          fretDetails['type_vehicule'] ?? 'Non spécifié',
                        ),
                        const SizedBox(height: 5),
                        _buildDetailsCard(
                          'Matricule :',
                          fretDetails['vehicule_matricule'] ?? 'Non spécifié',
                        ),
                        const SizedBox(height: 5),
                        _buildDetailsCard(
                          'Date de Départ:',
                          fretDetails['fret_details']?['date_depart'] ??
                              'Non spécifié',
                        ),
                        const SizedBox(height: 5),
                        _buildDetailsCard(
                          'Date d\'Arrivée:',
                          fretDetails['fret_details']?['date_arrive'] ??
                              'Non spécifié',
                        ),
                        /*  SizedBox(height: 5),
                        _buildDetailsCard(
                          'Statut de la Soumission:',
                          fretDetails['statut_soumission'] ?? 'Non spécifié',
                        ), */

                        const SizedBox(height: 15),
                        _buildSectionTitle('Chauffeur'),
                        const SizedBox(height: 5),
                        _buildDetailsCard(
                          'Nom et Prénom :',
                          '${fretDetails['chauffeur_nom'] ?? 'Non spécifié'} ${fretDetails['chauffeur_prenom'] ?? 'Non spécifié'}',
                        ),
                        const SizedBox(height: 5),
                        _buildDetailsCard(
                          'Téléphone :',
                          fretDetails['numero_tel_chauffeur'] ?? 'Non spécifié',
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
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
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            decoration: TextDecoration.none,
          ),
        ),
        leading: const Icon(
          Icons.info,
          color: Color(0xfffcce00),
        ),
      ),
    );
  }
}
