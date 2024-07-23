import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Chargeurs/profilChargeur.dart';
import 'package:ifret/main.dart';
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk_platform_interface.dart';

import 'success_screen.dart';

class Chargeur extends StatefulWidget {
  final String name;
  final String profileUrl;
  final String username;

  Chargeur({
    required this.name,
    required this.profileUrl,
    required this.username,
  });

  @override
  State<Chargeur> createState() => _ChargeurState();
}

class _ChargeurState extends State<Chargeur> {
  List<Message> _messages = [];
  TextEditingController _messageController = TextEditingController();
  int _currentIndex = 0;
  String? _currentUserNumeroTel;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      var response = await ApiRequest.fetchMessages();
      if (response != null &&
          response is Map<String, dynamic> &&
          response.containsKey('messages')) {
        List<dynamic> messagesData = response['messages'];
        List<Message> messages = messagesData
            .map((messageData) => Message.fromJson(messageData))
            .toList();
        setState(() {
          _messages = messages;
        });
        // Afficher une notification si un message de type "admin" est reçu
        _showAdminMessagesNotification(messages);
      } else {
        print('La réponse de l\'API ne contient pas la clé "messages".');
      }
    } catch (e) {
      print('Erreur lors de la récupération des messages : $e');
    }
  }

  void _showAdminMessagesNotification(List<Message> messages) {
    for (var message in messages) {
      if (message.type == 'admin') {
        _showNotification(message.text);
      }
    }
  }

  Future<void> _showNotification(String messageText) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Nouveau message de l\'administrateur',
      messageText,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFFCCE00),
        unselectedItemColor: Colors.black,
        items: [
          _bottomNavigationBarItem(
            icon: Icons.mail,
            label: 'Messagerie',
            index: 0,
          ),
          _bottomNavigationBarItem(
            icon: Icons.payment,
            label: 'Paiement',
            index: 1,
          ),
          _bottomNavigationBarItem(
            icon: Icons.car_crash,
            label: 'Tracking',
            index: 2,
          ),
          _bottomNavigationBarItem(
            icon: Icons.person,
            label: 'Profil',
            index: 3,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _bottomNavigationBarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
      backgroundColor: Colors.white,
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _getMessages();
      case 1:
        return KkiapaySample();
      case 2:
        return Tracking();
      case 3:
        return ProfilChargeur();
      default:
        return Container();
    }
  }

  Widget _getMessages() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: ApiRequest.fetchMessages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('En attente de la récupération des messages...');
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(
              'Erreur lors de la récupération des messages : ${snapshot.error}');
          return Center(child: Text('Erreur de chargement des messages'));
        } else if (snapshot.hasData) {
          print('Messages récupérés avec succès !');

          List<Message> messages = [];
          if (snapshot.data != null && snapshot.data! is Map<String, dynamic>) {
            print('Données des messages : ${snapshot.data!['messages']}');

            if (snapshot.data!['messages'] is List) {
              (snapshot.data!['messages'] as List<dynamic>)
                  .forEach((messageData) {
                Message message = Message.fromJson(messageData);
                messages.add(message);
              });
            } else {
              print('La clé "messages" ne contient pas une liste.');
            }
          } else {
            print('La réponse de l\'API n\'est pas dans le format attendu.');
          }

          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          if (messages.isEmpty) {
            return Center(child: Text('Aucun message disponible'));
          }

          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.only(bottom: 90.0, top: 130),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = messages.length - 1 - index;
                      return chatMessageTile(messages[reversedIndex]);
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (messageText) {
                          sendMessage(messageText);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Message",
                          hintStyle: TextStyle(color: Colors.black45),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage(_messageController.text);
                      },
                      child: Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Center(child: Text('Aucun message disponible'));
        }
      },
    );
  }

  Widget chatMessageTile(Message message) {
    bool isSentByAdmin = message.type == 'admin';
    bool isSentByUser = message.type == 'sent';

    return Align(
      alignment: isSentByAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSentByAdmin ? Colors.yellow : Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isSentByAdmin ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  void sendMessage(String messageText) {
    ApiRequest.sendMessage(messageText).then((response) {
      if (response != null) {
        setState(() {
          Message message = Message(
            text: messageText,
            type: 'sent', // Le type de message envoyé par l'utilisateur

            createdAt: DateTime.now(),
          );
          _messages.insert(0, message);
          _messageController.clear();
        });
      } else {
        print('Échec de l\'envoi du message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de l\'envoi du message'),
          ),
        );
      }
    }).catchError((error) {
      print('Erreur lors de l\'envoi du message : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi du message'),
        ),
      );
    });
  }
}

