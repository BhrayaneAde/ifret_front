import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:ifret/api/api_request.dart';

class EnregistrerCamionModifPage extends StatefulWidget {
  final String? matricule;
  final Map<String, dynamic> details;

  const EnregistrerCamionModifPage(
      {super.key, required this.matricule, required this.details});

  @override
  _EnregistrerCamionModifPageState createState() =>
      _EnregistrerCamionModifPageState();
}

class _EnregistrerCamionModifPageState
    extends State<EnregistrerCamionModifPage> {
  final TextEditingController _matriculeController = TextEditingController();
  File? _photoCamion;
  File? _carteGrise;
  File? _visiteTechnique;
  File? _assurance;
  String? _photoCamionCommentaire;
  String? _carteGriseCommentaire;
  String? _visiteTechniqueCommentaire;
  String? _assuranceCommentaire;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.matricule != null) {
      _fetchCamionDetails(widget.matricule!);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCamionDetails(String matricule) async {
    try {
      var camion = await ApiRequest.getCamionDetails(matricule);

      // Print the entire response to debug
      print('API Response: $camion');

      setState(() {
        _matriculeController.text = camion['matricule'] ?? '';

        // Set other fields based on the API response
        _photoCamion = camion['photo_camion'] != null
            ? File(camion['photo_camion'])
            : null;
        _carteGrise =
            camion['carte_grise'] != null ? File(camion['carte_grise']) : null;
        _visiteTechnique = camion['visite_technique'] != null
            ? File(camion['visite_technique'])
            : null;
        _assurance =
            camion['assurance'] != null ? File(camion['assurance']) : null;

        // Assign comments regardless of status
        _photoCamionCommentaire =
            camion['photo_camion_commentaire'] ?? _photoCamionCommentaire;
        _carteGriseCommentaire =
            camion['carte_grise_commentaire'] ?? _carteGriseCommentaire;
        _visiteTechniqueCommentaire = camion['visite_technique_commentaire'] ??
            _visiteTechniqueCommentaire;
        _assuranceCommentaire =
            camion['assurance_commentaire'] ?? _assuranceCommentaire;

        // Print comments to check if they are retrieved correctly
        print('Photo Camion Commentaire: $_photoCamionCommentaire');
        print('Carte Grise Commentaire: $_carteGriseCommentaire');
        print('Visite Technique Commentaire: $_visiteTechniqueCommentaire');
        print('Assurance Commentaire: $_assuranceCommentaire');

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur: $e');
    }
  }

  Future<void> _pickFile(int index) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      final filePath = result.files.single.path!;
      setState(() {
        switch (index) {
          case 0:
            _photoCamion = File(filePath);
            break;
          case 1:
            _carteGrise = File(filePath);
            break;
          case 2:
            _visiteTechnique = File(filePath);
            break;
          case 3:
            _assurance = File(filePath);
            break;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    try {
      Map<String, dynamic> data = {
        'matricule': _matriculeController.text,
      };

      if (_photoCamion != null) {
        data['photo_camion'] = await MultipartFile.fromFile(_photoCamion!.path);
      }
      if (_carteGrise != null) {
        data['carte_grise'] = await MultipartFile.fromFile(_carteGrise!.path);
      }
      if (_visiteTechnique != null) {
        data['visite_technique'] =
            await MultipartFile.fromFile(_visiteTechnique!.path);
      }
      if (_assurance != null) {
        data['assurance'] = await MultipartFile.fromFile(_assurance!.path);
      }

      if (data.keys.length <= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune modification détectée')),
        );
        return;
      }

      print('Data to be sent: $data');

      if (widget.matricule != null) {
        await ApiRequest().updateCamion(widget.matricule!, data);
      } else {
        // Logic to create a new camion (not provided in original code)
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camion mis à jour avec succès!')),
      );
    } catch (e) {
      print('Erreur lors de la mise à jour du camion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du camion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      buildTextField(
                        label: 'Numéro d\'immatriculation :',
                        controller: _matriculeController,
                        hintText: 'Ex: 22442890',
                      ),
                      const SizedBox(height: 10),
                      buildImageField(
                        label: "Photo du Camion",
                        file: _photoCamion,
                        onPressed: () => _pickFile(0),
                        commentaire: _photoCamionCommentaire,
                      ),
                      const SizedBox(height: 10),
                      buildImageField(
                        label: "Carte Grise",
                        file: _carteGrise,
                        onPressed: () => _pickFile(1),
                        commentaire: _carteGriseCommentaire,
                      ),
                      const SizedBox(height: 10),
                      buildImageField(
                        label: "Visite Technique",
                        file: _visiteTechnique,
                        onPressed: () => _pickFile(2),
                        commentaire: _visiteTechniqueCommentaire,
                      ),
                      const SizedBox(height: 10),
                      buildImageField(
                        label: "Assurance",
                        file: _assurance,
                        onPressed: () => _pickFile(3),
                        commentaire: _assuranceCommentaire,
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            const Color(0xFFFCCE00),
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          minimumSize: WidgetStateProperty.all<Size>(
                            const Size(double.infinity, 50),
                          ),
                        ),
                        child: const Text(
                          'Mettre à jour',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildImageField({
    required String label,
    required File? file,
    required VoidCallback onPressed,
    String? commentaire,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: file != null
                    ? ListTile(
                        title: Text(file.path.split('/').last),
                        trailing: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              switch (label) {
                                case "Photo du Camion":
                                  _photoCamion = null;
                                  break;
                                case "Carte Grise":
                                  _carteGrise = null;
                                  break;
                                case "Visite Technique":
                                  _visiteTechnique = null;
                                  break;
                                case "Assurance":
                                  _assurance = null;
                                  break;
                              }
                            });
                          },
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Aucun fichier sélectionné'),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(const Color(0xFFFCCE00)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Importer',
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
        if (commentaire != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              commentaire,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 16.0),
          const Text(
            "Enregistrer un Camion",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
