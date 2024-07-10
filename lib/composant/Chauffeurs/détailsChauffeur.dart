import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

class DetailChauffeur extends StatefulWidget {
  final int voyageId; // L'ID du voyage
  final int chauffeurId;

  DetailChauffeur(
      {required this.chauffeurId,
      required this.voyageId}); // Assurez-vous de l'ajouter au constructeur

  @override
  _DetailChauffeurState createState() => _DetailChauffeurState();
}

class _DetailChauffeurState extends State<DetailChauffeur> {
  late Map<String, dynamic> _voyageDetails;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchVoyageDetails(); // Récupérer les détails du voyage lors de l'initialisation
  }

  Future<void> _fetchVoyageDetails() async {
    try {
      // Appel de l'API pour récupérer les détails du voyage
      Map<String, dynamic> details =
          await ApiRequest.fetchVoyageDetails(widget.voyageId);
      setState(() {
        _voyageDetails = details;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails Chauffeur',
          style: TextStyle(color: Colors.black),
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
                  child: Text('Erreur lors de la récupération des données'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        _buildDetailsCard(
                            'Nom:', _voyageDetails['chauffeur_nom'] ?? 'N/A'),
                        _buildDetailsCard('Prénom(s):',
                            _voyageDetails['chauffeur_prenom'] ?? 'N/A'),
                        _buildDetailsCard('Numéro de Téléphone:',
                            _voyageDetails['numero_tel_chauffeur'] ?? 'N/A'),
                      ],
                    ),
                  ),
                ),
      backgroundColor: Colors.grey[200],
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
