import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:ifret/api/api_request.dart';

class EnregistrerCamionModifPage extends StatefulWidget {
  final String? matricule;
  final Map<String, dynamic> details;

  EnregistrerCamionModifPage({required this.matricule, required this.details});

  @override
  _EnregistrerCamionModifPageState createState() =>
      _EnregistrerCamionModifPageState();
}

class _EnregistrerCamionModifPageState
    extends State<EnregistrerCamionModifPage> {
  TextEditingController _matriculeController = TextEditingController();
  File? _photoCamion;
  File? _carteGrise;
  File? _visiteTechnique;
  File? _assurance;
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
          SnackBar(content: Text('Aucune modification détectée')),
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
        SnackBar(content: Text('Camion mis à jour avec succès!')),
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
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      buildTextField(
                        label: 'Numéro d\'immatriculation :',
                        controller: _matriculeController,
                        hintText: 'Ex: 22442890',
                      ),
                      SizedBox(height: 10),
                      buildImageField(
                        label: "Photo du Camion",
                        file: _photoCamion,
                        onPressed: () => _pickFile(0),
                      ),
                      SizedBox(height: 10),
                      buildImageField(
                        label: "Carte Grise",
                        file: _carteGrise,
                        onPressed: () => _pickFile(1),
                      ),
                      SizedBox(height: 10),
                      buildImageField(
                        label: "Visite Technique",
                        file: _visiteTechnique,
                        onPressed: () => _pickFile(2),
                      ),
                      SizedBox(height: 10),
                      buildImageField(
                        label: "Assurance",
                        file: _assurance,
                        onPressed: () => _pickFile(3),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFFFCCE00),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(
                            Size(120, 48),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Valider',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 190,
          height: 42,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide: BorderSide(color: Colors.black),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0,
              ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            ElevatedButton(
              onPressed: onPressed,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color(0xFFFCCE00),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(45),
                  ),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(120, 48),
                ),
              ),
              child: Text('Sélectionner un fichier'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                file != null
                    ? file.path.split('/').last
                    : 'Aucun fichier sélectionné',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/hautTransport.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          DecoratedBox(
            decoration: BoxDecoration(),
            child: SizedBox.expand(),
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Image.asset(
              'assets/images/ifret.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 27, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.matricule != null
                        ? 'Mise à jour'
                        : 'Enregistrer Camion',
                    style: TextStyle(
                      color: Color(0xFFFCCE00),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Camion',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
