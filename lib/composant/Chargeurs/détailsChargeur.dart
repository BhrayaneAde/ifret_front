import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

class DetailsChargeur extends StatelessWidget {
  final int transactionId;

  const DetailsChargeur(
      {super.key, required this.transactionId, required int fretId});

  void _showFeedbackModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Évaluation du client'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Veuillez évaluer la qualité du client :'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.sentiment_very_dissatisfied,
                        color: Colors.red),
                    onPressed: () {
                      _submitFeedback(context, "1"); // Mauvaise évaluation
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.sentiment_dissatisfied,
                        color: Colors.orange),
                    onPressed: () {
                      _submitFeedback(context, "2"); // Moyenne évaluation
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied,
                        color: Colors.yellow),
                    onPressed: () {
                      _submitFeedback(context, "3"); // Bonne évaluation
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.sentiment_very_satisfied,
                        color: Colors.green),
                    onPressed: () {
                      _submitFeedback(context, "4"); // Très bonne évaluation
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitFeedback(BuildContext context, String feedback) async {
    try {
      // Envoyer le feedback (en tant que string)
      await ApiRequest.updateFeedbackAndStatut(transactionId, feedback);

      // Fermer le modal et afficher un message de succès
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Merci pour votre évaluation ! Le statut est finalisé.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du feedback : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Spacer(),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Détails du Fret',
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFCCE00),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiRequest.fetchFretDetails(transactionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFCCE00),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Aucune donnée trouvée'),
            );
          }

          var transaction = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Afficher l'image
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.network(
                      transaction['image_url'] ??
                          'https://example.com/image.jpg', // Replace with your direct image URL
                      height: 200, // Adjust the height as needed
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
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return const Center(
                            child: Text('L\'image n\'est pas disponible'));
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 5),
                Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tileColor: Colors.white,
                        title: const Text(
                          'Description:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          transaction['description'] ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        leading: const Icon(Icons.description,
                            color: Color(0xfffcce00)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tileColor: Colors.white,
                        title: const Text(
                          'Lieu de départ:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          transaction['lieu_depart'] ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        leading: const Icon(Icons.location_on,
                            color: Color(0xfffcce00)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tileColor: Colors.white,
                        title: const Text(
                          'Lieu d\'arrivée:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          transaction['lieu_arrive'] ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        leading: const Icon(Icons.location_on,
                            color: Color(0xfffcce00)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tileColor: Colors.white,
                        title: const Text(
                          'Montant:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          transaction['montant']?.toString() ??
                              'N/A', // Convert to String
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        leading: const Icon(Icons.attach_money,
                            color: Color(0xfffcce00)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tileColor: Colors.white,
                        title: const Text(
                          'Statut:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          transaction['statut'] ?? 'N/A',
                          style: TextStyle(
                            color: (transaction['statut'] == 'en attente' ||
                                    transaction['statut'] == 'En attente' ||
                                    transaction['statut'] == 'En cours' ||
                                    transaction['statut'] == 'in progress')
                                ? Colors.orange
                                : Colors.green,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        leading: const Icon(Icons.check_circle,
                            color: Color(0xfffcce00)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _showFeedbackModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFCCE00),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Évaluer le client',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