class Message {
  final String text;
  final String type;
  final DateTime createdAt;

  Message({required this.text, required this.createdAt, required this.type});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      type: json['type'],
    );
  }
}

/* 
class MesInformations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Informations'),
      ),
      body: Center(
        child: Text('Contenu de Mes Informations'),
      ),
    );
  }
} */

// Votre clé API publique ici
const String publicApiKey = "2b8e553045da11efba1789f22fb73fae";

void callback(response, context) {
  switch (response['status']) {
    case PAYMENT_CANCELLED:
      debugPrint(PAYMENT_CANCELLED);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(PAYMENT_CANCELLED),
      ));
      break;

    case PENDING_PAYMENT:
      debugPrint(PENDING_PAYMENT);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(PENDING_PAYMENT),
      ));
      break;

    case PAYMENT_INIT:
      debugPrint(PAYMENT_INIT);
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //content: Text(PAYMENT_INIT),
      //));
      break;

    case PAYMENT_SUCCESS:
      debugPrint(PAYMENT_SUCCESS);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(PAYMENT_SUCCESS),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            amount: response['requestData']['amount'],
            transactionId: response['transactionId'],
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(PAYMENT_SUCCESS),
      ));
      break;
    case PAYMENT_FAILED:
      debugPrint(PAYMENT_FAILED);
      break;

    default:
      debugPrint(UNKNOWN_EVENT);
      break;
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor:
              Colors.blue, // Utilisez la couleur primaire souhaitée
          title: const Text('Kkiapay Sample'),
          centerTitle: true,
        ),
        body: const KkiapaySample(),
      ),
    );
  }
}

class KkiapaySample extends StatelessWidget {
  void _callback(Map<String, dynamic> response, BuildContext context) {
    switch (response['status']) {
      case PAYMENT_CANCELLED:
        debugPrint(PAYMENT_CANCELLED);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PAYMENT_CANCELLED),
        ));
        break;

      case PENDING_PAYMENT:
        debugPrint(PENDING_PAYMENT);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PENDING_PAYMENT),
        ));
        break;

      case PAYMENT_INIT:
        debugPrint(PAYMENT_INIT);
        break;

      case PAYMENT_SUCCESS:
        debugPrint(PAYMENT_SUCCESS);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PAYMENT_SUCCESS),
        ));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              amount: response['requestData']['amount'],
              transactionId: response['transactionId'],
            ),
          ),
        );
        break;

      default:
        debugPrint(UNKNOWN_EVENT);
        break;
    }
  }

  const KkiapaySample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Création de l'objet KKiaPay
    final kkiapay = const KKiaPay(
      amount: 1000,
      countries: ["BJ", "CI", "SN", "TG"],
      phone: "22961000000",
      name: "John Doe",
      email: "email@mail.com",
      reason: 'transaction reason',
      data: 'Fake data',
      sandbox: true,
      apikey: publicApiKey,
      callback:
          callback, // Assurez-vous que la signature du callback est correcte
      theme: defaultTheme,
      partnerId: 'AxXxXXxId',
      paymentMethods: ["momo", "card"],
    );

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ButtonTheme(
            minWidth: 500.0,
            height: 100.0,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xff222F5A)),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text(
                'Pay Now ( on Mobile )',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => kkiapay),
                );
              },
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class Tracking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking'),
      ),
      body: Center(
        child: Text('Contenu de Tracking'),
      ),
    );
  }
}
