import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

class ValidatedCamionsPage extends StatefulWidget {
  final List<dynamic> validatedCamions;
  final int fretId; // Ajout de l'ID du fret

  const ValidatedCamionsPage(
      {super.key, required this.validatedCamions, required this.fretId});

  @override
  _ValidatedCamionsPageState createState() => _ValidatedCamionsPageState();
}

class _ValidatedCamionsPageState extends State<ValidatedCamionsPage> {
  String? _selectedMatricule;
  String? _selectedCamionId;
  dynamic _selectedChauffeur;
  List<dynamic>? chauffeurs;
  final TextEditingController _localisationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _montantProposerController =
      TextEditingController(); // Ajout du contrôleur pour montantProposer

  String? numeroTelTransporteur;
  List<dynamic> _filteredChauffeurs = [];

  @override
  void initState() {
    super.initState();
    fetchChauffeurs();
    print('ID du fret: ${widget.fretId}'); // Affichage de l'ID du fret
    fetchUserNumeroTel(); // Call method to fetch auth token and user data
  }

  Future<void> fetchUserNumeroTel() async {
    try {
      // Fetch user's phone number from SharedPreferences
      String? userNumeroTel = await ApiRequest.getUserNumeroTel();
      setState(() {
        numeroTelTransporteur = userNumeroTel;
      });
    } catch (e) {
      print('Error fetching user phone number: $e');
      // Handle error as needed
    }
  }

  Future<void> fetchChauffeurs() async {
    try {
      List<dynamic>? fetchedChauffeurs = await ApiRequest.getChauffeurs();
      setState(() {
        chauffeurs = fetchedChauffeurs;
        _filteredChauffeurs.addAll(chauffeurs!); // Initialize filtered list
      });
    } catch (e) {
      print('Error fetching chauffeurs: $e');
    }
  }

  @override
  void dispose() {
    _localisationController.dispose();
    _searchController.dispose(); // Dispose of the search controller
    _montantProposerController
        .dispose(); // Dispose of montantProposer controller
    super.dispose();
  }

  Future<void> fetchCamionDetails(String matricule) async {
    try {
      dynamic camionDetails = await ApiRequest.getCamionDetails(matricule);

      // Log des détails du camion récupérés
      print('Camion Details: $camionDetails');

      setState(() {
        _selectedMatricule = camionDetails['matricule'];
        _selectedCamionId = camionDetails['id'].toString();
      });
    } catch (e) {
      // Log de l'erreur de récupération des détails du camion
      print('Error fetching camion details: $e');
      // Vous pouvez également afficher un message d'erreur à l'utilisateur ici
    }
  }

