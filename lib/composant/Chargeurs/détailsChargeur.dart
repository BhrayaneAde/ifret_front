import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

class DetailsChargeur extends StatelessWidget {
  final int transactionId;

  DetailsChargeur({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
            RichText(
              text: TextSpan(
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
        backgroundColor: Color(0xFFFCCE00),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiRequest.fetchFretDetails(transactionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFCCE00),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text('Aucune donnée trouvée'),
            );
          }

          var transaction = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Détails du Chargeur',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 5),
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
                        title: Text(
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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        leading:
                            Icon(Icons.description, color: Color(0xfffcce00)),
                      ),
                    ),
                    SizedBox(height: 15),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tileColor: Colors.white,
                        title: Text(
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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        leading:
                            Icon(Icons.location_on, color: Color(0xfffcce00)),
                      ),
                    ),
                    SizedBox(height: 15),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tileColor: Colors.white,
                        title: Text(
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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        leading:
                            Icon(Icons.location_on, color: Color(0xfffcce00)),
                      ),
                    ),
                    SizedBox(height: 15),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tileColor: Colors.white,
                        title: Text(
                          'Montant:',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          transaction['montant'] ?? 'N/A',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        leading:
                            Icon(Icons.attach_money, color: Color(0xfffcce00)),
                      ),
                    ),
                    SizedBox(height: 15),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tileColor: Colors.white,
                        title: Text(
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
                            color: transaction['statut'] == 'En cours'
                                ? Colors.orange
                                : Colors.green,
                            fontSize: 16,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        leading:
                            Icon(Icons.info_outline, color: Color(0xfffcce00)),
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}

 
/* 
import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';

class DetailsChargeur extends StatelessWidget {
  final int transactionId;

  DetailsChargeur({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Chargeur'),
        backgroundColor: Color(0xFFFCCE00),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiRequest.fetchFretDetails(transactionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFCCE00),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text('Aucune donnée trouvée'),
            );
          }

          var transaction = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ListTile(
                  title: Text('Description'),
                  subtitle: Text(transaction['description'] ?? 'N/A'),
                ),
                ListTile(
                  title: Text('Lieu de départ'),
                  subtitle: Text(transaction['lieu_depart'] ?? 'N/A'),
                ),
                ListTile(
                  title: Text('Lieu d\'arrivée'),
                  subtitle: Text(transaction['lieu_arrive'] ?? 'N/A'),
                ),
                ListTile(
                  title: Text('Montant'),
                  subtitle: Text(transaction['montant'] ?? 'N/A'),
                ),
                ListTile(
                  title: Text('Statut'),
                  subtitle: Text(transaction['statut'] ?? 'N/A'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
 */