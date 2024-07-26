import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Chargeurs/paiement.dart';

class DetailsChargeur extends StatefulWidget {
  final int transactionId;
  final int fretId;

  DetailsChargeur({required this.transactionId, required this.fretId});

  @override
  _DetailsChargeurState createState() => _DetailsChargeurState();
}

class _DetailsChargeurState extends State<DetailsChargeur> {
  int _totalPaid = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTotalPaidAmount();
  }

  Future<void> _fetchTotalPaidAmount() async {
    try {
      int totalPaid =
          await ApiRequest.fetchTotalPaidAmount(widget.fretId.toString());
      setState(() {
        _totalPaid = totalPaid;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching total paid amount: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        future: ApiRequest.fetchFretDetails(widget.transactionId),
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
          var montant = transaction['montant'];

          // Convertir montant en entier si nécessaire
          int montantInt;
          try {
            montantInt = int.parse(montant);
          } catch (e) {
            return Center(
              child: Text('Erreur: montant invalide'),
            );
          }

          double progress = _totalPaid / montantInt;

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
                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFCCE00),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Progression du paiement: ${(_totalPaid / montantInt * 100).toStringAsFixed(2)}%',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 15),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _showPaymentOptions(
                              context, widget.transactionId, montantInt);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff222F5A),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: Text(
                          'Effectuer un paiement',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
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

  void _showPaymentOptions(
      BuildContext context, int transactionId, int montantInt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisissez une option de paiement'),
          content:
              Text('Voulez-vous payer le solde totalement ou partiellement?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showPartialPaymentOptions(
                          context, transactionId, montantInt);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('Partiellement'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _initiatePayment(
                          context, transactionId, montantInt - _totalPaid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Totalement'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showPartialPaymentOptions(
      BuildContext context, int transactionId, int montantInt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('En combien de tranches?'),
          content: Text('Choisissez le nombre de tranches pour le paiement.'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _initiatePayment(context, transactionId,
                          ((montantInt - _totalPaid) / 2).round());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('2 tranches'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _initiatePayment(context, transactionId,
                          ((montantInt - _totalPaid) / 3).round());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('3 tranches'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _initiatePayment(
      BuildContext context, int transactionId, int montantPaye) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaiementPage(
          transactionId: transactionId.toString(), // Conversion en String
          montant: montantPaye,
        ),
      ),
    );
  }
}
