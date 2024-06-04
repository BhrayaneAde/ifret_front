import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Chargeurs/profilChargeur.dart';

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
      } else {
        print('La réponse de l\'API ne contient pas la clé "messages".');
      }
    } catch (e) {
      print('Erreur lors de la récupération des messages : $e');
    }
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
        return Paiement();
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
      text: json['text'],
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

class Paiement extends StatefulWidget {
  @override
  _PaiementState createState() => _PaiementState();
}

class _PaiementState extends State<Paiement> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(
        title: Text('Paiement'),
      ), */
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 20),
          Expanded(
            child: _currentTabIndex == 0
                ? PaiementLocal()
                : PaiementInternational(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 245, 234, 234),
        currentIndex: _currentTabIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border:
                    Border.all(color: const Color.fromARGB(255, 252, 250, 250)),
                color: _currentTabIndex == 0 ? Color(0xFFFCCE00) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_sharp,
                      color:
                          _currentTabIndex == 0 ? Colors.white : Colors.black),
                  SizedBox(width: 8.0),
                  Text(
                    'Paiement Local',
                    style: TextStyle(
                        color: _currentTabIndex == 0
                            ? Colors.white
                            : Colors.black),
                  ),
                ],
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Color.fromARGB(255, 247, 245, 245)),
                color: _currentTabIndex == 1 ? Color(0xFFFCCE00) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_sharp,
                      color:
                          _currentTabIndex == 1 ? Colors.white : Colors.black),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Paiement International',
                      style: TextStyle(
                          color: _currentTabIndex == 1
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/hautPaiement1.jpg', // Chemin de votre image
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
                /*  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Color.fromARGB(255, 248, 134, 3).withOpacity(0.3)
                ],
              ), */
                ),
            child:
                SizedBox.expand(), // Pour étendre le dégradé sur toute l'image
          ),
          Positioned(
            left: 16.0,
            top: 16.0,
            child: Image.asset(
              'assets/images/ifret.png', // Chemin de votre image
              width: 70, // Largeur de l'image
              height: 70, // Hauteur de l'image
              fit: BoxFit.cover, // Ajustement de l'image
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
                    _currentTabIndex == 0
                        ? 'Paiement Local'
                        : 'Paiement International',
                    style: TextStyle(
                      color: Color(0xFFFCCE00),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'En Ligne',
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

class PaiementLocal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          Center(
            child: Text(
              'Choisissez un moyen de paiement local:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 70.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement local (Fedapay MTN)
                  // Ajoutez le code de traitement pour le paiement local ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/mtn.png', height: 30.0),
                    SizedBox(width: 8.0),
                  ],
                ),
              ),
              /* SizedBox(height: 16.0), */
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement local (Fedapay Moov)
                  // Ajoutez le code de traitement pour le paiement local ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/moov.png', height: 30.0),
                    SizedBox(width: 8.0),
                    /* Text('Moov'), */
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class PaiementInternational extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          Center(
            child: Text(
              'Choisissez un moyen de paiement international:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement international (Visa)
                  // Ajoutez le code de traitement pour le paiement international ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/visa.png', height: 20.0),
                    SizedBox(width: 8.0),
                    /* Text('Visa'), */
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement international (PayPal)
                  // Ajoutez le code de traitement pour le paiement international ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/paypal.png', height: 20.0),
                    SizedBox(width: 8.0),
                    /* Text('PayPal'), */
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement international (MasterCard)
                  // Ajoutez le code de traitement pour le paiement international ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/mastercard-2.png', height: 20.0),
                    SizedBox(width: 8.0),
                    /*  Text('MasterCard'), */
                  ],
                ),
              ),
            ],
          ),
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