  void _soumissionner() async {
    try {
      // Récupérer le numéro de téléphone du transporteur depuis SharedPreferences
      String? numeroTelTransporteur = await ApiRequest.getUserNumeroTel();
      if (numeroTelTransporteur == null) {
        throw Exception('Numéro de téléphone du transporteur non disponible');
      }

      // Vérifiez si tous les champs requis sont remplis
      if (_selectedCamionId == null ||
          _selectedChauffeur == null ||
          _localisationController.text.isEmpty ||
          _montantProposerController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur'),
              content: const Text('Veuillez remplir tous les champs.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return; // Sortir de la méthode si des champs requis sont manquants
      }

      // Assurez-vous d'avoir le numéro de téléphone du chauffeur sélectionné
      String numeroTelChauffeur =
          _selectedChauffeur['numero_tel']; // Numéro de téléphone du chauffeur
      String montantProposer =
          _montantProposerController.text; // Récupérer montantProposer
      String localisation = _localisationController.text;

      // Préparer les données pour la soumission
      Map<String, dynamic> data = {
        'localisation': localisation,
        'numero_tel_transport': numeroTelTransporteur,
        'vehicule_id': _selectedCamionId,
        'numero_tel_chauffeur': numeroTelChauffeur,
        'montant':
            montantProposer, // Inclure montantProposer dans la soumission
        'fret_id': widget.fretId, // Assurez-vous que c'est le bon champ
        'statut': 'En attente',
        'statut_demande': '',
      };

      print(
          'Données soumises: $data'); // Log pour vérifier les données soumises

      // Appel de la méthode APIRequest pour la soumission
      ApiRequest.soumissionner(data).then((response) {
        if (response != null && response.statusCode == 201) {
          print('Soumission réussie.');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Soumission réussie'),
                content: const Text(
                    'Les informations ont été soumises avec succès.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(
                          '/notifications'); // Naviguer vers la page de notifications
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Afficher un message d'erreur si la soumission échoue
          String errorMessage = response != null
              ? 'Erreur lors de la soumission : ${response.statusCode} - ${response.statusMessage}\nDétails: ${response.data}'
              : 'Aucune réponse reçue.';

          print(errorMessage);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Erreur'),
                content: Text(errorMessage),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }).catchError((error) {
        // Gérer les erreurs de requête API
        print('Erreur lors de la soumission : $error');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur'),
              content: const Text(
                  'Erreur lors de la soumission. Veuillez réessayer plus tard.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    } catch (error) {
      // Gérer les erreurs générales
      print('Erreur lors de la soumission : $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: const Text(
                'Erreur lors de la récupération des informations de l\'utilisateur. Veuillez réessayer plus tard.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _filterChauffeurs() {
    String searchText = _searchController.text.toLowerCase();
    setState(() {
      _filteredChauffeurs = chauffeurs!
          .where((chauffeur) =>
              chauffeur['nom'].toLowerCase().contains(searchText) ||
              chauffeur['prenom'].toLowerCase().contains(searchText) ||
              chauffeur['numero_tel'].toLowerCase().contains(searchText))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soumission du Transporteur'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Liste des Camions Disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFCCE00),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedMatricule,
                    items: widget.validatedCamions
                        .map<DropdownMenuItem<String>>((camion) {
                      return DropdownMenuItem<String>(
                        value: camion['matricule'],
                        child: Text(camion['matricule']),
                      );
                    }).toList(),
                    onChanged: (String? selectedMatricule) {
                      if (selectedMatricule != null) {
                        fetchCamionDetails(selectedMatricule);
                      }
                    },
                    hint: const Text('Sélectionner un camion'),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              _selectedMatricule != null
                  ? Text(
                      'Camion sélectionné: $_selectedMatricule',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  : Container(),
              const SizedBox(height: 50),
              const Text(
                'Liste des Chauffeurs Disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFCCE00),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: (value) {
                        _filterChauffeurs();
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText:
                            'Rechercher par nom, prénom ou numéro de téléphone',
                        hintText: 'Rechercher...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _filterChauffeurs();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        const Color(0xFFFCCE00),
                      ),
                    ),
                    child: const Text(
                      'Rechercher',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _filteredChauffeurs.isNotEmpty
                  ? Row(
                      children: [
                        DropdownButton<dynamic>(
                          value: _selectedChauffeur,
                          items: _filteredChauffeurs
                              .map<DropdownMenuItem<dynamic>>((chauffeur) {
                            return DropdownMenuItem<dynamic>(
                              value: chauffeur,
                              child: Text(
                                  '${chauffeur['nom']} ${chauffeur['prenom']} (${chauffeur['numero_tel']})'),
                            );
                          }).toList(),
                          onChanged: (dynamic selectedChauffeur) {
                            setState(() {
                              _selectedChauffeur = selectedChauffeur;
                            });
                          },
                          hint: const Text('Sélectionner un chauffeur'),
                        ),
                        const SizedBox(width: 10),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Aucun chauffeur trouvé',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
              const SizedBox(height: 20),
              _selectedChauffeur != null
                  ? Text(
                      'Chauffeur sélectionné: ${_selectedChauffeur['nom']} ${_selectedChauffeur['prenom']} (${_selectedChauffeur['numero_tel']})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  : Container(),
              const SizedBox(height: 50),
              const Text(
                'Localisation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFCCE00),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _localisationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Entrez la localisation',
                  hintText: 'Localisation',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Montant Proposé',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFCCE00),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller:
                    _montantProposerController, // Champ pour le montant proposé
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Montant proposé',
                  hintText: 'Entrez le montant proposé',
                ),
              ),
              const SizedBox(height: 70),
              Center(
                child: ElevatedButton(
                  onPressed: _soumissionner,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(const Color(0xFFFCCE00)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Valider',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CamionDetailsPage extends StatelessWidget {
  final String matricule;

  const CamionDetailsPage({super.key, required this.matricule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Camion'),
      ),
      body: Center(
        child: Text('Détails pour le camion avec matricule: $matricule'),
      ),
    );
  }
}

class ChauffeurDetailsPage extends StatelessWidget {
  final dynamic chauffeur;

  const ChauffeurDetailsPage({super.key, required this.chauffeur});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Chauffeur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chauffeur: ${chauffeur['nom']} ${chauffeur['prenom']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Numéro de téléphone: ${chauffeur['numero_tel']}'),
          ],
        ),
      ),
    );
  }
}
