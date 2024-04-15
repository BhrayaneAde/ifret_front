import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TrafficChargeur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traffic'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.directions_car),
                          SizedBox(width: 5),
                          Text('Camion'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 5),
                          Text('John Doe'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.check_circle),
                          SizedBox(width: 5),
                          Text('Completed'),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Spacer(),
                SizedBox(height: 50),
                Align(
                  alignment: Alignment.topCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      _showDetailsDialog(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFFFCCE00)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                    child: Text(
                      'Détails',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails du trafic'),
          content: Text('Ajoutez ici les détails complets du trafic.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
