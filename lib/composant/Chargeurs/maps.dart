import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

const kGoogleApiKey = "AIzaSyA26h7EKkKUUYcy-PvyFDS_Zc2DJmsWVVw";

class MapSelectPosition extends StatefulWidget {
  final Function(String, LatLng) onLocationSelected; // Fonction de rappel

  MapSelectPosition({required this.onLocationSelected});

  @override
  _MapSelectPositionState createState() => _MapSelectPositionState();
}

class _MapSelectPositionState extends State<MapSelectPosition> {
  GoogleMapController? mapController;
  TextEditingController _searchController = TextEditingController();
  LatLng? currentPosition;
  final GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  bool isLoading = false; // Pour gérer l'état de chargement

  @override
  void initState() {
    super.initState();
    // Position de Cotonou, Bénin par défaut
    currentPosition = LatLng(6.3702928, 2.3912365); // Coordonnées de Cotonou
    _getCurrentLocation(); // Pour obtenir la position actuelle si nécessaire
  }

  // Obtenir la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Autorisation de localisation refusée.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Autorisation de localisation refusée de manière permanente. Veuillez l\'activer dans les paramètres.'),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner Lieu de Départ'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
              // Déplacer la caméra sur la position actuelle
              if (currentPosition != null) {
                _moveCameraTo(currentPosition!);
              }
            },
            initialCameraPosition: CameraPosition(
              target: currentPosition!, // Position par défaut
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: (LatLng tappedLocation) {
              _confirmLocation(
                  tappedLocation); // Confirmation lors du clic sur la carte
            },
          ),
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: GooglePlaceAutoCompleteTextField(
              textEditingController: _searchController,
              googleAPIKey: kGoogleApiKey,
              countries: ["bj"], // Limiter la recherche au Bénin
              boxDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              inputDecoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Rechercher votre adresse",
                hintStyle: GoogleFonts.inter(color: Colors.black54),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              containerHorizontalPadding: 10,
              itemClick: (prediction) async {
                _searchController.clear();
                setState(() => isLoading = true); // Commencer le chargement

                // Ajouter un délai pour le chargement
                await Future.delayed(const Duration(seconds: 1));

                // Obtenir les détails du lieu sélectionné
                PlacesDetailsResponse detail =
                    await places.getDetailsByPlaceId(prediction.placeId!);
                final lat = detail.result.geometry!.location.lat;
                final lng = detail.result.geometry!.location.lng;

                mapController?.animateCamera(
                  CameraUpdate.newLatLng(LatLng(lat, lng)),
                );

                setState(() => isLoading = false); // Arrêter le chargement
              },
            ),
          ),
          if (isLoading)
            const Center(
                child:
                    CircularProgressIndicator()), // Afficher l'indicateur de chargement
        ],
      ),
    );
  }

  void _moveCameraTo(LatLng position) {
    mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  Future<void> _confirmLocation(LatLng location) async {
    try {
      // Utiliser Geocoding pour obtenir l'adresse complète à partir des coordonnées
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      ).timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Utiliser la localité et la sous-localité pour former le nom du lieu
        String placeName =
            "${place.locality ?? 'Inconnu'}, ${place.subLocality ?? 'Inconnu'}";
        String fullLocation =
            '$placeName (Lat: ${location.latitude}, Lng: ${location.longitude})';

        // Afficher une boîte de dialogue de confirmation
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirmer le Lieu'),
              content: Text('Confirmez-vous le lieu suivant :\n$fullLocation'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    widget.onLocationSelected(fullLocation,
                        location); // Passer la localisation complète au parent
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .pop(); // Fermer la page de sélection de lieu
                  },
                  child: const Text('Confirmer'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Aucun lieu trouvé pour cette position.")),
        );
      }
    } catch (e) {
      // Gérer les erreurs, comme le délai d'attente ou les problèmes de réseau
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur lors de la récupération de la position.")),
      );
      print('Erreur: $e');
    }
  }
}
