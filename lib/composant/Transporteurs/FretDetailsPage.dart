import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Transporteurs/ValidatedCamionsPage.dart';

class FretDetailsPage extends StatefulWidget {
  final Map<String, dynamic> fretDetails;

  FretDetailsPage({required this.fretDetails});

  @override
  _FretDetailsPageState createState() => _FretDetailsPageState();
}

class _FretDetailsPageState extends State<FretDetailsPage> {
  List<dynamic> _camionsValides = []; // Déclaration de _camionsValides
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCamionsValides();
  }

  Future<void> _fetchCamionsValides() async {
    try {
      // Appel à la méthode statique pour récupérer les camions depuis ApiRequest
      List<dynamic> camions = await ApiRequest.getUserCamions();

      // Filtrer les camions validés
      List<dynamic> camionsValides =
          camions.where((camion) => camion['statut'] == 'Validé').toList();

      setState(() {
        _camionsValides = camionsValides;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des camions validés: $e');
      setState(() {
        _isLoading = false;
      });
      // Gérez l'erreur ici, par exemple, affichez un message à l'utilisateur
    }
  }

  Widget build(BuildContext context) {
    // Print pour afficher les détails complets du fret
    print('Détails complets du fret : ${widget.fretDetails}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Fret'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /*  ListTile(
                leading: Icon(Icons.message, color: Colors.black),
                title: Text('Message', style: TextStyle(color: Colors.black)),
                subtitle: Text(
                    '${widget.fretDetails['message'] ?? 'Non disponible'}',
                    style: TextStyle(color: Colors.black)),
              ), */
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.black),
                title: Text('Lieu de départ',
                    style: TextStyle(color: Colors.black)),
                subtitle: Text(
                    '${widget.fretDetails['lieu_depart'] ?? 'Non disponible'}',
                    style: TextStyle(color: Colors.black)),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.black),
                title: Text('Lieu d\'arrivée',
                    style: TextStyle(color: Colors.black)),
                subtitle: Text(
                    '${widget.fretDetails['lieu_arrive'] ?? 'Non disponible'}',
                    style: TextStyle(color: Colors.black)),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(Icons.attach_money, color: Colors.black),
                title: Text('Montant', style: TextStyle(color: Colors.black)),
                subtitle: Text(
                    '${widget.fretDetails['montant'] ?? 'Non disponible'}',
                    style: TextStyle(color: Colors.black)),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(Icons.description, color: Colors.black),
                title:
                    Text('Description', style: TextStyle(color: Colors.black)),
                subtitle: Text(
                    '${widget.fretDetails['description'] ?? 'Aucune description disponible'}',
                    style: TextStyle(color: Colors.black)),
              ),
              SizedBox(
                height: 10,
              ),
              /*  ListTile(
                leading: Icon(Icons.phone, color: Colors.black),
                title: Text('Numéro de téléphone',
                    style: TextStyle(color: Colors.black)),
                subtitle: Text(
                    '${widget.fretDetails['numero_tel'] ?? 'Non disponible'}',
                    style: TextStyle(color: Colors.black)),
              ), */
              ListTile(
                leading: Icon(Icons.info, color: Colors.black),
                title: Text('Statut', style: TextStyle(color: Colors.black)),
                subtitle: Text(
                    '${widget.fretDetails['statut'] ?? 'Non disponible'}',
                    style: TextStyle(color: Colors.black)),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(Icons.directions_car, color: Colors.black),
                title: Text('Type de véhicule'),
                subtitle: Text(
                    '${widget.fretDetails['type_vehicule'] ?? 'Non disponible'}'),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ValidatedCamionsPage(
                        validatedCamions: _camionsValides,
                        fretId: widget.fretDetails['id'], // Passer l'ID du fret
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFFFCCE00)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Soumissionner',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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
