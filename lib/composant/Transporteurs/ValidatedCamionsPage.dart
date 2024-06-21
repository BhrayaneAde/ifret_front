import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

class ValidatedCamionsPage extends StatefulWidget {
  final List<dynamic> validatedCamions;
  final int fretId; // Ajout de l'ID du fret

  ValidatedCamionsPage({required this.validatedCamions, required this.fretId});

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
    super.dispose();
  }

  Future<void> fetchCamionDetails(String matricule) async {
    try {
      // Appel à votre API pour récupérer les détails du camion par son matricule
      dynamic camionDetails = await ApiRequest.getCamionDetails(matricule);
      setState(() {
        _selectedMatricule = camionDetails['matricule'];
        _selectedCamionId = camionDetails['id'].toString();
      });
    } catch (e) {
      print('Error fetching camion details: $e');
    }
  }

  void _soumissionner() async {
    try {
      // Retrieve the transporter's phone number from SharedPreferences
      String? numeroTelTransporteur = await ApiRequest.getUserNumeroTel();
      if (numeroTelTransporteur == null) {
        throw Exception('Numéro de téléphone du transporteur non disponible');
      }

      // Check if all required fields are filled
      if (_selectedCamionId == null ||
          _selectedChauffeur == null ||
          _localisationController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text('Veuillez remplir tous les champs.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return; // Exit method if required fields are missing
      }

      // Ensure we have the selected chauffeur's phone number
      String numeroTelChauffeur =
          _selectedChauffeur['numero_tel']; // Chauffeur's phone number

      // Other data
      String localisation = _localisationController.text;

      // Prepare data for submission
      Map<String, dynamic> data = {
        'localisation': localisation,
        'numero_tel_transport': numeroTelTransporteur,
        'vehicule_id': _selectedCamionId,
        'numero_tel_chauffeur': numeroTelChauffeur,
        'demande_id': widget.fretId,
        'statut_soumission': 'En attente',
        'statut_demande': '',
      };

      // Call the APIRequest method for submission
      ApiRequest.soumissionner(data).then((response) {
        if (response != null && response.statusCode == 201) {
          print('Soumission réussie.');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Soumission réussie'),
                content: Text('Les informations ont été soumises avec succès.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
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
          // Show error message if submission fails
          String errorMessage = response != null
              ? 'Erreur lors de la soumission : ${response.statusCode} - ${response.statusMessage}\nDétails: ${response.data}'
              : 'Aucune réponse reçue.';

          print(errorMessage);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Erreur'),
                content: Text(errorMessage),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
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
        // Handle any API request errors
        print('Erreur lors de la soumission : $error');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text(
                  'Erreur lors de la soumission. Veuillez réessayer plus tard.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
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
      // Handle any general errors
      print('Erreur lors de la soumission : $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text(
                'Erreur lors de la récupération des informations de l\'utilisateur. Veuillez réessayer plus tard.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
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
        title: Text('Soumission du Transporteur'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Liste des Camions Disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFCCE00),
                ),
              ),
              SizedBox(height: 10),
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
                    hint: Text('Sélectionner un camion'),
                  ),
                  SizedBox(width: 10),
                  /*  ElevatedButton(
                    onPressed: () {
                      if (_selectedMatricule != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CamionDetailsPage(
                              matricule: _selectedMatricule!,
                            ),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('                      ...
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Erreur'),
                              content: Text('Veuillez sélectionner un camion.'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color(0xFFFCCE00),
                      ),
                    ),
                    child: Text(
                      'Voir Plus',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
           */
                ],
              ),
              _selectedMatricule != null
                  ? Text(
                      'Camion sélectionné: $_selectedMatricule',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  : Container(),
              SizedBox(height: 50),
              Text(
                'Liste des Chauffeurs Disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFCCE00),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: (value) {
                        _filterChauffeurs();
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText:
                            'Rechercher par nom, prénom ou numéro de téléphone',
                        hintText: 'Rechercher...',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _filterChauffeurs();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color(0xFFFCCE00),
                      ),
                    ),
                    child: Text(
                      'Rechercher',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
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
                          hint: Text('Sélectionner un chauffeur'),
                        ),
                        SizedBox(width: 10),
                        /*  ElevatedButton(
                          onPressed: () {
                            if (_selectedChauffeur != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChauffeurDetailsPage(
                                    chauffeur: _selectedChauffeur!,
                                  ),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Erreur'),
                                    content: Text(
                                        'Veuillez sélectionner un chauffeur.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xFFFCCE00),
                            ),
                          ),
                          child: Text(
                            'Détails',
                            style: TextStyle(color: Colors.white),
                          ),
                        ), */
                      ],
                    )
                  : Center(
                      child: Text(
                        'Aucun chauffeur trouvé',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
              SizedBox(height: 20),
              _selectedChauffeur != null
                  ? Text(
                      'Chauffeur sélectionné: ${_selectedChauffeur['nom']} ${_selectedChauffeur['prenom']} (${_selectedChauffeur['numero_tel']})',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  : Container(),
              SizedBox(height: 50),
              Text(
                'Localisation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFCCE00),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _localisationController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Entrez la localisation',
                  hintText: 'Localisation',
                ),
              ),
              SizedBox(height: 70),
              Center(
                child: ElevatedButton(
                  onPressed: _soumissionner,
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

  CamionDetailsPage({required this.matricule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Camion'),
      ),
      body: Center(
        child: Text('Détails pour le camion avec matricule: $matricule'),
      ),
    );
  }
}

class ChauffeurDetailsPage extends StatelessWidget {
  final dynamic chauffeur;

  ChauffeurDetailsPage({required this.chauffeur});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Chauffeur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chauffeur: ${chauffeur['nom']} ${chauffeur['prenom']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Numéro de téléphone: ${chauffeur['numero_tel']}'),
          ],
        ),
      ),
    );
  }
}
