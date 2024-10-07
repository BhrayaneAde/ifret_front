import 'package:flutter/material.dart';
import 'package:ifret/api/api_request.dart';
import 'package:ifret/composant/Chargeurs/profilChargeur.dart';

class Chargeur extends StatefulWidget {
  final String name;
  final String profileUrl;
  final String username;

  const Chargeur({
    super.key,
    required this.name,
    required this.profileUrl,
    required this.username,
  });

  @override
  State<Chargeur> createState() => _ChargeurState();
}

class _ChargeurState extends State<Chargeur> {
  List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
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
      if (response != null && response.containsKey('messages')) {
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
        selectedItemColor: const Color(0xFFFCCE00),
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
        return const Paiement();
      case 2:
        return const Tracking();
      case 3:
        return const ProfilChargeur();
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(
              'Erreur lors de la récupération des messages : ${snapshot.error}');
          return const Center(child: Text('Erreur de chargement des messages'));
        } else if (snapshot.hasData) {
          print('Messages récupérés avec succès !');

          List<Message> messages = [];
          if (snapshot.data != null) {
            print('Données des messages : ${snapshot.data!['messages']}');

            if (snapshot.data!['messages'] is List) {
              for (var messageData
                  in (snapshot.data!['messages'] as List<dynamic>)) {
                Message message = Message.fromJson(messageData);
                messages.add(message);
              }
            } else {
              print('La clé "messages" ne contient pas une liste.');
            }
          } else {
            print('La réponse de l\'API n\'est pas dans le format attendu.');
          }

          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          if (messages.isEmpty) {
            return const Center(child: Text('Aucun message disponible'));
          }

          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.only(bottom: 90.0, top: 130),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = messages.length - 1 - index;
                      return chatMessageTile(messages[reversedIndex]);
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (messageText) {
                          sendMessage(messageText);
                        },
                        decoration: const InputDecoration(
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
                      child: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('Aucun message disponible'));
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
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
          const SnackBar(
            content: Text('Échec de l\'envoi du message'),
          ),
        );
      }
    }).catchError((error) {
      print('Erreur lors de l\'envoi du message : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
  const Paiement({super.key});

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
          const SizedBox(height: 20),
          Expanded(
            child: _currentTabIndex == 0
                ? const PaiementLocal()
                : const PaiementInternational(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 245, 234, 234),
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
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border:
                    Border.all(color: const Color.fromARGB(255, 252, 250, 250)),
                color: _currentTabIndex == 0 ? const Color(0xFFFCCE00) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_sharp,
                      color:
                          _currentTabIndex == 0 ? Colors.white : Colors.black),
                  const SizedBox(width: 8.0),
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
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border:
                    Border.all(color: const Color.fromARGB(255, 247, 245, 245)),
                color: _currentTabIndex == 1 ? const Color(0xFFFCCE00) : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_sharp,
                      color:
                          _currentTabIndex == 1 ? Colors.white : Colors.black),
                  const SizedBox(width: 8.0),
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
    return SizedBox(
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
          const DecoratedBox(
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
                    style: const TextStyle(
                      color: Color(0xFFFCCE00),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
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
  const PaiementLocal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          const Center(
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
              const SizedBox(height: 70.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement local (Fedapay MTN)
                  // Ajoutez le code de traitement pour le paiement local ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/mtn.png', height: 30.0),
                    const SizedBox(width: 8.0),
                  ],
                ),
              ),
              /* SizedBox(height: 16.0), */
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement local (Fedapay Moov)
                  // Ajoutez le code de traitement pour le paiement local ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/moov.png', height: 30.0),
                    const SizedBox(width: 8.0),
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
  const PaiementInternational({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          const Center(
            child: Text(
              'Choisissez un moyen de paiement international:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
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
                    const SizedBox(width: 8.0),
                    /* Text('Visa'), */
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement international (PayPal)
                  // Ajoutez le code de traitement pour le paiement international ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/paypal.png', height: 20.0),
                    const SizedBox(width: 8.0),
                    /* Text('PayPal'), */
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Gérer le paiement international (MasterCard)
                  // Ajoutez le code de traitement pour le paiement international ici
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/mastercard-2.png', height: 20.0),
                    const SizedBox(width: 8.0),
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
  const Tracking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking'),
      ),
      body: const Center(
        child: Text('Contenu de Tracking'),
      ),
    );
  }
}
