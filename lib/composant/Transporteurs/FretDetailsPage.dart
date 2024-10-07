import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Transporteurs/ValidatedCamionsPage.dart';

class FretDetailsPage extends StatefulWidget {
  final Map<String, dynamic> fretDetails;

  const FretDetailsPage({super.key, required this.fretDetails});

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
      int fretId = widget.fretDetails['id'];

      // Récupérer les détails du voyage
      Map<String, dynamic> voyageDetails =
          await ApiRequest.fetchVoyageDetails(fretId);

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
    // Affichage de l'image du fret
    Widget imageWidget;
    if (widget.fretDetails.containsKey('fret_details') &&
        widget.fretDetails['fret_details'] != null &&
        widget.fretDetails['fret_details'].containsKey('image_url') &&
        widget.fretDetails['fret_details']['image_url'] != null &&
        widget.fretDetails['fret_details']['image_url'].isNotEmpty) {
      imageWidget = Image.network(
        widget.fretDetails['fret_details']['image_url'],
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return const Center(
              child: Text('Erreur de chargement de l\'image',
                  style: TextStyle(color: Colors.red)));
        },
      );
    } else {
      imageWidget = const Text(
        'Aucune image disponible pour ce fret',
        style: TextStyle(color: Colors.black),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Fret'),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(
                  child: Text('Erreur lors du chargement des détails'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        // Utilisation du widget imageWidget
                        Center(child: imageWidget),

                        const SizedBox(height: 10),
                        ListTile(
                          leading: const Icon(Icons.directions_car,
                              color: Colors.black),
                          title: const Text('Type de véhicule'),
                          subtitle: Text(
                              '${widget.fretDetails['type_camion'] ?? 'Non disponible'}'),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          leading: const Icon(Icons.directions_car,
                              color: Colors.black),
                          title: const Text('Type de Marchandise'),
                          subtitle: Text(
                              '${widget.fretDetails['type_marchandise'] ?? 'Non disponible'}'),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          leading: const Icon(Icons.description,
                              color: Colors.black),
                          title: const Text('Description',
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(
                              '${widget.fretDetails['description'] ?? 'Aucune description disponible'}',
                              style: const TextStyle(color: Colors.black)),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          leading: const Icon(Icons.attach_money,
                              color: Colors.black),
                          title: const Text('Montant',
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(_montant,
                              style: const TextStyle(color: Colors.black)),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          leading: const Icon(Icons.location_on,
                              color: Colors.black),
                          title: const Text('Lieu de départ',
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(
                              '${widget.fretDetails['lieu_depart'] ?? 'Non disponible'}',
                              style: const TextStyle(color: Colors.black)),
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          leading: const Icon(Icons.location_on,
                              color: Colors.black),
                          title: const Text('Lieu d\'arrivée',
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(
                              '${widget.fretDetails['lieu_arrive'] ?? 'Non disponible'}',
                              style: const TextStyle(color: Colors.black)),
                        ),
                        ListTile(
                          leading: const Icon(Icons.info, color: Colors.black),
                          title: const Text('Statut',
                              style: TextStyle(color: Colors.black)),
                          subtitle: Text(
                              '${widget.fretDetails['statut'] ?? 'Non disponible'}',
                              style: const TextStyle(color: Colors.black)),
                        ),
                        const SizedBox(height: 30),
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
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color(0xFFFCCE00)),
                              shape: WidgetStateProperty.all<
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
