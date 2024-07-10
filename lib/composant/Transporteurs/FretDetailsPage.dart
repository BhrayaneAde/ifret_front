import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Transporteurs/ValidatedCamionsPage.dart';

class FretDetailsPage extends StatefulWidget {
  final Map<String, dynamic> fretDetails;

  FretDetailsPage({required this.fretDetails});

  @override
  _FretDetailsPageState createState() => _FretDetailsPageState();
}

class _FretDetailsPageState extends State<FretDetailsPage> {
  List<dynamic> _camionsValides = [];
  bool _isLoading = true;
  bool _hasError = false; // Ajout d'un état pour gérer les erreurs
  String _montant = 'Non disponible'; // Stocker le montant récupéré

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      // Appel à la méthode pour récupérer les camions validés
      await _fetchCamionsValides();

      // Appel à la méthode pour récupérer le montant du voyage associé
      await _fetchMontant();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Erreur lors de la récupération des détails: $e');
    }
  }

  Future<void> _fetchCamionsValides() async {
    try {
      // Récupérer les camions de l'utilisateur
      List<dynamic> camions = await ApiRequest.getUserCamions();

      // Filtrer les camions validés
      List<dynamic> camionsValides =
          camions.where((camion) => camion['statut'] == 'Validé').toList();

      setState(() {
        _camionsValides = camionsValides;
      });
    } catch (e) {
      print('Erreur lors de la récupération des camions validés: $e');
    }
  }

  Future<void> _fetchMontant() async {
    try {
      // Récupérer l'ID du voyage associé au fret
      int voyageId = widget.fretDetails['id'];

      // Récupérer les détails du voyage
      Map<String, dynamic> voyageDetails =
          await ApiRequest.fetchVoyageDetails(voyageId);

      setState(() {
        _montant = voyageDetails['fret_details']['montant'].toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Erreur lors de la récupération du montant: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Fret'),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Erreur lors du chargement des détails'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 10),
                        ListTile(
                          leading:
                              Icon(Icons.directions_car, color: Colors.black),
                          title: Text('Type de véhicule'),
                          subtitle: Text(
                              '${widget.fretDetails['type_vehicule'] ?? 'Non disponible'}'),
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          leading: Icon(Icons.description, color: Colors.black),
                          title: Text('Description',
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(
                              '${widget.fretDetails['description'] ?? 'Aucune description disponible'}',
                              style: TextStyle(color: Colors.black)),
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          leading:
                              Icon(Icons.attach_money, color: Colors.black),
                          title: Text('Montant',
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(_montant,
                              style: TextStyle(color: Colors.black)),
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          leading: Icon(Icons.location_on, color: Colors.black),
                          title: Text('Lieu de départ',
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(
                              '${widget.fretDetails['lieu_depart'] ?? 'Non disponible'}',
                              style: TextStyle(color: Colors.black)),
                        ),
                        SizedBox(height: 10),
                        ListTile(
                          leading: Icon(Icons.location_on, color: Colors.black),
                          title: Text('Lieu d\'arrivée',
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(
                              '${widget.fretDetails['lieu_arrive'] ?? 'Non disponible'}',
                              style: TextStyle(color: Colors.black)),
                        ),
                        ListTile(
                          leading: Icon(Icons.info, color: Colors.black),
                          title: Text('Statut',
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(
                              '${widget.fretDetails['statut'] ?? 'Non disponible'}',
                              style: TextStyle(color: Colors.black)),
                        ),
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ValidatedCamionsPage(
                                    validatedCamions: _camionsValides,
                                    fretId: widget.fretDetails['id'],
                                  ),
                                ),
                              );
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
                            child: const Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Text(
                                'Soumissionner',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      backgroundColor: Colors.white,
    );
  }
}
