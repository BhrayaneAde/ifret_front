import 'package:flutter/material.dart';

class NotificationTransporteur extends StatefulWidget {
  const NotificationTransporteur({super.key});

  @override
  _NotificationTransporteurState createState() =>
      _NotificationTransporteurState();
}

class _NotificationTransporteurState extends State<NotificationTransporteur> {
  final List<Map<String, dynamic>> _notifications = [];
  int _notificationCount = 0; // Ajout du compteur de notifications

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    // Simulation de l'ajout de notifications pour démonstration
    _notifications.addAll([
      {
        'message': 'Nouvelle commande reçue',
        'date': '10 avril 2024',
        'read': false,
      },
      {
        'message': 'Mise à jour de l\'application disponible',
        'date': '8 avril 2024',
        'read': true,
      },
      {
        'message': 'Nouvelle fonctionnalité ajoutée',
        'date': '6 avril 2024',
        'read': false,
      },
    ]);

    _notificationCount = _notifications.length;
  }

  void _markNotificationAsRead(int index) {
    setState(() {
      // Marquer la notification comme lue
      _notifications[index]['read'] = true;
      _notificationCount--; // Décrémentation du compteur de notifications
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tri des notifications en fonction de leur état de lecture
    _notifications.sort((a, b) {
      if (a['read'] == true && b['read'] == false) {
        return 1;
      } else if (a['read'] == false && b['read'] == true) {
        return -1;
      } else {
        return 0;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              _notifications[index]['message'],
              // Utiliser le fontWeight en fonction de l'état de lecture de la notification
              style: TextStyle(
                fontWeight: _notifications[index]['read'] == true
                    ? FontWeight.normal
                    : FontWeight.bold,
              ),
            ),
            subtitle: Text(_notifications[index]['date']),
            onTap: () {
              // Lorsque l'utilisateur appuie sur la notification,
              // elle est marquée comme lue et retirée de la liste
              _markNotificationAsRead(index);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_active),
                if (_notificationCount !=
                    0) // Afficher l'indice uniquement si le compteur est différent de zéro
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: NotificationTransporteur(),
  ));
}
